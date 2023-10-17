import QtQuick


import "../elements"

PQTemplateFullscreen {

    id: settingsmanager_top

    thisis: "settingsmanager"
    popout: PQCSettings.interfacePopoutSettingsManager
    shortcut: "__settings"

    title: qsTranslate("settingsmanager", "Settings Manager")

    property bool settingChanged: false

    onPopoutChanged:
        PQCSettings.interfacePopoutSettingsManager = popout

    button1.text: qsTranslate("settingsmanager", "Apply changes")
    button1.enabled: settingChanged
    button1.onClicked: applyChanges()

    button2.visible: true
    button2.text: genericStringClose
    button2.onClicked: hide()

    property var categories: {

        "interface" : ["Interface",
                       {
                           "language" : "Language",
                            "popout" : "Popout",
                            "background" : "Background",
                            "contextmenu" : "Context menu"
                       }],

        "window" : ["Window",
                    {
                        "windowmode" : "Window mode",
                        "windowdecoration" : "Window decoration",
                        "windowbuttons" : "Window buttons",
                        "windowmanagement" : "Window management",
                        "trayicon" : "Tray icon"
                    }],

        "navigation" : ["Navigation",
                        {
                            "mousewheel" : "Mouse wheel",
                            "floating" : "Floating navigation",
                            "edge" : "Edge behavior"
                        }],

        "imageview" : ["Image view",
                       {
                            "transparency" : "Transparency checkerboard",
                            "margin" : "Margin",
                            "interpolation" : "Interpolation",
                            "zoom" : "Zoom",
                            "sizing" : "Image sizing",
                            "sortby" : "Sort by",
                            "looping" : "Looping",
                            "hidemouse" : "Hide mouse",
                            "animation" : "Animation",
                            "mapprovider" : "Map provider"
                       }],

        "thumbnails" : ["Thumbnails",
                        {
                            "look" : "Look",
                            "highlight" : "Highlight animation",
                            "image" : "Thumbnail image",
                            "filenamelabel" : "Filename label",
                            "disable" : "Disable",
                            "tooltip" : "Tooltip",
                            "hideshow" : "Hide/Show",
                            "cache" : "Cache",
                            "excludefolders" : "Exclude folders",
                            "threads" : "Threads"
                        }],

        "metadata" : ["Metadata",
                      {
                            "labels" : "Labels",
                            "autorotation" : "Auto rotation",
                            "mapservice" : "Map service",
                            "facetags" : "Face tags"
                      }],

        "session" : ["Session",
                     {
                        "resetview" : "Reset view",
                        "remember" : "Remember",
                        "reopen" : "Reopen last image",
                        "pixmapcache" : "Pixmap cache"
                     }],

        "filetypes" : ["File types",
                       {"filetypes" : "File types"}],
        "shortcuts" : ["Shortcuts",
                       {"shortcuts" : "Shortcuts"}]


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
                width: 3
                height: settingsmanager_top.contentHeight
                color: PQCLook.baseColorHighlight
            }

            Item {
                height: settingsmanager_top.contentHeight
                width: settingsmanager_top.width - 400
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
                text: "There are still unsaved changes. Do you want to apply your changes or discard them before closing?"
            }

            Row {

                x: (parent.width-width)/2

                spacing: 10

                PQButton {
                    id: confirmApply
                    text: "Apply"
                    onClicked: {
                        applyChanges()
                        hide()
                    }
                }
                PQButton {
                    id: confirmDiscard
                    text: "Discard"
                    onClicked: {
                        settingChanged = false
                        hide()
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
                            confirmDiscard.clicked()
                        else
                            hide()
                    } else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return) {
                        if(confirmUnsaved.visible)
                            confirmApply.clicked()
                    }

                }

            }

        }

    }

    function show() {
        confirmUnsaved.opacity = 0
        opacity = 1
        if(popout)
            settingsmanager_top.show()
    }

    function applyChanges() {
        settingChanged = false
    }

    function hide() {
        if(settingChanged) {
            confirmUnsaved.opacity = 1
        } else {
            settingsmanager_top.opacity = 0
            loader.elementClosed(thisis)
        }
    }

}
