import QtQuick 2.9

import "../../elements"

Rectangle {

    color: "transparent"

    height: 50

    property alias showWhichFileTypeIndex: allfiles.currentIndex
    property alias allFileTypes: allfiles.allfiletypes

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

    PQComboBox {

        id: sortby

        prefix: "Sort by: "

        model: ["Name", "Name (reversed)", "Time", "Time (reversed)", "File size", "File size (reversed)", "File type", "File type (reversed)"]

        anchors.right: allfiles.left
        anchors.rightMargin: 5
        y: (parent.height-height)/2

        tooltip: em.pty+qsTranslate("filedialog", "Choose by what to sort the files")
        tooltipFollowsMouse: false

        onCurrentIndexChanged: {
            // round() always rounds to nearest integer -> .../2 always gives .0 or .5, thus doing -0.1 will work as intended
            var currentIndexDiv2 = Math.round(currentIndex/2 - 0.1)
            settings.sortbyAscending = (currentIndex%2==0)
            settings.sortby = (currentIndexDiv2===0 ? "name" : (currentIndexDiv2===1 ? "time" : (currentIndexDiv2===2 ? "size" : "type")))
        }

    }

    PQComboBox {

        id: allfiles

        model: []

        anchors.right: whichview.left
        anchors.rightMargin: 10
        y: (parent.height-height)/2

        tooltip: em.pty+qsTranslate("filedialog", "Choose which selection of files to show")
        tooltipFollowsMouse: false

        firstItemEmphasized: true

        property var allfiletypes: []

        Component.onCompleted: {
            var m = []
            m.push(em.pty+qsTranslate("filedialog", "All supported images"))
            allfiletypes.push("all")
            m.push("Qt")
            allfiletypes.push("qt")
            if(handlingGeneral.isGraphicsMagickSupportEnabled()) {
                m.push("GraphicsMagick")
                allfiletypes.push("gm")
            }
            if(handlingGeneral.isLibRawSupportEnabled()) {
                m.push("LibRaw")
                allfiletypes.push("raw")
            }
            if(handlingGeneral.isDevILSupportEnabled()) {
                m.push("DevIL")
                allfiletypes.push("devil")
            }
            if(handlingGeneral.isFreeImageSupportEnabled()) {
                m.push("FreeImage")
                allfiletypes.push("freeimage")
            }
            if(handlingGeneral.isPopplerSupportEnabled()) {
                m.push("PDF (Poppler)")
                allfiletypes.push("poppler")
            }
            allfiles.lineBelowItem = allfiletypes.length-1
            m.push(em.pty+qsTranslate("filedialog", "All files"))
            allfiletypes.push("allfiles")
            model = m
        }

    }

    PQButton {

        id: whichview

        anchors.right: parent.right
        anchors.rightMargin: 10
        y: (parent.height-height)/2

        tooltip: em.pty+qsTranslate("filedialog", "Switch between list and icon view")

        imageButtonSource: settings.openDefaultView=="icons" ? "/filedialog/iconview.png" : "/filedialog/listview.png"

        onClicked:
            settings.openDefaultView = (settings.openDefaultView=="icons" ? "list" : "icons")

    }

}
