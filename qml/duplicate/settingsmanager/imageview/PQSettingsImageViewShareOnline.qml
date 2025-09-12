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
import PQCScriptsShareImgur
import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

PQSetting {

    id: set_shon

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "imgur.com")

            helptext: qsTranslate("settingsmanager",  "It is possible to share an image from PhotoQt directly to imgur.com. This can either be done anonymously or to an imgur.com account. For the former, no setup is required, after a successful upload you are presented with the URL to access and the URL to delete the image. For the latter, PhotoQt first needs to be authenticated to an imgur.com user account.")

            showLineAbove: false

        },

        PQText {
            x: -set_shon.indentWidth
            width: set_shon.contentWidth
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
            width: set_shon.contentWidth
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
                width: set_shon.contentWidth
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
            width: set_shon.contentWidth
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            font.weight: PQCLook.fontWeightBold
            color: "red"
            property string err: ""
            visible: err!=""
            text: qsTranslate("settingsmanager", "An error occured:") + " " + err
        }

    ]

    function handleEscape() {}

    function checkForChanges() {}

    function load() {}

    function applyChanges() {}

}
