import QtQuick

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

    property var selectedCategories: ["interface", "language"]

    property var categories: {

        //: A settings category
        "interface" : [qsTranslate("settingsmanager", "Interface"),
                       {
                                             //: A settings subcategory
                            "language"    : [qsTranslate("settingsmanager", "Language"),     "PQLanguage"],
                                             //: A settings subcategory
                            "background"  : [qsTranslate("settingsmanager", "Background"),   "PQBackground"],
                                             //: A settings subcategory
                            "popout"      : [qsTranslate("settingsmanager", "Popout"),       "PQPopout"],
                                             //: A settings subcategory
                            "edges"       : [qsTranslate("settingsmanager", "Edges"),        "PQEdges"],
                                             //: A settings subcategory
                            "contextmenu" : [qsTranslate("settingsmanager", "Context menu"), "PQContextMenu"],
                                             //: A settings subcategory
                            "statusinfo"  : [qsTranslate("settingsmanager", "Status info"),  "PQStatusInfo"],
                                             //: A settings subcategory
                            "window"      : [qsTranslate("settingsmanager", "Window"),       "PQWindow"],
                       }],

        //: A settings category
        "imageview" : [qsTranslate("settingsmanager", "Image view"),
                       {
                                             //: A settings subcategory
                            "image"       : [qsTranslate("settingsmanager", "Image"),        "PQImage"],
                                             //: A settings subcategory
                            "interaction" : [qsTranslate("settingsmanager", "Interaction"),  "PQInteraction"],
                                             //: A settings subcategory
                            "folder"      : [qsTranslate("settingsmanager", "Folder"),       "PQFolder"],
                                             //: A settings subcategory
                            "online"      : [qsTranslate("settingsmanager", "Share online"), "PQShareOnline"]
                       }],

        //: A settings category
        "thumbnails" : [qsTranslate("settingsmanager", "Thumbnails"),
                        {
                                                //: A settings subcategory
                            "look"           : [qsTranslate("settingsmanager", "Look"),              "PQLook"],
                                                //: A settings subcategory
                            "behavior"       : [qsTranslate("settingsmanager", "Behavior"),          "PQBehavior"]
                        }],

        //: A settings category
        "metadata" : [qsTranslate("settingsmanager", "Metadata"),
                      {
                                              //: A settings subcategory
                            "labels"       : [qsTranslate("settingsmanager", "Labels"),        "PQLabels"],
                                              //: A settings subcategory
                            "behavior"     : [qsTranslate("settingsmanager", "Behavior"),      "PQBehavior"],
                                              //: A settings subcategory
                            "facetags"     : [qsTranslate("settingsmanager", "Face tags"),     "PQFaceTags"]
                      }],

        //: A settings category
        "session" : [qsTranslate("settingsmanager", "Session"),
                     {
                                          //: A settings subcategory
                         "instance"    : [qsTranslate("settingsmanager", "Instance"),   "PQInstance"],
                                          //: A settings subcategory
                         "remember"    : [qsTranslate("settingsmanager", "Remember"),   "PQRemember"],
                                          //: A settings subcategory
                         "trayicon"    : [qsTranslate("settingsmanager", "Tray icon"),  "PQTrayIcon"]
                     }],

        //: A settings category
        "filetypes" : [qsTranslate("settingsmanager", "File types"),
                       {
                                          //: A settings subcategory
                           "filetypes" : [qsTranslate("settingsmanager", "File types"), "PQFileTypes"],
                                          //: A settings subcategory
                           "tweaks"    : [qsTranslate("settingsmanager", "Behavior"),   "PQBehavior"]
                       }],

        //: A settings category
        "shortcuts" : [qsTranslate("settingsmanager", "Keyboard & Mouse"),
                       {
                                          //: A settings subcategory
                           "shortcuts" : [qsTranslate("settingsmanager", "Shortcuts"),  "PQShortcuts"],
                                          //: A settings subcategory
                           "behavior"  : [qsTranslate("settingsmanager", "Behavior"),   "PQBehavior"]
                       }]


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
                    text: qsTranslate("settingsmanager", "Ctrl+S = Apply changes, Ctrl+R = Revert changes, Esc = Close")
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
        PQCNotify.ignoreKeysExceptEnterEsc = false
    }

}
