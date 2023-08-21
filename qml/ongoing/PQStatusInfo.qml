import QtQuick

import PQCFileFolderModel
import PQCScriptsFilesPaths

import "../elements"

Item {

    id: statusinfo_top

    x: 40
    y: 20

    Behavior on x { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 200 } }

    width: maincol.width
    height: maincol.height

    // possible values: counter, filename, filepathname, resolution, zoom, rotation
    property var info: PQCSettings.interfaceStatusInfoList

    Column {

        id: maincol

        Rectangle {

            color: PQCLook.transColor

            width: row.width+40
            height: row.height+20

            radius: 5

            Row {

                id: row

                x: 20
                y: 10

                spacing: 10

                Repeater {

                    model: PQCFileFolderModel.countMainView===0 ? 1 : info.length

                    Item {

                        width: childrenRect.width
                        height: childrenRect.height

                        Row {

                            spacing: 10

                            Loader {
                                id: ldr
                                property string t: info[index]
                                sourceComponent: PQCFileFolderModel.countMainView===0 ?
                                                   rectNoImages :
                                                   t=="counter" ?
                                                       rectCounter :
                                                       t=="filename" ?
                                                           rectFilename :
                                                           t=="filepathname" ?
                                                               rectFilepath :
                                                               t=="resolution" ?
                                                                   rectResolution :
                                                                   t=="zoom" ?
                                                                       rectZoom :
                                                                       t=="rotation" ?
                                                                           rectRotation :
                                                                           t=="filesize" ?
                                                                               rectFilesize :
                                                                               rectDummy
                            }

                            Rectangle {
                                height: ldr.height
                                width: 1
                                color: PQCLook.textColor
                                visible: index<info.length-1 && PQCFileFolderModel.countMainView>0
                            }

                        }

                    }

                }

            }

        }

    }

    Component {
        id: rectNoImages
        PQText {
            text: qsTranslate("statusinfo", "Click anywhere to open a file")
        }
    }

    Component {
        id: rectCounter
        PQText {
            text: (PQCFileFolderModel.currentIndex+1) + "/" + PQCFileFolderModel.countMainView
        }
    }

    Component {
        id: rectFilename
        PQText {
            text: PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile)
        }
    }

    Component {
        id: rectFilepath
        PQText {
            text: PQCFileFolderModel.currentFile
        }
    }

    Component {
        id: rectZoom
        PQText {
            text: Math.round(image.currentScale*100)+"%"
        }
    }

    Component {
        id: rectRotation
        PQText {
            text: (Math.round(image.currentRotation)%360+360)%360 + "°"
        }
    }

    Component {
        id: rectResolution
        Row {
            spacing: 2
            PQText {
                text: image.currentResolution.width
            }
            PQText {
                opacity: 0.7
                text: "x"
            }
            PQText {
                text: image.currentResolution.height
            }
        }
    }

    Component {
        id: rectFilesize
        PQText {
            text: PQCScriptsFilesPaths.getFileSizeHumanReadable(PQCFileFolderModel.currentFile)
        }
    }

    Component {
        id: rectDummy
        PQText {
            text: "[unknown]"
        }
    }

    PQMouseArea {
        anchors.fill: parent
        drag.target: PQCSettings.interfaceStatusInfoManageWindow ? undefined : parent
        hoverEnabled: true
        text: PQCSettings.interfaceStatusInfoManageWindow ?
                  qsTranslate("statusinfo", "Click and drag to move window around") :
                  qsTranslate("statusinfo", "Click and drag to move rectangle around")
        onWheel: (wheel) => {
            wheel.accepted = true
        }
        onPressed: {
            if(PQCSettings.interfaceStatusInfoManageWindow)
                toplevel.startSystemMove()
        }
        onDoubleClicked: {
            if(toplevel.visibility === Window.Maximized)
                toplevel.visibility = Window.Windowed
            else if(toplevel.visibility === Window.Windowed)
                toplevel.visibility = Window.Maximized
        }

}

}
