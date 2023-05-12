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

import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "../../../elements"

PQSetting {
    id: set
    //: A settings title referring to the background of PhotoQt (behind any image/element)
    title: "OpenGL"
    helptext: em.pty+qsTranslate("settingsmanager_interface", "What OpenGL backend should be used (if available). A restart of PhotoQt is required for changes to take effect.")
    expertmodeonly: true
    content: [

        PQComboBox {
            id: ogl_type
            model: [
                "Auto",
                "OpenGLES",
                "SoftwareOpenGL",
                "DesktopOpenGL"
            ]
        }

    ]

    Connections {

        target: settingsmanager_top

        onCloseModalWindow:
            fileDialog.close()

        onLoadAllSettings: {
            var ogl = handlingExternal.getOpenGL()
            if(ogl == "opengles")
                ogl_type.currentIndex = 1
            else if(ogl == "softwareopengl")
                ogl_type.currentIndex = 2
            else if(ogl == "desktopopengl")
                ogl_type.currentIndex = 3
            else
                ogl_type.currentIndex = 0
        }

        onSaveAllSettings: {
            handlingExternal.setOpenGL(ogl_type.currentText.toLowerCase())
        }

    }

}
