/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.5
import QtQuick.Controls 1.4
import PImgur 1.0

import "../../../elements"
import "../../"

Entry {

    id: entrytop

    title: "imgur.com"
    helptext: em.pty+qsTr("Here you can connect PhotoQt to your imgur.com account for uploading images directly to it. Alternatively, you can\
 always upload images anonymously to imgur.com without any user account. In either case, PhotoQt will return the image URL to you.")

    // This variable is needed to avoid a binding loop of slider<->spinbox
    property int val: 20

    content: [

        SettingsText {
            //: Account refers to an imgur.com user account
            text: em.pty+qsTr("Authenticated with account") + ":"
            font.pointSize: 13
        },
        SettingsText {
            id: authenticatedwith
            text: ""
            font.bold: true
            font.pointSize: 13
        },
        SettingsText {
            //: As in "not authenticated with imgur.com user account"
            text: "[" + em.pty+qsTr("not authenticated") + "]"
            font.bold: true
            visible: authenticatedwith.text==""
            font.pointSize: 13
        },
        SettingsText {
            id: authenticationDateTime
            property string datetime: "1991-07-23, 13:31"
            //: As in "authenticated with imgur.com user account on 1991-07-23, 13:31"
            text: "(" + em.pty+qsTr("authenticated on") + ": " + datetime + ")"
            visible: authenticatedwith.text!=""
            font.pointSize: 11
        }

    ]

    content2: [

        CustomButton {
            text: (authenticatedwith.text==""
            //: Account refers to imgur.com user account
                    ? em.pty+qsTr("Connect to Account")
                      //: Account refers to imgur.com user account
                    : em.pty+qsTr("Connect to New Account"))
            onClickedButton:
                authbox.show()
        },
        CustomButton {
            //: Account refers to imgur.com user account
            text: em.pty+qsTr("Forget Account")
            enabled: authenticatedwith.text!=""
            onClickedButton: {
                shareonline_imgur.forgetAccount()
                authenticatedwith.text = shareonline_imgur.getAccountUsername()
                authenticationDateTime.datetime = shareonline_imgur.getAuthDateTime()
            }
        }

    ]

    content3: [

        Flow {

            id: authbox

            spacing: 10
            width: parent.width
            enabled: false
            clip: true
            Behavior on height { NumberAnimation { duration: variables.animationSpeed } }
            opacity: 0.1
            Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

            function show() {
                authbox.enabled = getanddostuff.checkIfConnectedToInternet();
                inetconnected.visible = !getanddostuff.checkIfConnectedToInternet();
                authpin.clear();
                opacity = 1
                lineeditAuthorizeUrl.text = shareonline_imgur.authorizeUrlForPin()
            }
            function hide() { opacity = 0.1; }

            Text {
                id: inetconnected
                color: colour.text_warning
                visible: false
                height: butopenlink.height
                verticalAlignment: Text.AlignVCenter
                text: em.pty+qsTr("Not connected to internet")
            }
            Text {
                color: enabled ? colour.text : colour.text_disabled
                height: butopenlink.height
                verticalAlignment: Text.AlignVCenter
                text: em.pty+qsTr("Go to this URL:")
            }
            CustomLineEdit {
                id: lineeditAuthorizeUrl
                width: 400
                readOnly: true
                text: ""
                emptyMessage: em.pty+qsTr("loading...")
            }
            CustomButton {
                id: butopenlink
                text: em.pty+qsTr("open link")
                onClickedButton: getanddostuff.openLink(shareonline_imgur.authorizeUrlForPin())
            }
            Text {
                color: enabled ? colour.text : colour.text_disabled
                height: butopenlink.height
                verticalAlignment: Text.AlignVCenter
                text: em.pty+qsTr("Paste PIN here") + ":"
            }
            CustomLineEdit {
                id: authpin
                width: 100
            }
            CustomButton {
                text: em.pty+qsTr("Connect")
                onClickedButton: authenticate()
            }
            Rectangle {
                color: "transparent"
                width: 1
            }
            CustomButton {
                text: em.pty+qsTr("Cancel")
                onClickedButton:
                    authbox.hide()
            }

        }

    ]

    function authenticate() {
        verboseMessage("SettingsManager/Other/Imgur", "authenticate()")
        authbox.enabled = false
        var ret = shareonline_imgur.authorizeHandlePin(authpin.getText())
        if(ret === PImgur.IMGUR_NOERROR) {
            authbox.hide()
            setData()
        } else {
            authbox.enabled = true
            verboseMessage("SettingsManager/Other/Imgur", "authenticate(): Error return value: " + ret)
        }
    }

    function setData() {

        shareonline_imgur.authAccount()

        if(shareonline_imgur.authAccount() === PImgur.IMGUR_NOERROR) {
            authenticatedwith.text = shareonline_imgur.getAccountUsername()
            authenticationDateTime.datetime = shareonline_imgur.getAuthDateTime()
        } else
            authenticatedwith.text = ""

    }

    function saveData() { }

}
