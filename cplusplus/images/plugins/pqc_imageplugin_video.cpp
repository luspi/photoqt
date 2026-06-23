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

#include <imageplugins/pqc_imageplugin_video.h>
#include <pqc_settingscpp.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <pqc_imagecache.h>
#include <pqc_helper.h>

#include <QFile>
#include <QtDebug>
#include <QProcess>
#include <QImageReader>
#include <QTemporaryFile>
#ifdef PQMFFMPEGTHUMBNAILER
#include <libffmpegthumbnailer/videothumbnailer.h>
#include <libffmpegthumbnailer/filmstripfilter.h>
#endif


PQCImagePluginVideo::PQCImagePluginVideo(bool mpvNotQt) : m_mpvNotQt(mpvNotQt) {

    setData({
            {45123,
                 {{"3GP: 3rd Generation Partnership Project"}, {"3gp","3g2"}, {"video/3gpp","video/3gpp2"}}},
            {99887,
                 {{"AMV video format"}, {"amv"}, {}}},
            {11556,
                 {{"Advanced Systems Format"}, {"asf"}, {"video/x-ms-asf","application/vnd.ms-asf"}}},
            {33221,
                 {{"Audio Video Interleave"}, {"avi"}, {"video/vnd.avi","video/avi","video/msvideo","video/x-msvideo"}}},
            {55665,
                 {{"Flash Video"}, {"flv","f4v"}, {"video/x-flv"}}},
            {56478,
                 {{"MP4: MPEG-4 Part 14"}, {"mp4","m4v"}, {"video/mp4"}}},
            {23588,
                 {{"MPEG Transport Stream"}, {"mts","m2ts","ts"}, {"video/mp2t"}}},
            {15485,
                 {{"MPEG: Moving Picture Experts Group"}, {"mpg","mp2","mpeg","mpe","mpv","m2v"}, {"video/mpeg"}}},
            {47564,
                 {{"MXF: Material Exchange Format"}, {"mxf"}, {"application/mxf"}}},
            {44664,
                 {{"Matroska Video"}, {"mkv"}, {"video/x-matroska"}}},
            {82282,
                 {{"QuickTime File Format"}, {"mov","qt"}, {"video/quicktime"}}},
            {46512,
                 {{"RealMedia"}, {"rm"}, {"application/vnd.rn-realmedia"}}},
            {93393,
                 {{"Theora"}, {"ogg","ogv"}, {}}},
            {88818,
                 {{"Video Object"}, {"vob"}, {}}},
            {99929,
                 {{"WebM"}, {"webm"}, {"video/webm"}}},
            {16452,
                 {{"Windows Media Video"}, {"wmv"}, {"video/x-ms-wmv"}}},
            {33332,
                 {{"JPEG-2000 MJ2 video"}, {"mj2"}, {"video/mj2"}}}},
            (mpvNotQt ? "libmpv" : "video"));
}

const QSize PQCImagePluginVideo::loadSize(QString path) {

    if(PQCSettingsCPP::get().getFiletypesVideoThumbnailer() == "ffmpegthumbnailer") {

#ifdef PQMFFMPEGTHUMBNAILER

        try {

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

                thumbnailer.generateThumbnail(path.toStdString(), ThumbnailerImageType::Jpeg, tempFile.fileName().toStdString());

                // reopening the file is safe
                if(!tempFile.open()) {

                    qWarning() << "Unable to open temporary file from thumbnail generation.";

                } else {

                    // this is a JPEG, so load with Qt
                    QImage img(tempFile.fileName());

                    if(img.isNull())
                        qWarning() << "Failed to load video thumbnail from temporary file";
                    else
                        return img.size();

                }

            }

        } catch(...) {
            qWarning() << "ffmpegthumbnail API failed";
        }

#endif

#ifdef Q_OS_LINUX

        // the temp image thumbnail path (incl random int)
        QTemporaryFile tmp_file;
        if(!tmp_file.open()) {
            qWarning() << "Failed to create temporary file";
            return QSize();
        }

        // release the file
        tmp_file.close();

        // create thumbnail using ffmpegthumbnailer, the -s0 makes it create a thumbnail at original size
        QProcess proc;
        int ret = proc.execute("ffmpegthumbnailer", QStringList() << "-i" << path << "-s0" << "-o" << tmp_file.fileName());

        if(ret != 0) {
            qWarning() << "ffmpegthumbnailer ended with error code" << ret << "- is it installed?";
            return QSize();
        }

        QImageReader reader(tmp_file.fileName());
        const QSize orig = reader.size();

        // store in return variable
        return orig;

#endif

    }

    qWarning() << "Unknown video thumbnailer used:" << PQCSettingsCPP::get().getFiletypesVideoThumbnailer();;
    return QSize();


}

