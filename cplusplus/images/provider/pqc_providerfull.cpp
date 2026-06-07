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

#include <pqc_providerfull.h>
#include <pqc_loadimage.h>
#include <pqc_imagehandler.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <scripts/pqc_scriptsimages.h>
#include <pqc_settings.h>
#include <QFileInfo>
#include <QApplication>
#include <QColorSpace>
#include <pqc_notify_cpp.h>
#include <pqc_helper.h>
#include <QPainter>

#ifdef PQMLCMS2
#include <lcms2.h>
#endif

PQCProviderFull::PQCProviderFull() : QQuickImageProvider(QQuickImageProvider::Image) {}

PQCProviderFull::~PQCProviderFull() {}

QImage PQCProviderFull::requestImage(const QString &url, QSize *origSize, const QSize &requestedSize) {

    QString filename = PQCScriptsFilesPaths::get().cleanPath(QByteArray::fromPercentEncoding(url.toUtf8()));

    QString filenameForChecking = PQCHelper::extractInsideFilename(filename);

    if(!QFileInfo::exists(filenameForChecking)) {
        QString err = QApplication::translate("imageprovider", "File failed to load, it does not exist!");
        qWarning() << "ERROR:" << err;
        qWarning() << "Filename:" << filenameForChecking;
        return QImage();
    }

    // Load image
    QString error = "";
    QImage ret = PQCImageHandler::get().getImage(filename, requestedSize, *origSize, error);

    // if returned image is not a valid image
    if(ret.isNull()) {

        if(error == "")
            error = "Unknown error\n";

        // get the widht of the text
        // this class assumes everything is a single line of text
        QFont ft = qApp->font();
        ft.setPointSize(30);
        QFontMetrics metrics(ft);
        // get the bounding rect and do a rough conversion to a string with line breaks
        QRect rect = metrics.boundingRect(error);
        const int lineCount = qMax(1,error.count("\n"));
        const int eH = qMin(1200, qMax(600, rect.height()/lineCount + (lineCount+5)*metrics.lineSpacing()+20))+300;
        const int eW = qMin(1500, qMax(rect.width()/lineCount+100, static_cast<int>(eH*1.25)));
        QImage img(eW, eH, QImage::Format_ARGB32_Premultiplied);
        img.fill(Qt::transparent);

        // get the sad face image
        QString err;
        QImage sadface = PQCImageHandler::get().getImageWithPlugin("qt", ":/other/sadface.svg", QSize(128,128), *origSize, err);

        // start constructing
        QPainter painter(&img);

        // first draw a slightly rounded dark rectangle in the background
        const QColor bgcol(0,0,0,175);
        painter.setPen(QPen(bgcol));
        painter.setBrush(bgcol);
        painter.drawRoundedRect(QRect(0,0,img.width(),img.height()), 20, 20);

        // draw the sad face image in the top center
        painter.drawImage((img.width()-sadface.width())/2, 50, sadface);

        // white text
        painter.setPen(QPen(Qt::white));
        ft = qApp->font();
        // title: large, bold
        ft.setPointSize(45);
        ft.setBold(true);
        painter.setFont(ft);
        painter.drawText(QRect(10,200,img.width()-20,100), Qt::AlignHCenter, "Image failed to load!");
        // error messages: smaller, non-bold
        ft.setPointSize(30);
        ft.setBold(false);
        painter.setFont(ft);
        painter.drawText(QRect(10,330,img.width()-20,img.height()-340), Qt::AlignHCenter, error);
        painter.end();

        return img;
    }

    // return scaled version
    if(requestedSize.width() > 2 && requestedSize.height() > 2 && origSize->width() > requestedSize.width() && origSize->height() > requestedSize.height())
        return ret.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    // return full version
    return ret;

}
