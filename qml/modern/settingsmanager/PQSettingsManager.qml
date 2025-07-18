/**************************************************************************
 **                                                                      **
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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import PhotoQt

PQTemplateFullscreen {

    id: settingsmanager_top

    thisis: "settingsmanager"
    popout: PQCSettings.interfacePopoutSettingsManager      // qmllint disable unqualified
    shortcut: "__settings"
    noGapsAnywhere: true

    title: qsTranslate("settingsmanager", "Settings Manager")

    onPopoutChanged: {
        PQCSettings.interfacePopoutSettingsManager = popout // qmllint disable unqualified
    }

    function onPopoutClosed() {
        if(confirmUnsaved.visible)
            confirmCancel.clicked()
        if(settinginfomessage.visible)
            settinginfomessage.hide()
        button3.clicked()
    }

    button1.text: qsTranslate("settingsmanager", "Apply changes")
    button1.enabled: settingsloader.status===Loader.Ready ? settingsloader.item.settingChanged : false  // qmllint disable missing-property
    button1.onClicked: settingsloader.item.applyChanges()   // qmllint disable missing-property

    button2.text: qsTranslate("settingsmanager", "Revert changes")
    button2.visible: true
    button2.enabled: button1.enabled
    button2.onClicked: settingsloader.item.revertChanges()  // qmllint disable missing-property

    button3.visible: true
    button3.text: genericStringClose
    button3.font.weight: PQCLook.fontWeightNormal   // qmllint disable unqualified
    button3.onClicked: {
        if(button1.enabled) {
            confirmUnsaved.cat = "-"
            confirmUnsaved.opacity = 1
        } else
            hide()
    }

    property list<PQButton> allbuttons: [settingsinfobut, confirmApply, confirmDiscard, confirmCancel]

    botLeftContent: [
        Row {
            y: (parent.height-height)/2
            PQCheckBox {
                text: qsTranslate("settingsmanager", "auto-save")
                font.pointSize: PQCLook.fontSizeS                   // qmllint disable unqualified
                checked: PQCSettings.generalAutoSaveSettings        // qmllint disable unqualified
                onCheckedChanged: {
                    PQCSettings.generalAutoSaveSettings = checked   // qmllint disable unqualified
                }
            }
            PQCheckBox {
                text: qsTranslate("settingsmanager", "compact")
                font.pointSize: PQCLook.fontSizeS                   // qmllint disable unqualified
                checked: PQCSettings.generalCompactSettings         // qmllint disable unqualified
                onCheckedChanged: {
                    PQCSettings.generalCompactSettings = checked    // qmllint disable unqualified
                }
            }
        }
    ]

    showPopinPopout: !popout || !PQCWindowGeometry.settingsmanagerForcePopout   // qmllint disable unqualified

    property bool passShortcutsToDetector: false
    signal passOnShortcuts(var mods, var keys)

    property list<string> filterCategories: []
    property list<string> filterSubCategories: []

    property var categories: {

        //: A settings category
        "interface" : [qsTranslate("settingsmanager", "Interface"),
                       {
                                                //: A settings subcategory and the qml filename
                            "if_interface"    : [qsTranslate("settingsmanager", "Interface"), "PQInterface",
                                                 // the title and settings for filtering
                                                [qsTranslate("settingsmanager", "Language"),
                                                 qsTranslate("settingsmanager", "Fullscreen or window mode"),
                                                 qsTranslate("settingsmanager", "Window buttons"),
                                                 qsTranslate("settingsmanager", "Accent color"),
                                                 qsTranslate("settingsmanager", "Font weight"),
                                                 qsTranslate("settingsmanager", "Notification")],
                                                 // the settings for filtering
                                                ["Language",
                                                 "WindowMode",
                                                 "KeepWindowOnTop",
                                                 "SaveWindowGeometry",
                                                 "WindowDecoration",
                                                 "WindowButtonsShow",
                                                 "WindowButtonsDuplicateDecorationButtons",
                                                 "NavigationTopRight",
                                                 "WindowButtonsSize",
                                                 "WindowButtonsAutoHide",
                                                 "WindowButtonsAutoHideTopEdge",
                                                 "WindowButtonsAutoHideTimeout",
                                                 "AccentColor",
                                                 "FontNormalWeight",
                                                 "FontBoldWeight",
                                                 "NotificationLocation",
                                                 "NotificationTryNative",
                                                 "NotificationDistanceFromEdge"]],

                                                //: A settings subcategory
                            "if_background"  : [qsTranslate("settingsmanager", "Background"),   "PQBackground",
                                                [qsTranslate("settingsmanager", "Background"),
                                                 qsTranslate("settingsmanager", "Click on empty background"),
                                                 qsTranslate("settingsmanager", "Blurring elements behind other elements")],
                                                ["BackgroundImageScreenshot",
                                                 "BackgroundImageUse",
                                                 "BackgroundSolid",
                                                 "BackgroundFullyTransparent",
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
                                                ["PopoutFileDialogNonModal",
                                                 "PopoutMapExplorerNonModal",
                                                 "PopoutSettingsManagerNonModal",
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
                                                 "PopoutChromecast",
                                                 "PopoutCrop",
                                                 "MinimapPopout"]],

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
                                                 //: The alignment here refers to the position of the statusinfo, where along the top edge of the window it should be aligned along
                                                 qsTranslate("settingsmanager", "Alignment"),
                                                 qsTranslate("settingsmanager", "Window management")],
                                                ["StatusInfoShow",
                                                 "StatusInfoList",
                                                 "StatusInfoFontSize",
                                                 "StatusInfoAutoHide",
                                                 "StatusInfoAutoHideTopEdge",
                                                 "StatusInfoAutoHideTimeout",
                                                 "StatusInfoShowImageChange",
                                                 "StatusInfoManageWindow",
                                                 "StatusInfoPosition"]]

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
                                                 qsTranslate("settingsmanager", "Cache"),
                                                 qsTranslate("settingsmanager", "Color profiles")],
                                                ["Margin",
                                                 "AlwaysActualSize",
                                                 "FitInWindow",
                                                 "RespectDevicePixelRatio",
                                                 "TransparencyMarker",
                                                 "InterpolationDisableForSmallImages",
                                                 "Cache",
                                                 "ColorSpaceContextMenu",
                                                 "ColorSpaceEnable",
                                                 "ColorSpaceLoadEmbedded",
                                                 "ColorSpaceDefault"]],

                                                //: A settings subcategory
                            "iv_interaction" : [qsTranslate("settingsmanager", "Interaction"),  "PQInteraction",
                                                [qsTranslate("settingsmanager", "Zoom"),
                                                 qsTranslate("settingsmanager", "Minimap"),
                                                 qsTranslate("settingsmanager", "Mirror/Flip"),
                                                 qsTranslate("settingsmanager", "Floating navigation")],
                                                ["ZoomSpeed",
                                                 "ZoomMinEnabled",
                                                 "ZoomMin",
                                                 "ZoomMaxEnabled",
                                                 "ZoomMax",
                                                 "ZoomToCenter",
                                                 "MirrorAnimate",
                                                 "FloatingNavigation",
                                                 "ShowMinimap",
                                                 "MinimapSizeLevel"]],

                                                //: A settings subcategory
                            "iv_folder"      : [qsTranslate("settingsmanager", "Folder"),       "PQFolder",
                                                [qsTranslate("settingsmanager", "Looping"),
                                                 qsTranslate("settingsmanager", "Sort images"),
                                                 qsTranslate("settingsmanager", "Animation"),
                                                 qsTranslate("settingsmanager", "Preloading")],
                                                ["LoopThroughFolder",
                                                 "SortImagesBy",
                                                 "SortImagesAscending",
                                                 "AnimationDuration",
                                                 "AnimationType",
                                                 "PreloadInBackground"]],

                                                //: A settings subcategory
                            "iv_online"      : [qsTranslate("settingsmanager", "Share online"), "PQShareOnline",
                                                ["imgur.com"],
                                                []],

                                               //: A settings subcategory
                            "iv_metadata" : [qsTranslate("settingsmanager", "Metadata"),      "PQMetadata",
                                             [qsTranslate("settingsmanager", "Labels"),
                                              qsTranslate("settingsmanager", "Auto Rotation"),
                                              qsTranslate("settingsmanager", "GPS map"),
                                              qsTranslate("settingsmanager", "Floating element"),
                                              qsTranslate("settingsmanager", "Face tags"),
                                              qsTranslate("settingsmanager", "Look of face tags")],
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
                                              "Time",
                                              "AutoRotation",
                                              "GpsMap",
                                              "ElementFloating",
                                              "FaceTagsEnabled",
                                              "FaceTagsFontSize",
                                              "FaceTagsBorder",
                                              "FaceTagsBorderWidth",
                                              "FaceTagsBorderColor",
                                              "FaceTagsVisibility"]]
                       }],

        /**************************************************************************************************************************/

        //: A settings category
        "thumbnails" : [qsTranslate("settingsmanager", "Thumbnails"),
                        {
                                           //: A settings subcategory
                            "tb_image"  : [qsTranslate("settingsmanager", "Image"),          "PQThumbnailImage",
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
                            "tb_manage" : [qsTranslate("settingsmanager", "Manage"),         "PQThumbnailManage",
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
        "filetypes" : [qsTranslate("settingsmanager", "File types"),
                       {
                                             //: A settings subcategory
                           "ft_filetypes" : [qsTranslate("settingsmanager", "File types"), "PQFileTypes",
                                             [qsTranslate("settingsmanager", "File types")],
                                             []],

                                             //: A settings subcategory
                           "ft_behavior"  : [qsTranslate("settingsmanager", "Behavior"),   "PQBehavior",
                                             [qsTranslate("settingsmanager", "PDF"),
                                              qsTranslate("settingsmanager", "Archive"),
                                              qsTranslate("settingsmanager", "Video"),
                                              qsTranslate("settingsmanager", "Animated images"),
                                              qsTranslate("settingsmanager", "RAW images"),
                                              qsTranslate("settingsmanager", "Documents")],
                                             ["PDFQuality",
                                              "ExternalUnrar",
                                              "ArchiveControls",
                                              "ArchiveLeftRight",
                                              "VideoAutoplay",
                                              "VideoLoop",
                                              "VideoPreferLibmpv",
                                              "VideoThumbnailer",
                                              "VideoLeftRightJumpVideo",
                                              "VideoSpacePause",
                                              "AnimatedControls",
                                              "AnimatedLeftRight",
                                              "AnimatedSpacePause",
                                              "RAWUseEmbeddedIfAvailable",
                                              "DocumentControls",
                                              "DocumentLeftRight",
                                              "EscapeExitDocument",
                                              "EscapeExitArchive"]],
                           "ft_advanced"    : [qsTranslate("settingsmanager", "Advanced"), "PQAdvanced",
                                               [qsTranslate("settingsmanager", "Motion/Live photos"),
                                                qsTranslate("settingsmanager", "Photo spheres")],
                                                ["LoadMotionPhotos",
                                                 "LoadAppleLivePhotos",
                                                 "MotionPhotoPlayPause",
                                                 "MotionSpacePause",
                                                 "CheckForPhotoSphere",
                                                 "EscapeExitSphere"]]
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
                           "sc_behavior"  : [qsTranslate("settingsmanager", "Behavior"),   "PQShortcutsBehavior",
                                             [qsTranslate("settingsmanager", "Move image with mouse"),
                                              qsTranslate("settingsmanager", "Double click"),
                                              qsTranslate("settingsmanager", "Scroll speed"),
                                              qsTranslate("settingsmanager", "Hide mouse cursor")],
                                             ["UseMouseWheelForImageMove",
                                              "UseMouseLeftButtonForImageMove",
                                              "DoubleClickThreshold",
                                              "FlickAdjustSpeed",
                                              "FlickAdjustSpeedSpeedup",
                                              "HideCursorTimeout",
                                              "EscapeExitDocument",
                                              "EscapeExitArchive ",
                                              "EscapeExitBarcodes",
                                              "EscapeExitFilter",
                                              "EscapeExitSphere"]]
                       }],

        /**************************************************************************************************************************/

        "manage" : [qsTranslate("settingsmanager", "Manage"),
                    {

                                        //: A settings subcategory
                        "ss_session" : [qsTranslate("settingsmanager", "Session"),   "PQSession",
                                        [qsTranslate("settingsmanager", "Single instance"),
                                         qsTranslate("settingsmanager", "Reopen last image"),
                                         qsTranslate("settingsmanager", "Remember changes"),
                                         qsTranslate("settingsmanager", "Tray Icon"),
                                         qsTranslate("settingsmanager", "Reset when hiding")],
                                         ["AllowMultipleInstances",
                                          "RememberLastImage",
                                          "RememberZoomRotationMirror",
                                          "PreserveZoom",
                                          "PreserveRotation",
                                          "PreserveMirror",
                                          "TrayIcon",
                                          "TrayIconMonochrome",
                                          "TrayIconHideReset"]],

                                       //: A settings subcategory
                        "mn_config" : [qsTranslate("settingsmanager", "Configuration"), "PQConfiguration",
                                       [qsTranslate("settingsmanager", "Reset settings and shortcuts"),
                                        qsTranslate("settingsmanager", "Export/Import configuration")],
                                       []]
                    }],

        /**************************************************************************************************************************/

        "other" : [qsTranslate("settingsmanager", "Other"),
                    {
                        "ot_extensions" : [qsTranslate("settingamanager", "Extensions"), "PQExtensions",
                                            [qsTranslate("settingsmanager", "Extensions")],
                                            ["Extensions"]],

                                        //: A settings subcategory
                        "ot_filedialog" : [qsTranslate("settingsmanager", "File dialog"),   "PQFileDialog",
                                           [qsTranslate("settingsmanager", "Layout"),
                                            qsTranslate("settingsmanager", "Show hidden files and folders"),
                                            qsTranslate("settingsmanager", "Tooltip with Details"),
                                            //: The location here is a folder path
                                            qsTranslate("settingsmanager", "Remember previous location"),
                                            qsTranslate("settingsmanager", "Only select with single click"),
                                            qsTranslate("settingsmanager", "Sections"),
                                            qsTranslate("settingsmanager", "Drag and drop"),
                                            qsTranslate("settingsmanager", "Thumbnails"),
                                            qsTranslate("settingsmanager", "Padding"),
                                            qsTranslate("settingsmanager", "Folder thumbnails"),
                                            qsTranslate("settingsmanager", "Preview")],
                                           ["Layout",
                                            "ShowHiddenFilesFolders",
                                            "DetailsTooltip",
                                            "KeepLastLocation",
                                            "SingleClickSelect",
                                            "Places",
                                            "Devices",
                                            "PlacesWidth",
                                            "DragDropFileviewGrid",
                                            "DragDropPlaces",
                                            "DragDropFileviewList",
                                            "Thumbnails",
                                            "ThumbnailsScaleCrop",
                                            "ElementPadding",
                                            "FolderContentThumbnails",
                                            "FolderContentThumbnailsSpeed",
                                            "FolderContentThumbnailsLoop",
                                            "FolderContentThumbnailsAutoload",
                                            "FolderContentThumbnailsScaleCrop",
                                            "Preview",
                                            "PreviewBlur",
                                            "PreviewMuted",
                                            "PreviewColorIntensity",
                                            "PreviewHigherResolution",
                                            "PreviewCropToFit"]],

                                       //: A settings subcategory
                        "ot_slideshow" : [qsTranslate("settingsmanager", "Slideshow"), "PQSlideshow",
                                          [qsTranslate("settingsmanager", "Animation"),
                                           qsTranslate("settingsmanager", "Interval"),
                                           qsTranslate("settingsmanager", "Loop"),
                                           qsTranslate("settingsmanager", "Shuffle"),
                                           qsTranslate("settingsmanager", "Status info and window buttons"),
                                           qsTranslate("settingsmanager", "Include subfolders"),
                                           qsTranslate("settingsmanager", "Music file")],
                                          ["ImageTransition",
                                           "TypeAnimation",
                                           "Time",
                                           "Loop",
                                           "Shuffle",
                                           "HideWindowButtons",
                                           "HideLabels",
                                           "MusicFile",
                                           "IncludeSubFolders"]]
                    }]

    }

    content: [

        SplitView {

            width: settingsmanager_top.width
            height: settingsmanager_top.contentHeight

            // Show larger handle with triple dash
            handle: Rectangle {
                implicitWidth: 5
                implicitHeight: 5
                color: SplitHandle.hovered ? PQCLook.baseColorActive : PQCLook.baseColorHighlight   // qmllint disable unqualified
                Behavior on color { ColorAnimation { duration: 200 } }
                Image {
                    y: (parent.height-height)/2
                    width: parent.implicitWidth
                    height: parent.implicitHeight
                    sourceSize: Qt.size(width, height)
                    source: "image://svg/:/" + PQCLook.iconShade + "/handle.svg" // qmllint disable unqualified
                }
            }

            PQCategory {

                id: sm_category

                SplitView.minimumWidth: 100
                SplitView.preferredWidth: 250

                categories: settingsmanager_top.categories

                height: settingsmanager_top.contentHeight

                selectedCategories: ["interface", "if_interface"]
                onSelectedCategoriesChanged: {
                    fullscreenitem.forceActiveFocus()   // qmllint disable unqualified
                }

                function callConfirmIfUnsavedChanged(cat: string, index: int) : bool {
                    return settingsmanager_top.confirmIfUnsavedChanged(cat, index)
                }

            }

            Item {

                id: rightsidesettings

                SplitView.minimumWidth: 400
                SplitView.fillWidth: true

                height: settingsmanager_top.contentHeight

                Loader {
                    id: settingsloader
                    anchors.fill: parent
                    anchors.bottomMargin: 30
                    clip: true
                    asynchronous: true
                    source: "settings/" + sm_category.selectedCategories[0] + "/" + settingsmanager_top.categories[sm_category.selectedCategories[0]][1][sm_category.selectedCategories[1]][1] + "Settings.qml"
                    onStatusChanged: {
                        if(status === Loader.Ready)
                            loadingsettings.hide()
                        else
                            loadingsettings.showBusy()
                    }
                }

                PQWorking {
                    id: loadingsettings
                    anchors.fill: parent
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    y: parent.height-29
                    color: PQCLook.baseColorHighlight // qmllint disable unqualified
                }

                PQTextS {
                    x: 5
                    y: parent.height-29
                    height: 29
                    verticalAlignment: Text.AlignVCenter
                    font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                    text: qsTranslate("settingsmanager", "Ctrl+S = Apply changes, Ctrl+R = Revert changes, Esc = Close")
                }

            }

        }

    ]

    Rectangle {
        id: settinginfomessage
        anchors.fill: parent
        color: PQCLook.transColor // qmllint disable unqualified
        visible: opacity>0
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: settinginfomessage.hide()
        }

        Rectangle {
            x: (parent.width-width)/2
            y: (parent.height-height)/2
            width: Math.min(600, parent.width)
            height: settinginfomessage_col.height+30
            radius: 10
            color: PQCLook.baseColor // qmllint disable unqualified

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            Column {

                id: settinginfomessage_col
                x: 15
                y: 15
                width: parent.width
                spacing: 15

                PQTextL {
                    id: settinginfomessage_txt
                    width: parent.width
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    lineHeight: 1.2
                }

                PQButton {
                    id: settingsinfobut
                    x: (parent.width-width)/2
                    text: genericStringClose
                    onClicked:
                        settinginfomessage.hide()
                }
            }
        }

        function show(txt: string) {
            settinginfomessage_txt.text = txt
            opacity = 1
        }

        function hide() {
            opacity = 0
        }

    }

    Rectangle {

        id: confirmUnsaved

        anchors.fill: parent
        color: PQCLook.transColor // qmllint disable unqualified

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
                font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
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
                        settingsloader.item.applyChanges() // qmllint disable missing-property

                        if(confirmUnsaved.cat == "-") {
                            settingsmanager_top.hide()
                        } else {
                            sm_category.laodFromUnsavedActions(confirmUnsaved.cat, confirmUnsaved.ind)
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
                            settingsmanager_top.hide()
                        } else {
                            sm_category.laodFromUnsavedActions(confirmUnsaved.cat, confirmUnsaved.ind)
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

        target: PQCNotifyQML

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "show") {

                if(param[0] === settingsmanager_top.thisis)
                    settingsmanager_top.show()

            } else if(what === "showSettings") {

                if(param[0] === "metadata")
                    sm_category.loadSpecificCategory("imageview","iv_metadata")
                else if(param[0] === "thumbnails")
                    sm_category.loadSpecificCategory("thumbnails","tb_image")
                else if(param[0] === "statusinfo")
                    sm_category.loadSpecificCategory("interface","if_statusinfo")
                else if(param[0] === "windowbuttons" || param[0] === "quickactions")
                    sm_category.loadSpecificCategory("interface","if_interface")

                // we need to call the loader to set all other variables there accordingly
                PQCNotifyQML.loaderShow("settingsmanager") // qmllint disable unqualified

            } else if(what === "hide") {

                if(param[0] === settingsmanager_top.thisis)
                    settingsmanager_top.hide()

            } else if(settingsmanager_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(settingsmanager_top.closeAnyMenu())
                        return

                    if(settingsmanager_top.passShortcutsToDetector) {
                        settingsmanager_top.passOnShortcuts(param[1], param[0])
                        return
                    }

                    if(settingsmanager_top.popoutWindowUsed && PQCSettings.interfacePopoutSettingsManagerNonModal) // qmllint disable unqualified
                        return

                    if(param[0] === Qt.Key_Escape) {

                        if(settingsloader.item.catchEscape)
                            settingsloader.item.handleEscape()
                        else if(confirmUnsaved.visible)
                            confirmCancel.clicked()
                        else if(settinginfomessage.visible)
                            settinginfomessage.hide()
                        else {
                            settingsmanager_top.button3.clicked()
                        }

                    } else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return) {

                        if(confirmUnsaved.visible)
                            confirmApply.clicked()
                        else if(settinginfomessage.visible)
                            settinginfomessage.hide()

                    } else if(param[0] === Qt.Key_S && param[1] === Qt.ControlModifier) {

                        if(confirmUnsaved.opacity < 1 && settinginfomessage.opacity < 1)
                            settingsloader.item.applyChanges()

                    } else if(param[0] === Qt.Key_R && param[1] === Qt.ControlModifier) {

                        if(confirmUnsaved.opacity < 1 && settinginfomessage.opacity < 1)
                            settingsloader.item.revertChanges()

                    } else if(param[0] === Qt.Key_F && param[1] === Qt.ControlModifier) {

                        sm_category.setFocusOnFilter()

                    } else if((param[0] === Qt.Key_Tab && param[1] === Qt.ControlModifier) || (param[0] === Qt.Key_Down && param[1] === Qt.AltModifier)) {

                        sm_category.gotoNextIndex("sub")

                    } else if(((param[0] === Qt.Key_Backtab || param[0] === Qt.Key_Tab) && param[1] === Qt.ShiftModifier+Qt.ControlModifier) ||
                               (param[0] === Qt.Key_Up && param[1] === Qt.AltModifier)) {

                        sm_category.gotoPreviousIndex("sub")

                    } else if(param[0] === Qt.Key_Down && param[1] === Qt.ControlModifier) {

                        sm_category.gotoNextIndex("main")

                    } else if(param[0] === Qt.Key_Up && param[1] === Qt.ControlModifier) {

                        sm_category.gotoPreviousIndex("main")

                    }

                }

            }

        }

    }

    function closeAnyMenu() {
        for(var i in allbuttons) {
            if(allbuttons[i].contextmenu.visible) {
                allbuttons[i].contextmenu.close()
                return true
            }
        }
        if(contextMenuOpen) {
            closeContextMenus()
            return true
        }

        return false
    }

    function confirmIfUnsavedChanged(cat: string, index: int) : bool {

        if(confirmUnsaved.cat != "")
            return true

        if(settingsloader.status !== Loader.Ready)
            return true

        if(!settingsloader.item.settingChanged) // qmllint disable missing-property
            return true

        if(PQCSettings.generalAutoSaveSettings) {
            settingsloader.item.applyChanges()
            return true
        }

        confirmUnsaved.cat = cat
        confirmUnsaved.ind = index
        confirmUnsaved.opacity = 1

        return false

    }

    function show() {
        opacity = 1
        if(popoutWindowUsed)
            settingsmanager_window.visible = true // qmllint disable unqualified

        if(settingsloader.status === Loader.Ready)
            settingsloader.item.revertChanges()

    }

    function hide() {
        closeAnyMenu()
        settingsloader.item.handleEscape() // qmllint disable missing-property
        confirmUnsaved.opacity = 0
        settingsmanager_top.opacity = 0
        if(popoutWindowUsed)
            settingsmanager_window.visible = false // qmllint disable unqualified
        PQCNotifyQML.loaderRegisterClose(thisis)
        PQCNotify.ignoreKeysExceptEnterEsc = false
        PQCNotify.ignoreKeysExceptEsc = false
        fullscreenitem.forceActiveFocus()
    }

}
