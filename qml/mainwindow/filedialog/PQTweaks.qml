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
        handleToolTipPrefix: em.pty+qsTranslate("filedialog", "Zoom factor:") + " "

        anchors.left: zoomtext.right
        y: (parent.height-height)/2

        onValueChanged:
            settings.openZoomLevel = value

    }

    PQComboBox {

        id: sortby

        prefix: em.pty+qsTranslate("filedialog", "Sort by:") + " "

        model: [em.pty+qsTranslate("filedialog", "Name"),
                em.pty+qsTranslate("filedialog", "Natural Name"),
                em.pty+qsTranslate("filedialog", "Time modified"),
                em.pty+qsTranslate("filedialog", "File size"),
                em.pty+qsTranslate("filedialog", "File type"),
                "[" + em.pty+qsTranslate("filedialog", "reverse order") + "]"]
        lineBelowItem: 4

        anchors.right: allfiles.left
        anchors.rightMargin: 5
        y: (parent.height-height)/2

        tooltip: em.pty+qsTranslate("filedialog", "Choose by what to sort the files")
        tooltipFollowsMouse: false

        property int prevCurIndex: -1

        onCurrentIndexChanged: {
            if(currentIndex == 5) {
                settings.sortbyAscending = !settings.sortbyAscending
                currentIndex = prevCurIndex
            } else {
                settings.sortby = (currentIndex===0 ? "name" : (currentIndex===1 ? "naturalname" : (currentIndex===2 ? "time" : (currentIndex===3 ? "size" : "type"))))
                prevCurIndex = currentIndex
            }
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
        tooltipFollowsMouse: false

        imageButtonSource: settings.openDefaultView=="icons" ? "/filedialog/iconview.png" : "/filedialog/listview.png"

        onClicked:
            settings.openDefaultView = (settings.openDefaultView=="icons" ? "list" : "icons")

    }

}
