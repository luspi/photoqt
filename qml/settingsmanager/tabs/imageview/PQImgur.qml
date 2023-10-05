/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {

    id: set

    property bool authenticated: false

    //: A settings title about the margin around the main image
    title: em.pty+qsTranslate("settingsmanager_imageview", "imgur.com")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "Authorize PhotoQt with imgur.com account to upload images directly to user account.")
    content: [

        Column {

            spacing: 10

            PQText {
                id: account
                property string acc: ""
                text: em.pty+qsTranslate("settingsmanager_imageview", "Authenticated with user account:") + " <b>" + (acc=="" ? "---" : acc) + "</b>"
            }

            Item {
                width: 1
                height: 1
            }

            Row {

                spacing: 10

                PQButton {
                    visible: !authenticated
                    //: Written on button: authenticate with imgur.com account
                    text: em.pty+qsTranslate("settingsmanager_imageview", "Authenticate")
                    onClicked: {
                        Qt.openUrlExternally(handlingShareImgur.authorizeUrlForPin())
                        auth_part.height = auth_part.childrenRect.height
                        error.visible = false
                    }
                }

                PQButton {
                    visible: authenticated
                    //: The account is the connected account on imgur.com
                    text: em.pty+qsTranslate("settingsmanager_imageview", "Forget account")
                    onClicked: {
                        var ret = handlingShareImgur.forgetAccount()
                        if(ret == 0) {
                            account.acc = ""
                            authenticated = false
                            error.visible = false
                        } else {
                            error.err = ret
                            error.visible = true
                        }
                    }
                }

            }

            Column {

                id: auth_part

                height: 0
                Behavior on height { NumberAnimation { duration: 200 } }
                clip: true

                spacing: 10

                PQText {
                    width: set.contwidth
                    text: em.pty+qsTranslate("settingsmanager_imageview", "Switch to your browser and log into your imgur.com account. Then paste the displayed PIN in the field below. Click on the button above again to reopen the website.")
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                Row {

                    spacing: 10

                    PQLineEdit {
                        id: pinholder
                        placeholderText: "PIN"
                    }
                    PQButton {
                        text: genericStringSave
                        onClicked: {
                            var ret = handlingShareImgur.authorizeHandlePin(pinholder.text)
                            if(ret != 0) {
                                error.err = ret
                                error.visible = true
                            } else {
                                error.visible = false
                                account.acc = handlingShareImgur.getAccountUsername()
                                auth_part.height = 0
                            }
                        }
                    }
                }

            }

            PQText {
                id: error
                visible: false
                property int err: 0
                color: "red"
                text: em.pty+qsTranslate("settingsmanager_imageview", "An error occured:") + " " + err
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
        }

    }

    Component.onCompleted: {
        load()
    }

    Timer {
        id: loadBG
        interval: 0
        onTriggered: {
            handlingShareImgur.authAccount()
            if(handlingShareImgur.isAuthenticated()) {
                account.acc = handlingShareImgur.getAccountUsername()
                authenticated = true
            } else {
                account.acc = ""
                authenticated = false
            }
        }
    }

    function load() {
        loadBG.start()
    }

}
