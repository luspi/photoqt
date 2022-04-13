/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#include "loadimage_video.h"

PQLoadImageVideo::PQLoadImageVideo() {
    errormsg = "";
}

QSize PQLoadImageVideo::loadSize(QString filename) {

#ifdef Q_OS_LINUX

    if(PQSettings::get()["filetypesVideoThumbnailer"].toString() == "ffmpegthumbnailer") {

        // the temp image thumbnail path (incl random int)
        QString tmp_path = QString("%1/photoqt_videothumb_%2.jpg").arg(QDir::tempPath()).arg(rand());

        // create thumbnail using ffmpegthumbnailer, the -s0 makes it create a thumbnail at original size
        QProcess proc;
        int ret = proc.execute("ffmpegthumbnailer", QStringList() << "-i" << filename << "-s0" << "-o" << tmp_path);

        if(ret != 0) {
            LOG << CURDATE << "PQLoadImageVideo::loadSize(): ffmpegthumbnailer ended with error code " << ret << " - is it installed?" << NL;
            return QSize();
        }

        QImage thumb(tmp_path);

        // remove temporary thumbnail file
        QFile::remove(tmp_path);

        // store in return variable
        return thumb.size();

    } else if(PQSettings::get()["filetypesVideoThumbnailer"].toString() == "") {

#endif

        return QSize();

#ifdef Q_OS_LINUX

    }

    errormsg = "Unknown video thumbnailer used: " + PQSettings::get()["filetypesVideoThumbnailer"].toString();
    LOG << CURDATE << "PQLoadImageVideo::loadSize(): " << errormsg.toStdString() << NL;
    return QSize();

#endif

}

QImage PQLoadImageVideo::load(QString filename, QSize maxSize, QSize &origSize) {

    errormsg = "";

#ifdef Q_OS_LINUX

    if(PQSettings::get()["filetypesVideoThumbnailer"].toString() == "ffmpegthumbnailer") {

        // the temp image thumbnail path (incl random int)
        QString tmp_path = QString("%1/photoqt_videothumb_%2.jpg").arg(QDir::tempPath()).arg(rand());

        // create thumbnail using ffmpegthumbnailer
        QProcess proc;
        int ret = proc.execute("ffmpegthumbnailer", QStringList() << "-i" << filename << "-s0" << "-o" << tmp_path);

        if(ret != 0) {
            LOG << CURDATE << "PQLoadImageVideo: ffmpegthumbnailer ended with error code " << ret << " - is it installed?" << NL;
            QImage img(":/image/genericvideothumb.png");
            return img.scaledToWidth(maxSize.width());
        }

        QImage thumb(tmp_path);

        origSize = thumb.size();

        // remove temporary thumbnail file
        QFile::remove(tmp_path);

        // store in return variable
        return thumb;

    } else if(PQSettings::get()["filetypesVideoThumbnailer"].toString() == "") {

#endif

        QImage img(":/image/genericvideothumb.png");
        return img.scaledToWidth(maxSize.width());

#ifdef Q_OS_LINUX

    }

    errormsg = "Unknown video thumbnailer used: " + PQSettings::get()["filetypesVideoThumbnailer"].toString();
    LOG << CURDATE << "PQLoadImageVideo::load(): " << errormsg.toStdString() << NL;
    return QImage();

#endif

}
