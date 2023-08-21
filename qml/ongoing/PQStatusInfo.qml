import QtQuick

import PQCFileFolderModel
import PQCScriptsFilesPaths

import "../elements"

Item {

    id: statusinfo_top

    x: addLeft + 40
    y: addTop + 20

    Behavior on x { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 200 } }

    width: 100
    height: 30

    property int addLeft: (PQCSettings.interfaceEdgeLeftAction==="mainmenu" && PQCSettings.metadataElementBehindLeftEdge) ?
                              (mainmenu.setVisible ? (mainmenu.width+mainmenu.gap) : 0) :
                              (PQCSettings.interfaceEdgeLeftAction==="metadata" ?
                                   (metadata.setVisible ? (metadata.width+metadata.gap) : 0) :
                                   0)

    property int addTop: PQCSettings.interfaceEdgeTopAction==="thumbnails" ?
                             (thumbnails.setVisible ? thumbnails.height : 0) :
                             0

    // possible values: counter, filename, filepathname, resolution, zoom, rotation
    property var info: PQCSettings.interfaceStatusInfoList

    Column {

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

                    model: info.length

                    Item {

                        width: childrenRect.width
                        height: childrenRect.height

                        Row {

                            spacing: 10

                            Loader {
                                id: ldr
                                property string t: info[index]
                                sourceComponent: t=="counter" ?
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
                                visible: index<info.length-1
                            }

                        }

                    }

                }

            }

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

}
