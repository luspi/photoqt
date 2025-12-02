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
#include <pqc_settingscpp.h>
#include <QIcon>
#include <QFile>
#include <QPainter>
#include <QSvgRenderer>

PQCProviderTheme::PQCProviderTheme() : QQuickImageProvider(QQuickImageProvider::Image) {
    svg = new PQCProviderSVG;
#ifndef Q_OS_WIN
    origTheme = QIcon::themeName();
    origFallbackTheme = QIcon::fallbackThemeName();
    // this is needed to 'fix' the icons on Linux
    if(PQCSettingsCPP::get().getGeneralInterfaceVariant() == "modern") {
        if(QColor(PQCSettingsCPP::get().getInterfaceAccentColor()).lightness() > 96)
            QIcon::setThemeName(QString("%1-light").arg(origTheme));
        else
            QIcon::setThemeName(QString("%1-dark").arg(origTheme));
        QIcon::setFallbackThemeName(origTheme);
    }
    connect(&PQCSettingsCPP::get(), &PQCSettingsCPP::interfaceAccentColorChanged, this, [=]() {
        if(PQCSettingsCPP::get().getGeneralInterfaceVariant() == "modern") {
            if(QColor(PQCSettingsCPP::get().getInterfaceAccentColor()).lightness() > 96)
                QIcon::setThemeName(QString("%1-light").arg(origTheme));
            else
                QIcon::setThemeName(QString("%1-dark").arg(origTheme));
            QIcon::setFallbackThemeName(origTheme);
        }
    });
#endif
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

    // some entries in the places xml file might use inode-directory for a folder icon
    // this should be the same icon but can with some themes result in the wrong icon
    // being returned for inode-directory. Thus we fix it in that case to 'folder' to
    // work around this issue.
    const QString suf = (icon == "inode-directory" ? "folder" : const_cast<QString&>(icon).toLower());

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
