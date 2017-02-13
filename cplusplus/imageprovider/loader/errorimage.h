/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef LOADIMAGE_ERROR_H
#define LOADIMAGE_ERROR_H

#include <QImage>
#include <QPainter>
#include <QPixmap>
#include <QTextDocument>
#include "../../logger.h"

class ErrorImage {

public:

    static QImage load(QString errormessage) {
        QPixmap pix(":/img/plainerrorimg.png");
        QPainter paint(&pix);
        QTextDocument txt;
        txt.setHtml(QString("<center><div style=\"text-align: center; font-size: 12pt; font-wight: bold; color: white; background: none;\"><b>ERROR LOADING IMAGE</b><br><br><bR>%1</div></center>").arg(errormessage));
        paint.translate(100,150);
        txt.setTextWidth(440);
        txt.drawContents(&paint);
        paint.end();
        return pix.toImage();
    }

};

#endif // LOADIMAGE_ERROR_H
