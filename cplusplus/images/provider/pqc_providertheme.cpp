/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

#include <pqc_providertheme.h>
#include <pqc_providersvg.h>
#include <QIcon>
#include <QFile>
#include <QPainter>
#include <QSvgRenderer>

PQCProviderTheme::PQCProviderTheme() : QQuickImageProvider(QQuickImageProvider::Image) {
    svg = new PQCProviderSVG;
}

PQCProviderTheme::~PQCProviderTheme() {
    svg = new PQCProviderSVG;
}

QImage PQCProviderTheme::requestImage(const QString &icon, QSize *origSize, const QSize &requestedSize) {

    QSize use = requestedSize;

    if(!use.isValid()) {
        use.setWidth(512);
        use.setHeight(512);
        origSize->setWidth(512);
        origSize->setHeight(512);
    } else {
        origSize->setWidth(requestedSize.width());
        origSize->setHeight(requestedSize.width());
    }

    const QString suf = const_cast<QString&>(icon).toLower();

    QImage ret;

#ifndef Q_OS_WIN
    // Attempt to load icon from current theme
    QIcon ico = QIcon::fromTheme(suf);
    ret = QImage(ico.pixmap(use).toImage());
#endif

    if(ret.isNull()) {
        qDebug() << "Icon not found in theme, using fallback icon:" << suf;

        QString iconname = ":/filetypes/unknown.svg";

        if(suf != "folder" && QFile(QString(":/filetypes/%1.svg").arg(suf)).exists())
            iconname = QString(":/filetypes/%1.svg").arg(suf);
        else if(QFile(QString(":/other/filedialog-%1.svg").arg(suf)).exists())
            iconname = QString(":/other/filedialog-%1.svg").arg(suf);
        else if(suf.contains("folder") || suf.contains("directory"))
            iconname = QString(":/other/filedialog-folder.svg");

        return svg->requestImage(iconname, origSize, requestedSize);

    }

    return ret;

}
