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

#ifndef PQLOADIMAGEVIDEO_H
#define PQLOADIMAGEVIDEO_H

#include <QImage>
#include <QProcess>

#include "../../logger.h"
#include "../../settings/settings.h"

class PQLoadImageVideo {

public:
    PQLoadImageVideo() {
        errormsg = "";
    }

    QImage load(QString filename, QSize maxSize, QSize *) {

        errormsg = "";

#ifdef Q_OS_LINUX

        if(PQSettings::get()["filetypesVideoThumbnailer"].toString() == "ffmpegthumbnailer") {

            // the temp image thumbnail path (incl random int)
            QString tmp_path = QString("%1/photoqt_videothumb_%2.jpg").arg(QDir::tempPath()).arg(rand());

            // create thumbnail using ffmpegthumbnailer
            QProcess proc;
            int ret = proc.execute("ffmpegthumbnailer", QStringList() << "-i" << filename << "-s" << QString::number(maxSize.width()) << "-o" << tmp_path);

            if(ret != 0) {
                LOG << CURDATE << "PQLoadImageVideo: ffmpegthumbnailer ended with error code " << ret << " - is it installed?" << NL;
                QImage img(":/image/genericvideothumb.png");
                return img.scaledToWidth(maxSize.width());
            }

            QImage thumb(tmp_path);

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

    QString errormsg;

};

#endif // PQLOADIMAGEVIDEO_H
