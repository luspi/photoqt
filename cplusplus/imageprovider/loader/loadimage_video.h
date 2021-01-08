/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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
#include <QPixmap>
#include <QPainter>

#include "../../logger.h"
#include "../../settings/settings.h"

class PQLoadImageVideo {

public:
    PQLoadImageVideo() {
        errormsg = "";
    }

    QImage load(QString filename, QSize maxSize, QSize *) {

        errormsg = "";

        if(PQSettings::get().getVideoThumbnailer() == "ffmpegthumbnailer") {

            // the temp image thumbnail path (incl random int)
            QString tmp_path = QString("%1/photoqt_videothumb_%2.jpg").arg(QDir::tempPath()).arg(rand());

            // create thumbnail using ffmpegthumbnailer
            QProcess proc;
            proc.execute("ffmpegthumbnailer", QStringList() << "-i" << filename << "-s" << QString::number(maxSize.width()) << "-o" << tmp_path);

            // thumbnail and film border pixmap
            QPixmap thumb_tmp(tmp_path);
            QPixmap thumb(thumb_tmp.width()+40, thumb_tmp.height());
            QPixmap border(":/image/filmborder.png");

            // create painter (part opaque)
            QPainter paint(&thumb);

            // add border left and right of thumbnail
            paint.drawPixmap(QRectF(20, 0, thumb_tmp.width(), thumb.height()), thumb_tmp, QRectF(0, 0, thumb_tmp.width(), thumb_tmp.height()));
            paint.drawPixmap(QRectF(0, 0, 20, thumb.height()), border, QRectF(0, 0, border.width(), border.height()));
            paint.drawPixmap(QRectF(thumb.width()-20, 0, 20, thumb.height()), border, QRectF(0, 0, border.width(), border.height()));

            // done
            paint.end();

            // remove temporary thumbnail file
            QFile file(tmp_path);
            file.remove();

            // store in return variable
            return thumb.toImage();

        } else if(PQSettings::get().getVideoThumbnailer() == "") {

            QImage img(":/image/genericvideothumb.png");
            errormsg = "x";
            return img.scaledToWidth(maxSize.width());

        }

        errormsg = "Unknown video thumbnailer used: " + PQSettings::get().getVideoThumbnailer();
        LOG << CURDATE << "PQLoadImageVideo::load(): " << errormsg.toStdString() << NL;
        return QImage();

    }

    QString errormsg;

};

#endif // PQLOADIMAGEVIDEO_H
