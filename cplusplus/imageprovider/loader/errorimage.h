/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

#ifndef LOADIMAGE_ERROR_H
#define LOADIMAGE_ERROR_H

#include <QImage>
#include <QPainter>
#include <QPixmap>
#include <QTextDocument>
#include "../../logger.h"

class PQLoadImageErrorImage {

public:
    PQLoadImageErrorImage() {}

    QImage load(QString errormessage) {
        QPixmap pix(":/image/plainerrorimg.png");
        QPainter paint(&pix);
        QTextDocument txt;
        txt.setHtml("<center><div style=\"text-align: center; font-size: 12pt; font-wight: bold; color: white; background: none;\">" +
                    QString("<b>ERROR LOADING IMAGE</b><br><br><bR>%1</div></center>").arg(errormessage));
        paint.translate(100,150);
        txt.setTextWidth(440);
        txt.drawContents(&paint);
        paint.end();
        QImage pix2img = pix.toImage();
        pix2img.setText("error", "error");
        pix2img.setText("", "error");
        return pix2img;
    }

};

#endif // LOADIMAGE_ERROR_H
