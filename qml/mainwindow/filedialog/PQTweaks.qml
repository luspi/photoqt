import QtQuick 2.9

import "../../elements"

Rectangle {

    color: "transparent"

    height: 50

    property alias showallfiles: allfiles.checked

    Rectangle {
        x: 0
        width: parent.width
        y: 0
        height: 1
        color: "#aaaaaa"
    }

    Text {

        id: zoomtext

        color: "white"
        text: em.pty+qsTranslate("filedialog", "Zoom:")
        anchors.left: parent.left
        anchors.leftMargin: 5
        y: (parent.height-height)/2

        PQMouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            tooltip: em.pty+qsTranslate("filedialog", "Adjust font size of files and folders")
            tooltipFollowsMouse: false
        }

    }

    PQSlider {

        id: zoom

        from: 10
        to: 50
        value: settings.openZoomLevel

        divideToolTipValue: 10
        tooltip: em.pty+qsTranslate("filedialog", "Adjust font size of files and folders")
        handleToolTipPrefix: qsTranslate("filedialog", "Zoom factor:") + " "

        anchors.left: zoomtext.right
        y: (parent.height-height)/2

        onValueChanged:
            settings.openZoomLevel = value

    }

    PQCheckbox {

        id: thumb

        text: em.pty+qsTranslate("filedialog", "Thumbnails")

        tooltip: checked ? em.pty+qsTranslate("filedialog", "Click to hide thumbnails") : em.pty+qsTranslate("filedialog", "Click to show thumbnails")
        tooltipFollowsMouse: false

        anchors.right: preview.left
        y: (parent.height-height)/2

        checked: settings.openThumbnails

        onCheckedChanged:
            settings.openThumbnails = checked

    }

    PQCheckbox {

        id: preview

        text: "Preview"

        tooltip: checked ? em.pty+qsTranslate("filedialog", "Click to disable preview") : em.pty+qsTranslate("filedialog", "Click to enable preview")
        tooltipFollowsMouse: false

        anchors.right: allfiles.left
        y: (parent.height-height)/2

        checked: settings.openPreview

        onCheckedChanged:
            settings.openPreview = checked

    }

    PQCheckbox {

        id: allfiles

        text: em.pty+qsTranslate("filedialog", "All Files")
        tooltipFollowsMouse: false

        tooltip: checked ? em.pty+qsTranslate("filedialog", "Click to show only supported images") : em.pty+qsTranslate("filedialog", "Click to show all files")

        anchors.right: iconview.left
        y: (parent.height-height)/2

    }

    PQButton {

        id: iconview

        imageButtonSource: "/filedialog/iconview.png"
        imageOpacity: (settings.openDefaultView=="icons") ? 1 : 0.3

        tooltip: em.pty+qsTranslate("filedialog", "Show folders and files in a grid")
        tooltipFollowsMouse: false

        height: parent.height-10
        width: height

        anchors.right: listview.left
        y: (parent.height-height)/2

        onClicked:
            settings.openDefaultView="icons"

    }

    PQButton {

        id: listview

        imageButtonSource: "/filedialog/listview.png"
        imageOpacity: (settings.openDefaultView=="list") ? 1 : 0.3

        tooltip: em.pty+qsTranslate("filedialog", "Show folders and files in a list")
        tooltipFollowsMouse: false

        height: parent.height-10
        width: height

        anchors.right: parent.right
        y: (parent.height-height)/2

        onClicked:
            settings.openDefaultView="list"

    }

}
