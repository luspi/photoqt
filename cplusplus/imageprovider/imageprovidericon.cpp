/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#include "imageprovidericon.h"
#include <QPainter>
#include <QSvgRenderer>

QImage PQImageProviderIcon::requestImage(const QString &icon, QSize *origSize, const QSize &requestedSize) {

    DBG << CURDATE << "PQImageProviderIcon::requestPixmap() " << NL
        << CURDATE << "** icon = " << icon.toStdString() << NL
        << CURDATE << "** requestedSize = " << requestedSize.width() << "x" << requestedSize.height() << NL;

    QSize use = requestedSize;

    if(use == QSize(-1,-1)) {
        use.setWidth(256);
        use.setHeight(256);
        origSize->setWidth(256);
        origSize->setHeight(256);
    } else {
        origSize->setWidth(requestedSize.width());
        origSize->setHeight(requestedSize.width());
    }

    QString suf = const_cast<QString&>(icon);

    if(suf.startsWith("::theme::")) {

        suf = suf.remove(0,9);

        // Attempt to load icon from current theme
        QIcon ico = QIcon::fromTheme(suf);
        QImage ret = QImage(ico.pixmap(use).toImage());

        // If icon is not available or if on Windows, choose from a small selection of custom provided icons
        // These backup icons are taken from the Breese-Dark icon theme, created by KDE/Plasma
        if(ret.isNull()) {
            LOG << CURDATE << "ImageProviderIcon: Icon not found in theme, using fallback icon: " << suf.toStdString() << NL;
            if(QFile(QString(":/filedialog/backupicons/%1.svg").arg(suf)).exists())
                return QIcon(QString(":/filedialog/backupicons/%1.svg").arg(suf)).pixmap(use).toImage();
            else if(suf.contains("folder") || suf.contains("directory"))
                return QIcon(":/filedialog/backupicons/folder.svg").pixmap(use).toImage();
            else if(suf.contains("image"))
                return QIcon(":/filedialog/backupicons/image.svg").pixmap(use).toImage();
            else
                return QIcon(":/filedialog/backupicons/unknown.svg").pixmap(use).toImage();
        }

        return ret;

    }

    QString iconname = "";
    if(QFile::exists(QString(":/filetypes/%1.svg").arg(suf.toLower())))
        iconname = QString(":/filetypes/%1.svg").arg(suf.toLower());
    else
        iconname = ":/filetypes/unknown.svg";

    QSvgRenderer svg;
    QImage ret;

    // Loading SVG file
    svg.load(iconname);

    // Invalid vector graphic
    if(!svg.isValid()) {
        LOG << CURDATE << "PQImageProviderIcon: reader svg - Error: invalid svg file" << NL;
        return ret;
    }

    // Render SVG into pixmap
    if(requestedSize.width() > 10 && requestedSize.height() > 10)
        ret = QImage(requestedSize, QImage::Format_ARGB32);
    else
        ret = QImage(512,512, QImage::Format_ARGB32);
    ret.fill(::Qt::transparent);
    QPainter painter(&ret);
    svg.render(&painter);
    painter.end();

    return ret;

}