const QImage PQCImagePluginVideo::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: requestedSize =" << requestedSize;

    if(PQCSettingsCPP::get().getFiletypesVideoThumbnailer() == "ffmpegthumbnailer") {

#ifdef PQMFFMPEGTHUMBNAILER

        try {

            ffmpegthumbnailer::VideoThumbnailer thumbnailer;

            thumbnailer.setThumbnailSize(requestedSize.width(), requestedSize.height());
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
                error += err % "\n";
                return QImage();
            }
            // release the file
            tempFile.close();

            thumbnailer.generateThumbnail(path.toStdString(), ThumbnailerImageType::Jpeg, tempFile.fileName().toStdString());

            // reopening the file is safe
            if(!tempFile.open()) {
                const QString err = "Unable to open temporary file from thumbnail generation.";
                qWarning() << err;
                error += err % "\n";
                return QImage();
            }

            // attempt to load file as simple image
            QImage ffmpegimg(tempFile.fileName());

            if(ffmpegimg.isNull())
                qWarning() << "Failed to load video thumbnail from temporary file";
            else {
                return ffmpegimg;
            }

        } catch(...) {
            qWarning() << "ffmpegthumbnailer API failed";
        }

#endif

#ifdef Q_OS_LINUX

        // the temp image thumbnail path (incl random int)
        QTemporaryFile tmp_file;
        if(!tmp_file.open()) {
            const QString msg = "Failed to create temporary file";
            qWarning() << msg;
            error += msg % "\n";
            return QImage();
        }

        // create thumbnail using ffmpegthumbnailer
        QProcess proc;
        int ret = proc.execute("ffmpegthumbnailer", QStringList() << "-i" << path << "-s0" << "-o" << tmp_file.fileName());

        // without this it seems like zombie ffmpeg processes might appear
        proc.kill();

        if(ret != 0) {
            const QString msg = QString("ffmpegthumbnailer ended with error code %1 - is it installed?").arg(ret);
            error += msg % "\n";
            qWarning() << msg;
            return QImage();
        }

        QImage img(tmp_file.fileName());

        origSize = img.size();

        // Scale image if necessary
        if(requestedSize.width() != -1) {
            img = img.scaled(origSize.scaled(requestedSize, Qt::KeepAspectRatio),
                             Qt::IgnoreAspectRatio,
                             (PQCSettingsCPP::get().getImageviewRescalingSmooth() ? Qt::SmoothTransformation : Qt::FastTransformation));
        }

        // store in return variable
        return img;

#endif

    } else if(PQCSettingsCPP::get().getFiletypesVideoThumbnailer() == "") {

        const QString msg = "No video thumbnailer selected";
        qWarning() << msg;
        error += msg % "\n";
        return QImage();

    }

    const QString msg = "Unknown video thumbnailer used: " + PQCSettingsCPP::get().getFiletypesVideoThumbnailer();
    qWarning() << msg;
    error += msg % "\n";
    return QImage();


}

const bool PQCImagePluginVideo::writeImage(QImage img, QString targetPath) {
    return false;
}
