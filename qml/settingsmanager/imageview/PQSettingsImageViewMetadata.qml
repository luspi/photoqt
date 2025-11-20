/**************************************************************************
 * *                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

import QtQuick
import QtQuick.Controls
import PhotoQt

PQSetting {

    id: set_meta

    property list<var> labels: [
        //: Part of the meta information about the current image.
        ["Filename", qsTranslate("settingsmanager", "file name")],
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

    property list<string> currentCheckBoxStates: ["0","0","0","0","0",
                                                  "0","0","0","0","0",
                                                  "0","0","0","0","0",
                                                  "0","0","0","0"]
    property string _defaultCurrentCheckBoxStates: ""
    onCurrentCheckBoxStatesChanged:
        checkForChanges()

    signal labelsLoadDefault()
    signal labelsResetDefault()
    signal labelsSaveChanges()

    signal selectAllLabels()
    signal selectNoLabels()
    signal invertLabelSelection()

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Labels")

            helptext: qsTranslate("settingsmanager",  "Whenever an image is loaded PhotoQt tries to find as much metadata about the image as it can. The found information is then displayed in the metadata element that can be accesses either through one of the screen edges or as floating element. Since not all information might be wanted by everyone, individual information labels can be disabled.")

            showLineAbove: false

        },

        Rectangle {

            width: Math.min(set_meta.contentWidth, 600)
            height: 350
            color: "transparent"
            border.width: 1
            border.color: PQCLook.baseBorder

            PQLineEdit {
                id: labels_filter
                width: parent.width
                //: placeholder text in a text edit
                placeholderText: qsTranslate("settingsmanager", "Filter labels")
            }

            Flickable {

                id: labels_flickable

                x: 5
                y: labels_filter.height
                width: parent.width - (labels_scroll.visible ? 5 : 10)
                height: parent.height-labels_filter.height-labels_buts.height

                contentHeight: labels_col.height
                clip: true

                ScrollBar.vertical: PQVerticalScrollBar { id: labels_scroll }

                Grid {

                    id: labels_col
                    spacing: 5

                    columns: 3
                    padding: 5

                    Repeater {

                        model: set_meta.labels.length

                        Item {

                            id: deleg

                            required property int modelData

                            property bool matchesFilter: (labels_filter.text===""||set_meta.labels[deleg.modelData][1].toLowerCase().indexOf(labels_filter.text.toLowerCase()) > -1)

                            width: (labels_flickable.width - (labels_scroll.visible ? labels_scroll.width : 0))/3 - labels_col.spacing
                            height: matchesFilter ? 30 : 0
                            opacity: matchesFilter ? 1 : 0

                            Behavior on height { NumberAnimation { duration: 200 } }
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            PQHighlightMarker {
                                visible: tilemouse.containsMouse||check.checked
                            }

                            property bool delegSetup: false
                            Timer {
                                interval: 500
                                running: set_meta.settingsLoaded
                                onTriggered:
                                    deleg.delegSetup = true
                            }

                            PQCheckBox {
                                id: check
                                x: 10
                                y: (parent.height-height)/2
                                width: parent.width-20
                                elide: Text.ElideRight
                                text: set_meta.labels[deleg.modelData][1]
                                font.weight: PQCLook.fontWeightNormal
                                font.pointSize: PQCLook.fontSizeS
                                extraHovered: tilemouse.containsMouse
                                checked: PQCSettings["metadata"+set_meta.labels[deleg.modelData][0]]
                                onCheckedChanged: {
                                    if(!deleg.delegSetup) return
                                    set_meta.currentCheckBoxStates[deleg.modelData] = (checked ? "1" : "0")
                                    set_meta.currentCheckBoxStatesChanged()
                                }

                                Connections {
                                    target: set_meta
                                    function onSelectAllLabels() {
                                        check.checked = true
                                    }
                                    function onSelectNoLabels() {
                                        check.checked = false
                                    }
                                    function onInvertLabelSelection() {
                                        check.checked = !check.checked
                                    }
                                }

                            }

                            PQMouseArea {
                                id: tilemouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked:
                                    check.checked = !check.checked
                            }

                            Connections {

                                target: set_meta

                                function onLabelsResetDefault() {

                                    var m = set_meta.labels[deleg.modelData][0]

                                         if(m === "Filename")     check.checked = PQCSettings.getDefaultForMetadataFilename()
                                    else if(m === "FileType")     check.checked = PQCSettings.getDefaultForMetadataFileType()
                                    else if(m === "FileSize")     check.checked = PQCSettings.getDefaultForMetadataFileSize()
                                    else if(m === "ImageNumber")  check.checked = PQCSettings.getDefaultForMetadataImageNumber()
                                    else if(m === "Dimensions")   check.checked = PQCSettings.getDefaultForMetadataDimensions()

                                    else if(m === "Copyright")    check.checked = PQCSettings.getDefaultForMetadataCopyright()
                                    else if(m === "ExposureTime") check.checked = PQCSettings.getDefaultForMetadataExposureTime()
                                    else if(m === "Flash")        check.checked = PQCSettings.getDefaultForMetadataFlash()
                                    else if(m === "FLength")      check.checked = PQCSettings.getDefaultForMetadataFLength()
                                    else if(m === "FNumber")      check.checked = PQCSettings.getDefaultForMetadataFNumber()

                                    else if(m === "Gps")          check.checked = PQCSettings.getDefaultForMetadataGps()
                                    else if(m === "Iso")          check.checked = PQCSettings.getDefaultForMetadataIso()
                                    else if(m === "Keywords")     check.checked = PQCSettings.getDefaultForMetadataKeywords()
                                    else if(m === "LightSource")  check.checked = PQCSettings.getDefaultForMetadataLightSource()
                                    else if(m === "Location")     check.checked = PQCSettings.getDefaultForMetadataLocation()

                                    else if(m === "Make")         check.checked = PQCSettings.getDefaultForMetadataMake()
                                    else if(m === "Model")        check.checked = PQCSettings.getDefaultForMetadataModel()
                                    else if(m === "SceneType")    check.checked = PQCSettings.getDefaultForMetadataSceneType()
                                    else if(m === "Software")     check.checked = PQCSettings.getDefaultForMetadataSoftware()
                                    else if(m === "Time")         check.checked = PQCSettings.getDefaultForMetadataTime()

                                }

                                function onLabelsLoadDefault() {
                                    check.checked = PQCSettings["metadata"+set_meta.labels[deleg.modelData][0]]
                                }

                                function onLabelsSaveChanges() {
                                    PQCSettings["metadata"+set_meta.labels[deleg.modelData][0]] = check.checked
                                }
                            }

                        }

                    }

                    Item {
                        width: 1
                        height: 1
                    }

                }

            }

            Item {

                id: labels_buts
                y: (parent.height-height)
                width: parent.width
                height: 50

                Rectangle {
                    width: parent.width
                    height: 1
                    color: PQCLook.baseBorder
                }

                Row {
                    x: 5
                    y: (parent.height-height)/2
                    spacing: 5
                    PQButton {
                        id: butselall
                        width: (labels_buts.width-20)/3
                        //: written on button
                        text: qsTranslate("settingsmanager", "Select all")
                        smallerVersion: true
                        onClicked:
                            set_meta.selectAllLabels()
                    }
                    PQButton {
                        id: butselnone
                        width: (labels_buts.width-20)/3
                        //: written on button
                        text: qsTranslate("settingsmanager", "Select none")
                        smallerVersion: true
                        onClicked:
                            set_meta.selectNoLabels()
                    }
                    PQButton {
                        id: butselinv
                        width: (labels_buts.width-20)/3
                        //: written on button, referring to inverting the selected options
                        text: qsTranslate("settingsmanager", "Invert")
                        smallerVersion: true
                        onClicked:
                            set_meta.invertLabelSelection()
                    }
                }

            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                labelsResetDefault()

                set_meta.checkForChanges()

            }
        },

        /************************************************/

        PQSettingSubtitle {
            //: Settings title
            title: qsTranslate("settingsmanager", "Sidebar")
            visible: !set_meta.modernInterface
            helptext: qsTranslate("settingsmanager",  "Some information about the image can be shown in a side bar either along the left or the right edge of the window.")
        },

        PQCheckBox {
            id: sidebarcheck
            visible: !set_meta.modernInterface
            text: qsTranslate("settingsmanager", "Show information in sidebar")
            onCheckedChanged: set_meta.checkForChanges()
        },

        Row {
            visible: !set_meta.modernInterface
            spacing: 10
            PQRadioButton {
                id: sidebarleft
                enabled: sidebarcheck.checked
                text: qsTranslate("settingsmanager", "left edge")
                onCheckedChanged: set_meta.checkForChanges()
            }
            PQRadioButton {
                id: sidebarright
                enabled: sidebarcheck.checked
                text: qsTranslate("settingsmanager", "right edge")
                onCheckedChanged: set_meta.checkForChanges()
            }
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                sidebarcheck.checked = PQCSettings.getDefaultForMetadataSideBar()
                sidebarleft.checked = (PQCSettings.getDefaultForMetadataSideBarLocation()==="left")
                sidebarright.checked = (PQCSettings.getDefaultForMetadataSideBarLocation()==="right")

                set_meta.checkForChanges()

            }
        },

        /************************************************/

        PQSettingSubtitle {
            //: Settings title
            title: qsTranslate("settingsmanager", "Auto Rotation")
            helptext: qsTranslate("settingsmanager",  "When an image is taken with the camera turned on its side, some cameras store that rotation in the metadata. PhotoQt can use that information to display an image the way it was meant to be viewed. Disabling this will load all photos without any rotation applied by default.")
        },

        PQCheckBox {
            id: autorot
            enforceMaxWidth: set_meta.contentWidth
            text: qsTranslate("settingsmanager", "Apply default rotation automatically")
            onCheckedChanged: set_meta.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                autorot.checked = PQCSettings.getDefaultForMetadataAutoRotation()

                set_meta.checkForChanges()

            }
        },

        /************************************************/

        PQSettingSubtitle {
            //: Settings title
            title: qsTranslate("settingsmanager", "GPS map")
            helptext: qsTranslate("settingsmanager",  "Some cameras store the location of where the image was taken in the metadata of its images. PhotoQt can use that information in multiple ways. It can show a floating embedded map with a pin on that location, and it can show the GPS coordinates in the metadata element. In the latter case, a click on the GPS coordinates will open the location in an online map service, the choice of which can be set here.")
        },

        PQRadioButton {
            ButtonGroup { id: mapgroup }
            id: osm
            enforceMaxWidth: set_meta.contentWidth
            text: "openstreetmap.org"
            onCheckedChanged: set_meta.checkForChanges()
            ButtonGroup.group: mapgroup
        },
        PQRadioButton {
            id: google
            enforceMaxWidth: set_meta.contentWidth
            text: "maps.google.com"
            onCheckedChanged: set_meta.checkForChanges()
            ButtonGroup.group: mapgroup
        },
        PQRadioButton {
            id: bing
            enforceMaxWidth: set_meta.contentWidth
            text: "bing.com/maps"
            onCheckedChanged: set_meta.checkForChanges()
            ButtonGroup.group: mapgroup
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                var val = PQCSettings.getDefaultForMetadataGpsMap()
                google.checked = (val === "maps.google.com")
                bing.checked = (val === "bing.com/maps")
                osm.checked = (val === "openstreetmap.org" || (!google.checked && !bing.checked))

                set_meta.checkForChanges()

            }
        },

        /************************************************/

        PQSettingSubtitle {
            visible: set_meta.modernInterface
            //: Settings title
            title: qsTranslate("settingsmanager", "Floating element")
            helptext: qsTranslate("settingsmanager", "The metadata element can be show in two different ways. It can either be shown hidden behind one of the screen edges and shown when the cursor is close to said edge. Or it can be shown as floating element that can be triggered by shortcut and stays visible until manually hidden.")
        },

        PQRadioButton {
            visible: set_meta.modernInterface
            id: screenegde
            enforceMaxWidth: set_meta.contentWidth
            text: qsTranslate("settingsmanager", "hide behind screen edge")
            checked: !PQCSettings.metadataElementFloating
            onCheckedChanged: set_meta.checkForChanges()
        },

        PQRadioButton {
            visible: set_meta.modernInterface
            id: floating
            enforceMaxWidth: set_meta.contentWidth
            text: qsTranslate("settingsmanager", "use floating element")
            checked: PQCSettings.metadataElementFloating
            onCheckedChanged: set_meta.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                screenegde.checked = PQCSettings.getDefaultForMetadataElementFloating()
                floating.checked = PQCSettings.getDefaultForMetadataElementFloating()

                set_meta.checkForChanges()

            }
        }

    ]

    Timer {
        interval: 100
        id: saveDefaultCheckTimer
        onTriggered: {
            set_meta._defaultCurrentCheckBoxStates = set_meta.currentCheckBoxStates.join("")
        }
    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = ((_defaultCurrentCheckBoxStates !== currentCheckBoxStates.join("")) || autorot.hasChanged() ||
                                                      osm.hasChanged() || google.hasChanged() || bing.hasChanged() ||
                                                      screenegde.hasChanged() || floating.hasChanged() ||
                                                      sidebarcheck.hasChanged() || sidebarleft.hasChanged() || sidebarright.hasChanged())

    }

    function load() {

        settingsLoaded = false

        labelsLoadDefault()
        saveDefaultCheckTimer.restart()

        sidebarcheck.loadAndSetDefault(PQCSettings.metadataSideBar)
        sidebarright.loadAndSetDefault(PQCSettings.metadataSideBarLocation==="right")
        sidebarleft.loadAndSetDefault(PQCSettings.metadataSideBarLocation==="left")

        autorot.loadAndSetDefault(PQCSettings.metadataAutoRotation)

        google.loadAndSetDefault(PQCSettings.metadataGpsMap==="maps.google.com")
        bing.loadAndSetDefault(PQCSettings.metadataGpsMap==="bing.com/maps")
        osm.loadAndSetDefault(PQCSettings.metadataGpsMap==="openstreetmap.org" || (!google.checked && !bing.checked))

        screenegde.loadAndSetDefault(!PQCSettings.metadataElementFloating)
        floating.loadAndSetDefault(PQCSettings.metadataElementFloating)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        labelsSaveChanges()
        _defaultCurrentCheckBoxStates = currentCheckBoxStates.join("")

        PQCSettings.metadataSideBar = sidebarcheck.checked
        PQCSettings.metadataSideBarLocation = (sidebarleft.checked ? "left" : "right")

        sidebarcheck.saveDefault()
        sidebarleft.saveDefault()
        sidebarright.saveDefault()

        PQCSettings.metadataAutoRotation = autorot.checked
        autorot.saveDefault()

        if(bing.checked)
            PQCSettings.metadataGpsMap = "bing.com/maps"
        else if(google.checked)
            PQCSettings.metadataGpsMap = "maps.google.com"
        else
            PQCSettings.metadataGpsMap = "openstreetmap.org"
        osm.saveDefault()
        google.saveDefault()
        bing.saveDefault()

        PQCSettings.metadataElementFloating = floating.checked
        screenegde.saveDefault()
        floating.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
