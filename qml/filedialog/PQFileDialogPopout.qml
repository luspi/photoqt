import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "./filedialog"
import "../elements"

Window {

    id: filedialog_window

    width: 1024
    height: 768

    minimumWidth: 800
    minimumHeight: 600

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
