import QtQuick


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

    button2.text: "Revert changes"
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

    property var selectedCategories: ["interface", "language"]

    property var categories: {

        "interface" : ["Interface",
                       {
                           "language"     : ["Language",     "PQLanguage"],
                            "popout"      : ["Popout",       "PQPopout"],
                            "background"  : ["Background",   "PQBackground"],
                            "contextmenu" : ["Context menu", "PQContextMenu"],
                            "window"      : ["Window",       "PQWindow"],
                            "trayicon"    : ["Tray icon",    "PQTrayIcon"]
                       }],

        "imageview" : ["Image view",
                       {
                            "defaultlook"   : ["Default Look",        "PQDefaultLook"],     // margin, sizing, transparency, interpolation
                            "zoom"          : ["Zoom",                "PQZoom"],
                            "sortby"        : ["Sort by",             "PQSortBy"],
                            "behavior"      : ["Behavior",            "PQBehavior"],    // looping, hidemouse, animation?
                            "animation"     : ["Animation",           "PQAnimation"],
                            "mapprovider"   : ["Map provider",        "PQMapProvider"],
                            "mouse"         : ["Mouse",               "PQMouse"],
                            "floating"      : ["Floating navigation", "PQFloatingNavigation"],
                            "edge"          : ["Edge behavior",       "PQEdge"]
                       }],

        "thumbnails" : ["Thumbnails",
                        {
                            "look"           : ["Look",                "PQLook"],
                            "highlight"      : ["Highlight animation", "PQHighlight"],
                            "image"          : ["Thumbnail image",     "PQImage"],
                            "filenamelabel"  : ["Filename label",      "PQFilenameLabel"],
                            "disable"        : ["Disable",             "PQDisable"],
                            "tooltip"        : ["Tooltip",             "PQTooltip"],
                            "hideshow"       : ["Hide/Show",           "PQHideShow"],
                            "cache"          : ["Cache",               "PQCache"],
                            "excludefolders" : ["Exclude folders",     "PQExclude"],
                            "threads"        : ["Threads",             "PQThreads"]
                        }],

        "metadata" : ["Metadata",
                      {
                            "labels"       : ["Labels",        "PQLabels"],
                            "autorotation" : ["Auto rotation", "PQAutoRotation"],
                            "mapservice"   : ["Map service",   "PQMapService"],
                            "facetags"     : ["Face tags",     "PQFaceTags"]
                      }],

        "session" : ["Session",
                     {
                        "resetview"   : ["Reset view",        "PQReset"],
                        "remember"    : ["Remember",          "PQRemember"],
                        "reopen"      : ["Reopen last image", "PQReopen"],
                        "pixmapcache" : ["Pixmap cache",      "PQPixmapCache"]
                     }],

        "filetypes" : ["File types",
                       {"filetypes" : ["File types", "PQFileTypes"]}],
        "shortcuts" : ["Shortcuts",
                       {"shortcuts" : ["Shortcuts",  "PQShortcuts"]}]


    }

    property var categoryKeys: Object.keys(categories)

    content: [

        Row {

            spacing: 2

            PQMainCategory { id: sm_maincategory }

            /***********************************************************/

            Rectangle {
                width: 3
                height: settingsmanager_top.contentHeight
                color: PQCLook.baseColorHighlight
            }

            PQSubCategory { id: sm_subcategory }

            /***********************************************************/

            Rectangle {
                visible: sm_subcategory.visible
                width: 3
                height: settingsmanager_top.contentHeight
                color: PQCLook.baseColorHighlight
            }

            Item {

                height: settingsmanager_top.contentHeight
                width: settingsmanager_top.width - sm_maincategory.width - (sm_subcategory.visible ? sm_subcategory.width+8 : 0) - 16

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
                    text: "Ctrl+S = Apply changes, Ctrl+R = Revert changes, Esc = Close"
                }

            }

            /***********************************************************/

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
                text: "Unsaved changes"
            }

            PQText {
                x: (parent.width-width)/2
                width: 400
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: "The settings on this page have changed. Do you want to save or discard them?"
            }

            Row {

                x: (parent.width-width)/2

                spacing: 10

                PQButton {
                    id: confirmApply
                    text: "Apply"
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
                    text: "Discard"
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
                    text: "Cancel"
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

                        console.warn("Ctrl+S")

                        if(confirmUnsaved.opacity === 0)
                            settingsloader.item.applyChanges()

                    }

                }

            }

        }

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

        if(popout)
            settingsmanager_top.show()
    }

    function hide() {
        confirmUnsaved.opacity = 0
        settingsmanager_top.opacity = 0
        loader.elementClosed(thisis)
    }

}
