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

#include "imageprovidericon.h"
#include <QPainter>

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


    // get filetype icon
    if(icon.startsWith("IMAGE////")) {

        QString i = const_cast<QString&>(icon);
        QString suf = i.remove(0,9);

        bool fixed = false;
        if(suf.startsWith("::fixedsize::")) {
            suf = suf.remove(0,13);
            fixed = true;
        }

        QImage ret;

        if(QFile::exists(QString(":/filetypes/%1.ico").arg(suf.toLower())))
            ret = QImage(QString(":/filetypes/%1.ico").arg(suf.toLower()));
        else
            ret = QImage(":/filetypes/unknown.ico");

        if(fixed) {

            QImage fix(266, 266, QImage::Format_ARGB32);
            fix.fill(qRgba(255,255,255,8));
            QPainter painter(&fix);
            ret = ret.scaled(256,256,Qt::KeepAspectRatio);
            painter.drawImage((266-ret.width())/2, (266-ret.height())/2, ret);
            painter.setPen(qRgba(255,255,255,175));
            painter.drawLine(0, 265, 266, 265);
            painter.end();

            return fix;

        } else
            return ret;

    }

    // Attempt to load icon from current theme
    QIcon ico = QIcon::fromTheme(icon);
    QImage ret = QImage(ico.pixmap(use).toImage());

    // If icon is not available or if on Windows, choose from a small selection of custom provided icons
    // These backup icons are taken from the Breese-Dark icon theme, created by KDE/Plasma
    if(ret.isNull()) {
        LOG << CURDATE << "ImageProviderIcon: Icon not found in theme, using fallback icon: " << icon.toStdString() << NL;
        if(QFile(QString(":/filedialog/backupicons/%1.svg").arg(icon)).exists())
            return QIcon(QString(":/filedialog/backupicons/%1.svg").arg(icon)).pixmap(use).toImage();
        else if(icon.contains("folder") || icon.contains("directory"))
            return QIcon(":/filedialog/backupicons/folder.svg").pixmap(use).toImage();
        else if(icon.contains("image"))
            return QIcon(":/filedialog/backupicons/image.svg").pixmap(use).toImage();
        else
            return QIcon(":/filedialog/backupicons/unknown.svg").pixmap(use).toImage();
    }

    return ret;

}
