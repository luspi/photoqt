/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import PQCNotify

import "../elements"

PQTemplateFullscreen {

    id: settingsmanager_top

    thisis: "settingsmanager"
    popout: PQCSettings.interfacePopoutSettingsManager
    shortcut: "__settings"

    title: qsTranslate("settingsmanager", "Settings Manager")

    onPopoutChanged:
        PQCSettings.interfacePopoutSettingsManager = popout

    button1.text: qsTranslate("settingsmanager", "Apply changes")
    button1.enabled: settingsloader.status===Loader.Ready ? settingsloader.item.settingChanged : false
    button1.onClicked: settingsloader.item.applyChanges()

    button2.text: qsTranslate("settingsmanager", "Revert changes")
    button2.visible: true
    button2.enabled: button1.enabled
    button2.onClicked: settingsloader.item.revertChanges()

    button3.visible: true
    button3.text: genericStringClose
    button3.font.weight: PQCLook.fontWeightNormal
    button3.onClicked: {
        if(button1.enabled) {
            confirmUnsaved.cat = "-"
            confirmUnsaved.opacity = 1
        } else
            hide()
    }

    property bool passShortcutsToDetector: false
    signal passOnShortcuts(var mods, var keys)

    property var selectedCategories: ["interface", "if_language"]
    onSelectedCategoriesChanged: {
        fullscreenitem.forceActiveFocus()
    }

    property var filterCategories: []
    property var filterSubCategories: []

    property var categories: {

        //: A settings category
        "interface" : [qsTranslate("settingsmanager", "Interface"),
                       {
                                             //: A settings subcategory and the qml filename
                            "if_language"    : [qsTranslate("settingsmanager", "Language"), "PQLanguage",
                                                 // the title and settings for filtering
                                                [qsTranslate("settingsmanager", "Language")],
                                                 // the settings for filtering
                                                ["Language"]],

                                                //: A settings subcategory
                            "if_background"  : [qsTranslate("settingsmanager", "Background"),   "PQBackground",
                                                [qsTranslate("settingsmanager", "Background"),
                                                 qsTranslate("settingsmanager", "Click on empty background"),
                                                 qsTranslate("settingsmanager", "Blurring elements behind other elements")],
                                                ["BackgroundImageScreenshot",
                                                 "BackgroundImageUse",
                                                 "BackgroundSolid",
                                                 "BackgroundImageUse",
                                                 "BackgroundImagePath",
                                                 "BackgroundImageScale",
                                                 "BackgroundImageScaleCrop",
                                                 "BackgroundImageStretch",
                                                 "BackgroundImageCenter",
                                                 "BackgroundImageTile",
                                                 "CloseOnEmptyBackground",
                                                 "NavigateOnEmptyBackground",
                                                 "WindowDecorationOnEmptyBackground",
                                                 "BlurElementsInBackground"]],

                                                //: A settings subcategory
                            "if_popout"      : [qsTranslate("settingsmanager", "Popout"),       "PQPopout",
                                                [qsTranslate("settingsmanager", "Popout"),
                                                 qsTranslate("settingsmanager", "Keep popouts open"),
                                                 qsTranslate("settingsmanager", "Pop out when window is small")],
                                                ["PopoutFileDialogKeepOpen",
                                                 "PopoutMapExplorerKeepOpen",
                                                 "PopoutWhenWindowIsSmall",
                                                 "PopoutFileDialog",
                                                 "PopoutMapExplorer",
                                                 "PopoutSettingsManager",
                                                 "PopoutMainMenu",
                                                 "PopoutMetadata",
                                                 "PopoutHistogram",
                                                 "PopoutMapCurrent",
                                                 "PopoutScale",
                                                 "PopoutSlideshowSetup",
                                                 "PopoutSlideShowControls",
                                                 "PopoutFileRename",
                                                 "PopoutFileDelete",
                                                 "PopoutExport",
                                                 "PopoutAbout",
                                                 "PopoutImgur",
                                                 "PopoutWallpaper",
                                                 "PopoutFilter",
                                                 "PopoutAdvancedSort",
                                                 "PopoutChromecast"]],

                                                //: A settings subcategory
                            "if_edges"       : [qsTranslate("settingsmanager", "Edges"),        "PQEdges",
                                                [qsTranslate("settingsmanager", "Edges"),
                                                 qsTranslate("settingsmanager", "Sensitivity")],
                                                ["EdgeTopAction",
                                                 "EdgeLeftAction",
                                                 "EdgeRightAction",
                                                 "EdgeBottomAction",
                                                 "HotEdgeSize"]],

                                                //: A settings subcategory
                            "if_contextmenu" : [qsTranslate("settingsmanager", "Context menu"), "PQContextMenu",
                                                [qsTranslate("settingsmanager", "Context menu"),
                                                 qsTranslate("settingsmanager", "Duplicate entries in main menu")],
                                                ["ShowExternal"]],

                                                //: A settings subcategory
                            "if_statusinfo"  : [qsTranslate("settingsmanager", "Status info"),  "PQStatusInfo",
                                                [qsTranslate("settingsmanager", "Status info"),
                                                 qsTranslate("settingsmanager", "Font size"),
                                                 qsTranslate("settingsmanager", "Hide automatically"),
                                                 qsTranslate("settingsmanager", "Window management")],
                                                ["StatusInfoShow",
                                                 "StatusInfoList",
                                                 "StatusInfoFontSize",
                                                 "StatusInfoAutoHide",
                                                 "StatusInfoAutoHideTopEdge",
                                                 "StatusInfoAutoHideTimeout",
                                                 "StatusInfoShowImageChange",
                                                 "StatusInfoManageWindow"]],

                                                //: A settings subcategory
                            "if_window"      : [qsTranslate("settingsmanager", "Window"),       "PQWindow",
                                                [qsTranslate("settingsmanager", "Fullscreen or window mode"),
                                                 qsTranslate("settingsmanager", "Window buttons"),
                                                 qsTranslate("settingsmanager", "Hide automatically")],
                                                ["WindowMode",
                                                 "KeepWindowOnTop",
                                                 "SaveWindowGeometry",
                                                 "WindowDecoration",
                                                 "WindowButtonsShow",
                                                 "WindowButtonsDuplicateDecorationButtons",
                                                 "NavigationTopRight",
                                                 "WindowButtonsSize",
                                                 "WindowButtonsAutoHide",
                                                 "WindowButtonsAutoHideTopEdge",
                                                 "WindowButtonsAutoHideTimeout"]],
                       }],

        /**************************************************************************************************************************/

        //: A settings category
        "imageview" : [qsTranslate("settingsmanager", "Image view"),
                       {
                                                //: A settings subcategory
                            "iv_image"       : [qsTranslate("settingsmanager", "Image"),        "PQImage",
                                                [qsTranslate("settingsmanager", "Margin"),
                                                 qsTranslate("settingsmanager", "Image size"),
                                                 qsTranslate("settingsmanager", "Transparency marker"),
                                                 qsTranslate("settingsmanager", "Interpolation"),
                                                 qsTranslate("settingsmanager", "Cache")],
                                                ["Margin",
                                                 "AlwaysActualSize",
                                                 "FitInWindow",
                                                 "TransparencyMarker",
                                                 "InterpolationDisableForSmallImages",
                                                 "InterpolationThreshold",
                                                 "Cache"]],

                                                //: A settings subcategory
                            "iv_interaction" : [qsTranslate("settingsmanager", "Interaction"),  "PQInteraction",
                                                [qsTranslate("settingsmanager", "Zoom"),
                                                 qsTranslate("settingsmanager", "Floating navigation")],
                                                ["ZoomSpeed",
                                                 "ZoomMinEnabled",
                                                 "ZoomMin",
                                                 "ZoomMaxEnabled",
                                                 "ZoomMax",
                                                 "NavigationFloating"]],

                                                //: A settings subcategory
                            "iv_folder"      : [qsTranslate("settingsmanager", "Folder"),       "PQFolder",
                                                [qsTranslate("settingsmanager", "Looping"),
                                                 qsTranslate("settingsmanager", "Sort images"),
                                                 qsTranslate("settingsmanager", "Animation")],
                                                ["LoopThroughFolder",
                                                 "SortImagesBy",
                                                 "SortImagesAscending",
                                                 "AnimationDuration",
                                                 "AnimationType"]],

                                                //: A settings subcategory
                            "iv_online"      : [qsTranslate("settingsmanager", "Share online"), "PQShareOnline",
                                                ["imgur.com"],
                                                []]
                       }],

        /**************************************************************************************************************************/

        //: A settings category
        "thumbnails" : [qsTranslate("settingsmanager", "Thumbnails"),
                        {
                                           //: A settings subcategory
                            "tb_image"  : [qsTranslate("settingsmanager", "Image"),          "PQImage",
                                           [qsTranslate("settingsmanager", "Size"),
                                            qsTranslate("settingsmanager", "Scale and crop"),
                                            qsTranslate("settingsmanager", "Icons only"),
                                            qsTranslate("settingsmanager", "Label"),
                                            qsTranslate("settingsmanager", "Tooltip")],
                                           ["Size",
                                            "CropToFit",
                                            "SmallThumbnailsKeepSmall",
                                            "IconsOnly",
                                            "Filename",
                                            "FontSize",
                                            "InactiveTransparent",
                                            "Tooltip"]],

                                           //: A settings subcategory
                            "tb_all"    : [qsTranslate("settingsmanager", "All thumbnails"), "PQAllThumbnails",
                                           [qsTranslate("settingsmanager", "Spacing"),
                                            qsTranslate("settingsmanager", "Highlight"),
                                            qsTranslate("settingsmanager", "Center on active"),
                                            qsTranslate("settingsmanager", "Visibility")],
                                           ["Spacing",
                                            "HighlightAnimation",
                                            "HighlightAnimationLiftUp",
                                            "CenterOnActive",
                                            "Visibility"]],

                                           //: A settings subcategory
                            "tb_manage" : [qsTranslate("settingsmanager", "Manage"),         "PQManage",
                                           [qsTranslate("settingsmanager", "Cache"),
                                            qsTranslate("settingsmanager", "Exclude folders"),
                                            qsTranslate("settingsmanager", "How many threads")],
                                           ["Cache",
                                            "ExcludeNextcloud",
                                            "ExcludeOwnCloud",
                                            "ExcludeDropBox",
                                            "ExcludeFolders",
                                            "MaxNumberThreads"]]
                        }],

        /**************************************************************************************************************************/

        //: A settings category
        "metadata" : [qsTranslate("settingsmanager", "Metadata"),
                      {
                                             //: A settings subcategory
                            "md_labels"   : [qsTranslate("settingsmanager", "Labels"),        "PQLabels",
                                             [qsTranslate("settingsmanager", "Labels")],
                                             ["Filename",
                                              "FileType",
                                              "FileSize",
                                              "ImageNumber",
                                              "Dimensions",
                                              "Copyright",
                                              "ExposureTime",
                                              "Flash",
                                              "FLength",
                                              "FNumber",
                                              "Gps",
                                              "Iso",
                                              "Keywords",
                                              "LightSource",
                                              "Location",
                                              "Make",
                                              "Model",
                                              "SceneType",
                                              "Software",
                                              "Time"]],

                                             //: A settings subcategory
                            "md_behavior" : [qsTranslate("settingsmanager", "Behavior"),      "PQBehavior",
                                             [qsTranslate("settingsmanager", "Auto Rotation"),
                                              qsTranslate("settingsmanager", "GPS map"),
                                              qsTranslate("settingsmanager", "Floating element")],
                                             ["AutoRotation",
                                              "GpsMap",
                                              "ElementFloating"]],

                                             //: A settings subcategory
                            "md_facetags" : [qsTranslate("settingsmanager", "Face tags"),     "PQFaceTags",
                                             [qsTranslate("settingsmanager", "Show face tags"),
                                              qsTranslate("settingsmanager", "Look"),
                                              qsTranslate("settingsmanager", "Visibility")],
                                             ["FaceTagsEnabled",
                                              "FaceTagsFontSize",
                                              "FaceTagsBorder",
                                              "FaceTagsBorderWidth",
                                              "FaceTagsBorderColor",
                                              "FaceTagsVisibility"]]
                      }],

        /**************************************************************************************************************************/

        //: A settings category
        "session" : [qsTranslate("settingsmanager", "Session"),
                     {
                                          //: A settings subcategory
                         "ss_instance" : [qsTranslate("settingsmanager", "Instance"),   "PQInstance",
                                          [qsTranslate("settingsmanager", "Single instance"),
                                           "AllowMultipleInstances"]],

                                          //: A settings subcategory
                         "ss_remember" : [qsTranslate("settingsmanager", "Remember"),   "PQRemember",
                                          [qsTranslate("settingsmanager", "Reopen last image"),
                                           qsTranslate("settingsmanager", "Remember changes")],
                                          ["RememberLastImage",
                                           "RememberZoomRotationMirror"]],

                                          //: A settings subcategory
                         "ss_trayicon" : [qsTranslate("settingsmanager", "Tray icon"),  "PQTrayIcon",
                                          [qsTranslate("settingsmanager", "Tray Icon"),
                                           qsTranslate("settingsmanager", "Reset when hiding")],
                                          ["TrayIcon",
                                           "TrayIconMonochrome",
                                           "TrayIconHideReset"]]
                     }],

        /**************************************************************************************************************************/

        //: A settings category
        "filetypes" : [qsTranslate("settingsmanager", "File types"),
                       {
                                             //: A settings subcategory
                           "ft_filetypes" : [qsTranslate("settingsmanager", "File types"), "PQFileTypes",
                                             [qsTranslate("settingsmanager", "File types")],
                                             []],

                                             //: A settings subcategory
                           "ft_tweaks"    : [qsTranslate("settingsmanager", "Behavior"),   "PQBehavior",
                                             [qsTranslate("settingsmanager", "PDF"),
                                              qsTranslate("settingsmanager", "Archive"),
                                              qsTranslate("settingsmanager", "Video"),
                                              qsTranslate("settingsmanager", "Viewer mode")],
                                             ["PDFQuality",
                                              "ExternalUnrar",
                                              "VideoAutoplay",
                                              "VideoLoop",
                                              "VideoPreferLibmpv",
                                              "VideoThumbnailer",
                                              "BigViewerModeButton"]],
                           "ft_motionlive"  : [qsTranslate("settingsmanager", "Advanced"), "PQAdvanced",
                                               ["Apple Live Photo",
                                                "Google/Samsung Motion Video"],
                                                ["LoadMotionPhotos",
                                                 "LoadAppleLivePhotos"]]
                       }],

        /**************************************************************************************************************************/

        //: A settings category
        "shortcuts" : [qsTranslate("settingsmanager", "Keyboard & Mouse"),
                       {
                                             //: A settings subcategory
                           "sc_shortcuts" : [qsTranslate("settingsmanager", "Shortcuts"),  "PQShortcuts",
                                             [qsTranslate("settingsmanager", "Shortcuts")],
                                             []],

                                             //: A settings subcategory
                           "sc_behavior"  : [qsTranslate("settingsmanager", "Behavior"),   "PQBehavior",
                                             [qsTranslate("settingsmanager", "Move image with mouse"),
                                              qsTranslate("settingsmanager", "Double click"),
                                              qsTranslate("settingsmanager", "Mouse wheel"),
                                              qsTranslate("settingsmanager", "Hide mouse cursor")],
                                             ["UseMouseWheelForImageMove",
                                              "UseMouseLeftButtonForImageMove",
                                              "DoubleClickThreshold",
                                              "MouseWheelSensitivity",
                                              "HideCursorTimeout"]]
                       }],

        "manage" : [qsTranslate("settingsmanager", "Manage"),
                    {
                        "mn_reset" : [qsTranslate("settingsmanager", "Reset"), "PQReset",
                                      [qsTranslate("settingsmanager", "Reset settings"),
                                       qsTranslate("settingsmanager", "Reset shortcuts")],
                                      []],

                        "mn_expimp" : [qsTranslate("settingsmanager", "Export/Import"), "PQExportImport",
                                       [qsTranslate("settingsmanager", "Export settings"),
                                        qsTranslate("settingsmanager", "Import settings")],
                                       []]
                    }]

    }

    property var categoryKeys: Object.keys(categories)

    content: [

        SplitView {

            width: settingsmanager_top.width
            height: settingsmanager_top.contentHeight

            // Show larger handle with triple dash
            handle: Rectangle {
                implicitWidth: 5
                implicitHeight: 5
                color: SplitHandle.hovered ? PQCLook.baseColorActive : PQCLook.baseColorHighlight
                Behavior on color { ColorAnimation { duration: 200 } }
                Image {
                    y: (parent.height-height)/2
                    width: parent.implicitWidth
                    height: parent.implicitHeight
                    sourceSize: Qt.size(width, height)
                    source: "image://svg/:/white/handle.svg"
                }
            }

            PQMainCategory {
                id: sm_maincategory
                SplitView.minimumWidth: 100
                SplitView.preferredWidth: 250
            }

            PQSubCategory {
                id: sm_subcategory
                SplitView.minimumWidth: 100
                SplitView.preferredWidth: 250
            }

            Item {

                SplitView.minimumWidth: 400
                SplitView.fillWidth: true

                height: settingsmanager_top.contentHeight

                Loader {
                    id: settingsloader
                    anchors.fill: parent
                    anchors.bottomMargin: 30
                    clip: true
                    asynchronous: true
                    source: "settings/" + selectedCategories[0] + "/" + categories[selectedCategories[0]][1][selectedCategories[1]][1] + ".qml"
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    y: parent.height-29
                    color: PQCLook.baseColorHighlight
                }

                PQTextS {
                    x: 5
                    y: parent.height-29
                    height: 29
                    verticalAlignment: Text.AlignVCenter
                    font.weight: PQCLook.fontWeightBold
                    text: qsTranslate("settingsmanager", "Ctrl+S = Apply changes, Ctrl+R = Revert changes, Esc = Close")
                }

            }

        }

    ]

    Rectangle {

        id: confirmUnsaved

        anchors.fill: parent
        color: PQCLook.transColor

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: opacity>0

        property string cat: ""
        property int ind: -1

        Column {

            x: (parent.width-width)/2
            y: (parent.height-height)/2

            spacing: 20

            PQTextXL {
                x: (parent.width-width)/2
                font.weight: PQCLook.fontWeightBold
                text: qsTranslate("settingsmanager", "Unsaved changes")
            }

            PQText {
                x: (parent.width-width)/2
                width: 400
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTranslate("settingsmanager", "The settings on this page have changed. Do you want to apply or discard them?")
            }

            Row {

                x: (parent.width-width)/2

                spacing: 10

                PQButton {
                    id: confirmApply
                    //: written on button, used as in: apply changes
                    text: qsTranslate("settingsmanager", "Apply")
                    onClicked: {
                        settingsloader.item.applyChanges()

                        if(confirmUnsaved.cat == "-") {
                            hide()
                        } else if(confirmUnsaved.cat == "main") {
                            sm_maincategory.setCurrentIndex(confirmUnsaved.ind)
                        } else if(confirmUnsaved.cat == "sub") {
                            sm_subcategory.setCurrentIndex(confirmUnsaved.ind)
                        }
                        confirmUnsaved.opacity = 0
                        confirmUnsaved.cat = ""
                        confirmUnsaved.ind = -1
                    }
                }
                PQButton {
                    id: confirmDiscard
                    //: written on button, used as in: discard changes
                    text: qsTranslate("settingsmanager", "Discard")
                    onClicked: {
                        if(confirmUnsaved.cat == "-") {
                            hide()
                        } else if(confirmUnsaved.cat == "main") {
                            sm_maincategory.setCurrentIndex(confirmUnsaved.ind)
                        } else if(confirmUnsaved.cat == "sub") {
                            sm_subcategory.setCurrentIndex(confirmUnsaved.ind)
                        }
                        confirmUnsaved.opacity = 0
                        confirmUnsaved.cat = ""
                        confirmUnsaved.ind = -1
                    }
                }
                PQButton {
                    id: confirmCancel
                    text: genericStringCancel
                    onClicked: {
                        confirmUnsaved.opacity = 0
                        confirmUnsaved.cat = ""
                        confirmUnsaved.ind = -1
                    }
                }
            }

        }

    }

    Connections {
        target: loader

        function onPassOn(what, param) {

            if(what === "show") {

                if(param === thisis)
                    show()

            } else if(what === "hide") {

                if(param === thisis)
                    hide()

            } else if(settingsmanager_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(passShortcutsToDetector) {
                        passOnShortcuts(param[1], param[0])
                        return
                    }

                    if(param[0] === Qt.Key_Escape) {

                        if(confirmUnsaved.visible)
                            confirmCancel.clicked()
                        else {
                            button3.clicked()
                        }

                    } else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return) {

                        if(confirmUnsaved.visible)
                            confirmApply.clicked()

                    } else if(param[0] === Qt.Key_S && param[1] === Qt.ControlModifier) {

                        if(confirmUnsaved.opacity < 1)
                            settingsloader.item.applyChanges()

                    } else if(param[0] === Qt.Key_R && param[1] === Qt.ControlModifier) {

                        if(confirmUnsaved.opacity < 1)
                            settingsloader.item.revertChanges()

                    } else if(param[0] === Qt.Key_F && param[1] === Qt.ControlModifier) {

                        sm_maincategory.setFocusOnFilter()

                    } else if(param[0] === Qt.Key_Tab && param[1] === Qt.ControlModifier) {

                        sm_subcategory.gotoNextIndex()

                    } else if((param[0] === Qt.Key_Backtab || param[0] === Qt.Key_Tab) && param[1] === Qt.ShiftModifier+Qt.ControlModifier) {

                        sm_subcategory.gotoPreviousIndex()

                    } else if(param[0] === Qt.Key_Down && param[1] === Qt.ControlModifier) {

                        sm_maincategory.gotoNextIndex()

                    } else if(param[0] === Qt.Key_Up && param[1] === Qt.ControlModifier) {

                        sm_maincategory.gotoPreviousIndex()

                    }

                }

            }

        }

    }

    function filterSettings(str) {

        if(str === "") {
            filterCategories = []
            filterSubCategories = []
        }

        var foundcat = []
        var foundsubcat = []

        for(var i in categoryKeys) {

            var key = categoryKeys[i]
            var val = categories[key]

            var subkeys = Object.keys(val[1])

            for(var j in subkeys) {

                var subkey = subkeys[j]
                var subval = val[1][subkey]

                if(subval[0].toLowerCase().includes(str)) {
                    if(foundcat.indexOf(key) === -1)
                        foundcat.push(key)
                    foundsubcat.push(subkey)
                } else {

                    for(var k in subval[2]) {

                        if(subval[2][k].toLowerCase().includes(str)) {
                            if(foundcat.indexOf(key) === -1)
                                foundcat.push(key)
                            foundsubcat.push(subkey)
                            break
                        }

                    }

                    for(var l in subval[3]) {

                        if(subval[3][l].toLowerCase().includes(str)) {
                            if(foundcat.indexOf(key) === -1)
                                foundcat.push(key)
                            if(foundsubcat.indexOf(subkey) === -1)
                                foundsubcat.push(subkey)
                            break
                        }

                    }
                }

            }

        }

        // if nothing was found we need to distinguish this from 'no filter text entered'
        if(foundcat.length == 0 || foundsubcat.length == 0) {
            foundcat = ["-"]
            foundsubcat = ["-"]
        }

        filterCategories = foundcat
        filterSubCategories = foundsubcat

    }

    function confirmIfUnsavedChanged(cat, index) {

        if(confirmUnsaved.cat != "")
            return true

        if(settingsloader.status !== Loader.Ready)
            return true

        if(!settingsloader.item.settingChanged)
            return true

        confirmUnsaved.cat = cat
        confirmUnsaved.ind = index
        confirmUnsaved.opacity = 1

        return false

    }

    function show() {
        opacity = 1

        if(settingsloader.status === Loader.Ready)
            settingsloader.item.revertChanges()

    }

    function hide() {
        confirmUnsaved.opacity = 0
        settingsmanager_top.opacity = 0
        loader.elementClosed(thisis)
        PQCNotify.ignoreKeysExceptEnterEsc = false
        PQCNotify.ignoreKeysExceptEsc = false
        fullscreenitem.forceActiveFocus()
    }

}
