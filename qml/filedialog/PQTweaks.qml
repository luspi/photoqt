import QtQuick
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
        border.color: PQCLook.baseColorContrast
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
                PQToolTip {
                    anchors.fill: parent
                    text: qsTranslate("filedialog", "Adjust size of files and folders")
                }
            }

            PQSlider {

                id: zoomslider

                y: (parent.height-height)/2

                from: 1
                to: 100
                value: 50

                stepSize: 1
                wheelStepSize: 1

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
                filedialog_top.hide()
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
            }

            PQComboBox {
                y: (parent.height-height)/2
                firstItemEmphasized: true
                lineBelowItem: [0,7]

                model: [qsTranslate("filedialog", "All supported images"),
                        "Qt",
                        (PQCScriptsConfig.isImageMagickSupportEnabled() ? "ImageMagick" : "GraphicsMagick"),
                        "LibRaw", "DevIL",
                        "FreeImage", "PDF (Poppler)",
                        qsTranslate("filedialog", "Video files"),
                        qsTranslate("filedialog", "All files")]

            }

        }

    }

    Rectangle {
        y: 0
        width: parent.width
        height: 1
        color: PQCLook.baseColorContrast
    }

}
