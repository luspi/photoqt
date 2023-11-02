import QtQuick
import QtQuick.Controls

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - metadataFilename
// - metadataFileType
// - metadataFileSize
// - metadataImageNumber
// - metadataCopyright
// - metadataDimensions
// - metadataExposureTime
// - metadataFlash
// - metadataFLength
// - metadataFNumber
// - metadataGps
// - metadataIso
// - metadataKeywords
// - metadataLightSource
// - metadataLocation
// - metadataMake
// - metadataModel
// - metadataSceneType
// - metadataSoftware
// - metadataTime

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false

    ScrollBar.vertical: PQVerticalScrollBar {}

                          //: Part of the meta information about the current image.
    property var labels: [["Filename", qsTranslate("settingsmanager", "file name")],
                          //: Part of the meta information about the current image.
                          ["FileType", qsTranslate("settingsmanager", "file type")],
                          //: Part of the meta information about the current image.
                          ["FileSize", qsTranslate("settingsmanager", "file size")],
                          //: Part of the meta information about the current image.
                          ["ImageNumber", qsTranslate("settingsmanager", "image #/#")],
                          //: Part of the meta information about the current image.
                          ["Dimensions", qsTranslate("settingsmanager", "dimensions")],
                          //: Part of the meta information about the current image.
                          ["Copyright", qsTranslate("settingsmanager", "copyright")],
                          //: Part of the meta information about the current image.
                          ["ExposureTime", qsTranslate("settingsmanager", "exposure time")],
                          //: Part of the meta information about the current image.
                          ["Flash", qsTranslate("settingsmanager", "flash")],
                          //: Part of the meta information about the current image.
                          ["FLength", qsTranslate("settingsmanager", "focal length")],
                          //: Part of the meta information about the current image.
                          ["FNumber", qsTranslate("settingsmanager", "f-number")],
                          //: Part of the meta information about the current image.
                          ["Gps", qsTranslate("settingsmanager", "GPS position")],
                          ["Iso", "ISO"],
                          //: Part of the meta information about the current image.
                          ["Keywords", qsTranslate("settingsmanager", "keywords")],
                          //: Part of the meta information about the current image.
                          ["LightSource", qsTranslate("settingsmanager", "light source")],
                          //: Part of the meta information about the current image.
                          ["Location", qsTranslate("settingsmanager", "location")],
                          //: Part of the meta information about the current image.
                          ["Make", qsTranslate("settingsmanager", "make")],
                          //: Part of the meta information about the current image.
                          ["Model", qsTranslate("settingsmanager", "model")],
                          //: Part of the meta information about the current image.
                          ["SceneType", qsTranslate("settingsmanager", "scene type")],
                          //: Part of the meta information about the current image.
                          ["Software", qsTranslate("settingsmanager", "software")],
                          //: Part of the meta information about the current image.
                          ["Time", qsTranslate("settingsmanager", "time photo was taken")]]

    property var currentCheckBoxStates: ["0","0","0","0","0",
                                         "0","0","0","0","0",
                                         "0","0","0","0","0",
                                         "0","0","0","0","0"]
    property string _defaultCurrentCheckBoxStates: ""
    onCurrentCheckBoxStatesChanged:
        checkDefault()

    Column {

        id: contcol

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Labels")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text:qsTranslate("settingsmanager",  "Whenever an image is loaded PhotoQt tries to find as much metadata about the image as it can. The found information is then displayed in the metadata element that can be accesses either through one of the screen edges or as floating element. Since not all information might be wanted by everyone, individual information labels can be disabled.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Flow {

            x: (parent.width-width)/2

            width: setting_top.width > 940 ? 940 : (setting_top.width > 630 ? 630 : 310)
            spacing: 10

            Repeater {

                model: labels.length

                Rectangle {

                    id: deleg
                    height: 35
                    radius: 5

                    width: 300

                    property bool hovered: false

                    color: hovered||check.checked ? PQCLook.baseColorActive : PQCLook.baseColorHighlight
                    Behavior on color { ColorAnimation { duration: 200 } }

                    PQCheckBox {
                        id: check
                        x: 5
                        width: parent.width-10
                        y: (parent.height-height)/2
                        text: labels[index][1]
                        font.weight: PQCLook.fontWeightBold
                        color: deleg.hovered||check.checked ? PQCLook.textColorActive : PQCLook.textColor
                        elide: Text.ElideRight
                        checked: currentCheckBoxStates[index]==="1"
                        onCheckedChanged: {
                            var val = (checked ? "1" : "0")
                            if(currentCheckBoxStates[index] !== val) {
                                currentCheckBoxStates[index] = val
                                currentCheckBoxStatesChanged()
                                checked = Qt.binding(function() { return currentCheckBoxStates[index]==="1"; } )
                            }
                        }
                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered:
                            deleg.hovered = true
                        onExited:
                            deleg.hovered = false
                        onClicked:
                            check.checked = !check.checked
                    }

                }

            }

        }

        Item {
            width: 1
            height: 10
        }

        Column {

            x: (parent.width-width)/2
            spacing: 10

            PQButton {
                width: Math.min(setting_top.width, 500)
                //: used as in: check all checkboxes
                text: qsTranslate("settingsmanager", "Check all")
                onClicked: {
                    for(var i = 0; i < labels.length; ++i)
                        currentCheckBoxStates[i] = "1"
                    currentCheckBoxStatesChanged()
                }
            }

            PQButton {
                width: Math.min(setting_top.width, 500)
                //: used as in: check none of the checkboxes
                text: qsTranslate("settingsmanager", "Check none")
                onClicked: {
                    for(var i = 0; i < labels.length; ++i)
                        currentCheckBoxStates[i] = "0"
                    currentCheckBoxStatesChanged()
                }
            }

        }


    }

    Component.onCompleted:
        load()

    function checkDefault() {

        var chk = currentCheckBoxStates.join("")

        settingChanged = (chk!==_defaultCurrentCheckBoxStates)

    }

    function load() {

        for(var i = 0; i < labels.length; ++i) {
            currentCheckBoxStates[i] = (PQCSettings["metadata"+labels[i][0]] ? "1" : "0")
        }
        _defaultCurrentCheckBoxStates = currentCheckBoxStates.join("")
        currentCheckBoxStatesChanged()

        settingChanged = false

    }

    function applyChanges() {

        for(var i = 0; i < labels.length; ++i) {
            PQCSettings["metadata"+labels[i][0]] = (currentCheckBoxStates[i]==="1" ? true : false)
        }

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
