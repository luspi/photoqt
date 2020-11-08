/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

import QtQuick 2.9

PQFileTypeTile {

    title: "Qt plugins"

    available: PQImageFormats.getAvailableEndingsWithDescriptionQt()
    defaultEnabled: PQImageFormats.getDefaultEnabledEndingsQt()
    currentlyEnabled: PQImageFormats.enabledFileformatsQt
    projectWebpage: ["qt", "https://doc.qt.io/qt-5/qtimageformats-index.html",
                     "kde", "https://api.kde.org/frameworks/kimageformats/html/index.html",
                     "libqpsd", "https://github.com/roniemartinez/libqpsd",
                     "avif", "https://github.com/novomesk/qt-avif-image-plugin"]
    description: em.pty+qsTranslate("settingsmanager_filetypes", "These are all the image formats either natively supported by Qt or through an image formats plugins:") + " <b>qt5-imageformats, kimageformats, libqpsd, avif</b>"

    iconsource: "/settingsmanager/filetypes/qt.png"

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            resetChecked()
        }

        onSaveAllSettings: {
            var c = []
            for(var key in checkedItems) {
                if(checkedItems[key])
                    c.push(key)
            }
            PQImageFormats.enabledFileformatsQt = c
        }

    }

    Component.onCompleted: {
        resetChecked()
    }
}
