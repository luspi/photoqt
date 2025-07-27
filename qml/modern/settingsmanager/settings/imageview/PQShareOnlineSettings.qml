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

import QtQuick
import QtQuick.Controls
import PQCScriptsShareImgur
import PhotoQt.Modern
import PhotoQt.Shared

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:
// - imgur.com connection

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    PQScrollManager { flickable: setting_top }

    property bool settingChanged: false
    property bool settingsLoaded: false
    property bool catchEscape: butauth.contextmenu.visible || butsave.contextmenu.visible

    Column {

        id: contcol

        width: parent.width

        spacing: 10

        PQSetting {

            id: set_imgur

            title: "imgur.com"
            showResetButton: false

            helptext: qsTranslate("settingsmanager", "It is possible to share an image from PhotoQt directly to imgur.com. This can either be done anonymously or to an imgur.com account. For the former, no setup is required, after a successful upload you are presented with the URL to access and the URL to delete the image. For the latter, PhotoQt first needs to be authenticated to an imgur.com user account.")

            content: [

                PQText {
                    width: set_imgur.rightcol
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    // font.weight: PQCLook.fontWeightBold
                    text: qsTranslate("settingsmanager", "Note that any change here is saved immediately!")
                },

                Item {
                    width: 1
                    height: 10
                },

                PQTextL {
                    id: account
                    width: set_imgur.rightcol
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    visible: acc!=""
                    property string acc: ""
                    text: qsTranslate("settingsmanager", "Authenticated with user account:") + " <b>" + acc + "</b>"
                },

                Item {
                    visible: account.acc!=""
                    width: 1
                    height: 10
                },

                PQButton {
                    id: butauth
                    text: account.acc == "" ?
                              //: Written on button, used as in: Authenticate with user account
                              qsTranslate("settingsmanager", "Authenticate") :
                              //: Written on button, used as in: Forget user account
                              qsTranslate("settingsmanager", "Forget account")
                    onClicked: {
                        if(account.acc == "") {
                            Qt.openUrlExternally(PQCScriptsShareImgur.authorizeUrlForPin()) 
                            authcol.authshow = true
                            error.err = ""
                        } else {
                            var ret = PQCScriptsShareImgur.forgetAccount()
                            if(ret === 0) {
                                account.acc = ""
                                error.err = ""
                            } else {
                                error.err = ret
                            }
                        }
                    }
                },

                Column {

                    id: authcol
                    spacing: 10

                    clip: true
                    height: authshow ? (authinfotxt.height+authpinrow.height+authspacer.height+20) : 0
                    Behavior on height { NumberAnimation { duration: 200 } }

                    property bool authshow: false

                    Item {
                        id: authspacer
                        width: 1
                        height: 10
                    }

                    PQText {
                        id: authinfotxt
                        width: set_imgur.rightcol
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTranslate("settingsmanager", "Switch to your browser and log into your imgur.com account. Then paste the displayed PIN in the field below. Click on the button above again to reopen the website.")
                    }

                    Row {
                        id: authpinrow
                        spacing: 5

                        PQLineEdit {
                            id: pinholder
                            placeholderText: "PIN"
                        }
                        PQButton {
                            id: butsave
                            text: genericStringSave
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.BusyCursor
                            onClicked: {
                                authpinrow.enabled = false
                                var ret = PQCScriptsShareImgur.authorizeHandlePin(pinholder.text) 
                                if(ret !== 0) {
                                    authpinrow.enabled = true
                                    error.err = ret
                                } else {
                                    authpinrow.enabled = true
                                    error.err = ""
                                    account.acc = PQCScriptsShareImgur.getAccountUsername()
                                    authcol.authshow = false
                                }
                            }
                        }
                    }

                },

                PQText {
                    id: error
                    width: set_imgur.rightcol
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.weight: PQCLook.fontWeightBold 
                    color: "red"
                    property string err: ""
                    visible: err!=""
                    text: qsTranslate("settingsmanager", "An error occured:") + " " + err
                }

            ]

        }

    }

    PQWorking {
        parent: setting_top.parent
        id: busy
    }

    Timer {
        id: loadBG
        interval: 200
        onTriggered: {
            PQCScriptsShareImgur.authAccount() 
            if(PQCScriptsShareImgur.isAuthenticated()) {
                account.acc = PQCScriptsShareImgur.getAccountUsername()
            } else {
                account.acc = ""
            }
            busy.hide()
        }
    }

    Component.onCompleted:
        load()

    function handleEscape() {
        butauth.contextmenu.close()
        butsave.contextmenu.close()
    }

    function load() {
        busy.showBusy()
        loadBG.restart()
    }

    function applyChanges() {
    }

    function revertChanges() {
        load()
    }

}
