import QtQuick

import PQCImageFormats
import PQCFileFolderModel
import PQCScriptsConfig

import "../elements"

Item {

    id: tweaks_top

    width: parent.width
    height: 50

    property int zoomMoveUpHeight: leftcolrect.state==="moveup" ? leftcolrect.height : 0

    Rectangle {

        id: leftcolrect

        y: 0
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutElastic } }

        width: leftcol.width+15
        height: parent.height

        color: PQCLook.baseColor
        border.color: PQCLook.baseColorActive
        border.width: state==="moveup" ? 1 : 0

        Row {

            id: leftcol
            x: 5
            y: (parent.height-height)/2

            spacing: 5

            PQText {
                y: (parent.height-height)/2
                text: qsTranslate("filedialog", "Zoom:")
                font.weight: PQCLook.fontWeightBold
                PQMouseArea {
                    anchors.fill: parent
                    text: qsTranslate("filedialog", "Adjust size of files and folders")
                }
            }

            PQSlider {

                id: zoomslider

                y: (parent.height-height)/2

                from: 1
                to: 100

                stepSize: 1
                wheelStepSize: 1

                value: PQCSettings.filedialogZoom
                onValueChanged:
                    PQCSettings.filedialogZoom = value

            }

            PQText {
                y: (parent.height-height)/2
                text: zoomslider.value + "%"
            }

        }

        Connections {
            target: tweaks_top
            function onWidthChanged() {
                if(tweaks_top.width < (rightcol.width+leftcol.width+cancelbutton.width+50))
                    leftcolrect.state   = "moveup"
                else
                    leftcolrect.state = "movedown"
            }
        }

        states: [
            State {
                name: "moveup"
                PropertyChanges {
                    target: leftcolrect
                    y: -height+1
                }
            },
            State {
                name: "movedown"
                PropertyChanges {
                    target: leftcolrect
                    y: 0
                }
            }
        ]

    }

    Item {
        anchors.left: parent.left
        anchors.right: rightcol.parent.left
        anchors.leftMargin: leftcolrect.state==="moveup" ? 0 : (leftcol.width+leftcol.x)
        Behavior on anchors.leftMargin { NumberAnimation { duration: 200; easing.type: Easing.OutBounce } }
        height: parent.height

        PQButtonElement {
            id: cancelbutton
            height: parent.height
            anchors.centerIn: parent
            text: genericStringCancel
            tooltip: qsTranslate("filedialog", "Cancel and close")
            onClicked:
                filedialog_top.hideFileDialog()
        }
    }

    Item {

        x: parent.width-width-5
        width: rightcol.width
        height: parent.height

        Row {

            id: rightcol
            y: (parent.height-height)/2
            spacing: 5

            PQComboBox {
                y: (parent.height-height)/2
                lineBelowItem: [4]

                prefix: qsTranslate("filedialog", "Sort by:") + " "

                model: [qsTranslate("filedialog", "Name"),
                        qsTranslate("filedialog", "Natural Name"),
                        qsTranslate("filedialog", "Time modified"),
                        qsTranslate("filedialog", "File size"),
                        qsTranslate("filedialog", "File type"),
                        "[" + qsTranslate("filedialog", "reverse order") + "]"]

                Component.onCompleted: {
                    setCurrentIndex()
                }

                // this hack is needed as at startup the currentIndex gets set to 0 and its changed signal gets triggered
                property bool delayAfterSetup: false
                Timer {
                    running: true
                    interval: 200
                    onTriggered:
                        parent.delayAfterSetup = true
                }

                onCurrentIndexChanged: {
                    if(!delayAfterSetup) return
                    if(currentIndex === 0)
                        PQCSettings.imageviewSortImagesBy = "name"
                    else if(currentIndex === 1)
                        PQCSettings.imageviewSortImagesBy = "naturalname"
                    else if(currentIndex === 2)
                        PQCSettings.imageviewSortImagesBy = "time"
                    else if(currentIndex === 3)
                        PQCSettings.imageviewSortImagesBy = "size"
                    else if(currentIndex === 4)
                        PQCSettings.imageviewSortImagesBy = "type"
                    else if(currentIndex === 5) {
                        PQCSettings.imageviewSortImagesAscending = !PQCSettings.imageviewSortImagesAscending
                        setCurrentIndex()
                    }
                }

                function setCurrentIndex() {
                    var sortby = PQCSettings.imageviewSortImagesBy
                    if(sortby === "name")
                        currentIndex = 0
                    else if(sortby === "naturalname")
                        currentIndex = 1
                    else if(sortby === "time")
                        currentIndex = 2
                    else if(sortby === "size")
                        currentIndex = 3
                    else if(sortby === "type")
                        currentIndex = 4
                }

            }

            PQComboBox {
                y: (parent.height-height)/2
                firstItemEmphasized: true
                lineBelowItem: [0,7]

                model: [qsTranslate("filedialog", "All supported images"),
                        "Qt",
                        (PQCScriptsConfig.isImageMagickSupportEnabled() ? "ImageMagick" : "GraphicsMagick"),
                        "LibRaw", "DevIL",
                        "FreeImage", "PDF",
                        qsTranslate("filedialog", "Video files"),
                        qsTranslate("filedialog", "All files")]

                onCurrentIndexChanged: {
                    if(currentIndex === 0) {
                        PQCFileFolderModel.restrictToSuffixes = PQCImageFormats.getEnabledFormats()
                        PQCFileFolderModel.restrictToMimeTypes = PQCImageFormats.getEnabledMimeTypes()
                    } else if(currentIndex === 1) {
                        PQCFileFolderModel.restrictToSuffixes = PQCImageFormats.getEnabledFormatsQt()
                        PQCFileFolderModel.restrictToMimeTypes = PQCImageFormats.getEnabledMimeTypesQt()
                    } else if(currentIndex === 2) {
                        PQCFileFolderModel.restrictToSuffixes = PQCImageFormats.getEnabledFormatsMagick()
                        PQCFileFolderModel.restrictToMimeTypes = PQCImageFormats.getEnabledMimeTypesMagick()
                    } else if(currentIndex === 3) {
                        PQCFileFolderModel.restrictToSuffixes = PQCImageFormats.getEnabledFormatsLibRaw()
                        PQCFileFolderModel.restrictToMimeTypes = PQCImageFormats.getEnabledMimeTypesLibRaw()
                    } else if(currentIndex === 4) {
                        PQCFileFolderModel.restrictToSuffixes = PQCImageFormats.getEnabledFormatsDevIL()
                        PQCFileFolderModel.restrictToMimeTypes = PQCImageFormats.getEnabledMimeTypesDevIL()
                    } else if(currentIndex === 5) {
                        PQCFileFolderModel.restrictToSuffixes = PQCImageFormats.getEnabledFormatsFreeImage()
                        PQCFileFolderModel.restrictToMimeTypes = PQCImageFormats.getEnabledMimeTypesFreeImage()
                    } else if(currentIndex === 6) {
                        PQCFileFolderModel.restrictToSuffixes = PQCImageFormats.getEnabledFormatsPoppler()
                        PQCFileFolderModel.restrictToMimeTypes = PQCImageFormats.getEnabledMimeTypesPoppler()
                    } else if(currentIndex === 7) {
                        PQCFileFolderModel.restrictToSuffixes = PQCImageFormats.getEnabledFormatsVideo()
                        PQCFileFolderModel.restrictToMimeTypes = PQCImageFormats.getEnabledMimeTypesVideo()
                    } else if(currentIndex === 8) {
                        PQCFileFolderModel.restrictToSuffixes = []
                        PQCFileFolderModel.restrictToMimeTypes = []
                    }
                }

            }

        }

    }

    Rectangle {
        y: 0
        width: parent.width
        height: 1
        color: PQCLook.baseColorActive
    }

}
