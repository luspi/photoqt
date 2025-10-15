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

#include <pqc_providericon.h>
#include <pqc_providersvg.h>
#include <QIcon>
#include <QFile>
#include <QPainter>
#include <QSvgRenderer>

PQCProviderIcon::PQCProviderIcon() : QQuickImageProvider(QQuickImageProvider::Image) {
    svg = new PQCProviderSVG;
}

PQCProviderIcon::~PQCProviderIcon() {
    svg = new PQCProviderSVG;
}

QImage PQCProviderIcon::requestImage(const QString &icon, QSize *origSize, const QSize &requestedSize) {

    QSize use = requestedSize;

    if(use == QSize(-1,-1)) {
        use.setWidth(512);
        use.setHeight(512);
        origSize->setWidth(512);
        origSize->setHeight(512);
    } else {
        origSize->setWidth(requestedSize.width());
        origSize->setHeight(requestedSize.width());
    }

    const QString suf = const_cast<QString&>(icon);

    QString iconname = ":/filetypes/unknown.svg";
    if(suf.startsWith("network_"))
        iconname = ":/filetypes/network_unknown.svg";
    if(QFile::exists(QString(":/filetypes/%1.svg").arg(suf.toLower())))
        iconname = QString(":/filetypes/%1.svg").arg(suf.toLower());
    else if(suf.contains(".")) {
        const QString suf2 = (suf.startsWith("network_") ? "network_" : "") + suf.split(".").last();
        if(QFile::exists(QString(":/filetypes/%1.svg").arg(suf2.toLower())))
            iconname = QString(":/filetypes/%1.svg").arg(suf2.toLower());
    }

    return svg->requestImage(iconname, origSize, requestedSize);

}
