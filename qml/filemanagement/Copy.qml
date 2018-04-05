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

import QtQuick 2.5
import PFileDialog 1.0
import "../handlestuff.js" as Handle

Item {

    x: 0
    y: (container.height-height-110)/2
    width: container.width-110
    height: container.height

    Text {
        width: parent.width
        height: parent.height
        verticalAlignment: Qt.AlignVCenter
        horizontalAlignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        text: em.pty+qsTr("Use the file dialog to select a destination location.")
        color: colour.bg_label
        font.bold: true
        font.pointSize: 20
    }

    PFileDialog {
        id: filedialog
        onAccepted:
            copyFile(file)
        onRejected: {
            if(management_top.current === "cp")
                management_top.hide()
        }
    }

    Connections {
        target: container
        onItemShown:
            filedialog.getFilename(em.pty+qsTr("Copy Image to..."), variables.currentDir + "/" + variables.currentFileWithoutExtras)
        onItemHidden:
            filedialog.close()
    }

    function copyFile(file) {
        verboseMessage("FileManagement/Copy", "copyFile(): " + file)
        getanddostuff.copyImage(variables.currentDir + "/" + variables.currentFile, file)
        if(getanddostuff.removeFilenameFromPath(file) === variables.currentDir) {
            Handle.loadFile(file, variables.filter, true)
        }
        management_top.hide()
    }

}
