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
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: filedialog_window

    width: 1024
    height: 768

    minimumWidth: 800
    minimumHeight: 600

    modality: PQSettings.openPopoutElementKeepOpen ? Qt.NonModal : Qt.ApplicationModal

    color: "#88000000"

    Loader {
        source: "PQFileDialog.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return filedialog_window.width })
                item.parentHeight = Qt.binding(function() { return filedialog_window.height })
            }
    }

    onClosing: {

//        filedialog_window.
        windowgeometry.fileDialogWindowMaximized = (filedialog_window.visibility==Window.Maximized)
        windowgeometry.fileDialogWindowGeometry = Qt.rect(filedialog_window.x, filedialog_window.y, filedialog_window.width, filedialog_window.height)

        if(variables.visibleItem == "filedialog")
            variables.visibleItem = ""
    }

    Component.onCompleted:  {

        if(windowgeometry.fileDialogWindowMaximized)

            filedialog_window.visibility = Window.Maximized

        else {

            filedialog_window.setX(windowgeometry.fileDialogWindowGeometry.x)
            filedialog_window.setY(windowgeometry.fileDialogWindowGeometry.y)
            filedialog_window.setWidth(windowgeometry.fileDialogWindowGeometry.width)
            filedialog_window.setHeight(windowgeometry.fileDialogWindowGeometry.height)

        }

    }

}
