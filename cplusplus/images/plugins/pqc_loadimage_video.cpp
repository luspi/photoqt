/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include <pqc_loadimage_video.h>
#include <pqc_settingscpp.h>
#include <QImage>
#include <QImageReader>
#include <QProcess>
#include <QDir>
#ifdef PQMFFMPEGTHUMBNAILER
#include <pqc_loadimage.h>
#include <QTemporaryFile>
#include <libffmpegthumbnailer/videothumbnailer.h>
#include <libffmpegthumbnailer/filmstripfilter.h>
#endif

PQCLoadImageVideo::PQCLoadImageVideo() {}

PQCLoadImageVideo::~PQCLoadImageVideo() {}

const QSize PQCLoadImageVideo::loadSize(QString filename) {

    if(PQCSettingsCPP::get().getFiletypesVideoThumbnailer() == "ffmpegthumbnailer") {

#ifdef PQMFFMPEGTHUMBNAILER

        ffmpegthumbnailer::VideoThumbnailer thumbnailer;

        thumbnailer.setThumbnailSize(0);
        thumbnailer.setMaintainAspectRatio(true);
        thumbnailer.setSmartFrameSelection(true);
        thumbnailer.setWorkAroundIssues(true);

        // we use a temporary file that is automatically removed afterwards
        QTemporaryFile tempFile;
        tempFile.setAutoRemove(true);

        // we need to open it in order for it to be created and have a filename
        if(!tempFile.open()) {

            qWarning() << "Unable to open temporary file from thumbnail generation.";

        } else {

            // release the file
            tempFile.close();

            thumbnailer.generateThumbnail(filename.toStdString(), ThumbnailerImageType::Jpeg, tempFile.fileName().toStdString());

            // reopening the file is safe
            if(!tempFile.open()) {

                qWarning() << "Unable to open temporary file from thumbnail generation.";

            } else {

                // attempt to load file
                QImage img;
                QSize origSize;
                QString err = PQCLoadImage::get().load(tempFile.fileName(), QSize(-1,-1), origSize, img);

                if(!err.isEmpty())
                    qWarning() << "Failed to load video thumbnail from temporary file";
                else
                    return img.size();

            }

        }

#endif

#ifdef Q_OS_LINUX

        // the temp image thumbnail path (incl random int)
        QString tmp_path = QString("%1/photoqt_videothumb_%2.jpg").arg(QDir::tempPath()).arg(rand());

        // create thumbnail using ffmpegthumbnailer, the -s0 makes it create a thumbnail at original size
        QProcess proc;
        int ret = proc.execute("ffmpegthumbnailer", QStringList() << "-i" << filename << "-s0" << "-o" << tmp_path);

        if(ret != 0) {
            qWarning() << "ffmpegthumbnailer ended with error code" << ret << "- is it installed?";
            return QSize();
        }

        QImageReader reader(tmp_path);
        const QSize orig = reader.size();

        // remove temporary thumbnail file
        QFile::remove(tmp_path);

        // store in return variable
        return orig;

#endif

    }

    qWarning() << "Unknown video thumbnailer used:" << PQCSettingsCPP::get().getFiletypesVideoThumbnailer();;
    return QSize();

}

const QString PQCLoadImageVideo::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "** filename =" << filename;
    qDebug() << "** maxSize =" << maxSize;

    QString errormsg = "";

    if(PQCSettingsCPP::get().getFiletypesVideoThumbnailer() == "ffmpegthumbnailer") {

#ifdef PQMFFMPEGTHUMBNAILER

        ffmpegthumbnailer::VideoThumbnailer thumbnailer;

        thumbnailer.setThumbnailSize(maxSize.width(), maxSize.height());
        thumbnailer.setMaintainAspectRatio(true);
        thumbnailer.setSmartFrameSelection(true);
        thumbnailer.setWorkAroundIssues(true);

        // add movie-strip overlay
        ffmpegthumbnailer::FilmStripFilter filmStrip;
        thumbnailer.addFilter(&filmStrip);

        // we use a temporary file that is automatically removed afterwards
        QTemporaryFile tempFile;
        tempFile.setAutoRemove(true);

        // we need to open it in order for it to be created and have a filename
        if(!tempFile.open()) {
            const QString err = "Unable to open temporary file from thumbnail generation.";
            qWarning() << err;
            return err;
        }
        // release the file
        tempFile.close();

        thumbnailer.generateThumbnail(filename.toStdString(), ThumbnailerImageType::Jpeg, tempFile.fileName().toStdString());

        // reopening the file is safe
        if(!tempFile.open()) {
            const QString err = "Unable to open temporary file from thumbnail generation.";
            qWarning() << err;
            return err;
        }

        // attempt to load file
        QString err = PQCLoadImage::get().load(tempFile.fileName(), QSize(-1,-1), origSize, img);

        if(!err.isEmpty())
            qWarning() << "Failed to load video thumbnail from temporary file";
        else
            return "";

#endif

#ifdef Q_OS_LINUX


        // the temp image thumbnail path (incl random int)
        QString tmp_path = QString("%1/photoqt_videothumb_%2.jpg").arg(QDir::tempPath()).arg(rand());

        // create thumbnail using ffmpegthumbnailer
        QProcess proc;
        int ret = proc.execute("ffmpegthumbnailer", QStringList() << "-i" << filename << "-s0" << "-o" << tmp_path);

        // without this it seems like zombie ffmpeg processes might appear
        proc.kill();

        if(ret != 0) {
            errormsg = QString("ffmpegthumbnailer ended with error code %1 - is it installed?").arg(ret);
            qWarning() << errormsg;
            return errormsg;
        }

        img = QImage(tmp_path);

        origSize = img.size();

        // remove temporary thumbnail file
        QFile::remove(tmp_path);

        // Scale image if necessary
        if(maxSize.width() != -1) {
            img = img.scaled(origSize.scaled(maxSize, Qt::KeepAspectRatio),
                             Qt::IgnoreAspectRatio,
                             (PQCSettingsCPP::get().getImageviewRescalingSmooth() ? Qt::SmoothTransformation : Qt::FastTransformation));
        }

        // store in return variable
        return "";

#endif

    } else if(PQCSettingsCPP::get().getFiletypesVideoThumbnailer().isEmpty()) {

        errormsg = "No video thumbnailer selected";
        qWarning() << errormsg;
        return errormsg;

    }

    errormsg = "Unknown video thumbnailer used: " + PQCSettingsCPP::get().getFiletypesVideoThumbnailer();
    qWarning() << errormsg;
    return errormsg;

}
