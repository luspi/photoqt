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

#include "imageprovidericon.h"

QPixmap ImageProviderIcon::requestPixmap(const QString &icon, QSize *, const QSize &requestedSize) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "ImageProviderIcon: Attempting to load icon from theme: " << icon.toStdString() << NL;

    QSize use = requestedSize;

    if(use == QSize(-1,-1)) {
        use.setWidth(300);
        use.setHeight(300);
    }

    // Attempt to load icon from current theme
    QIcon ret;
    ret = ret.fromTheme(icon);

    // If icon is not available or if on Windows, choose from a small selection of custom provided icons
    // These backup icons are taken from the Breese-Dark icon theme, created by KDE/Plasma
    if(ret.isNull()) {
        if(qgetenv("PHOTOQT_DEBUG") == "yes")
            LOG << CURDATE << "ImageProviderIcon: Icon not found in theme, using fallback icon: " << icon.toStdString() << NL;
        if(QFile(":/img/openfile/backupicons/" + icon + ".svg").exists())
            ret = QIcon(":/img/openfile/backupicons/" + icon + ".svg");
        else if(icon.contains("folder") || icon.contains("directory"))
            ret = QIcon(":/img/openfile/backupicons/folder.svg");
        else if(icon.contains("image"))
            ret = QIcon(":/img/openfile/backupicons/image.svg");
        else
            ret = QIcon(":/img/openfile/backupicons/unknown.svg");
    }

    return QPixmap(ret.pixmap(use));

}
