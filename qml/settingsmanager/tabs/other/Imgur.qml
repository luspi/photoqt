import QtQuick 2.4
import QtQuick.Controls 1.3
import PImgur 1.0

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("imgur.com")
            helptext: qsTr("Here you can connect PhotoQt to your imgur.com account for uploading images directly to it. Alternatively, you can always upload images anonymously to imgur.com. In either case, PhotoQt will return the image URL to you.")

        }

        EntrySetting {

            id: entry

            // This variable is needed to avoid a binding loop of slider<->spinbox
            property int val: 20

            Column {

                spacing: 5

                Rectangle {
                    color: "transparent"
                    width: 1
                    height: 1
                }

                Row {

                    spacing: 10

                    SettingsText {
                        text: qsTr("Authenticated with account") + ":"
                        font.pointSize: 13
                    }
                    SettingsText {
                        id: authenticatedwith
                        text: ""
                        font.bold: true
                        font.pointSize: 13
                    }
                    SettingsText {
                        text: "[" + qsTr("not authenticated") + "]"
                        font.bold: true
                        visible: authenticatedwith.text==""
                        font.pointSize: 13
                    }
                    SettingsText {
                        id: authenticationDateTime
                        property string datetime: "1991-07-23, 13:31"
                        text: "(" + qsTr("authenticated on") + ": " + datetime + ")"
                        visible: authenticatedwith.text!=""
                        font.pointSize: 11
                    }

                }

                Rectangle {
                    color: "transparent"
                    width: 1
                    height: 1
                }

                Row {

                    spacing: 10

                    CustomButton {
                        //: Text on button to connect PhotoQt with an imgur.com user account
                        text: (authenticatedwith.text=="" ? qsTr("Connect to Account") : qsTr("Connect to New Account"))
                        onClickedButton:
                            authbox.show()
                    }
                    CustomButton {
                        //: Text on button to forget PhotoQt's connection with an imgur.com user account
                        text: qsTr("Forget Account")
                        enabled: authenticatedwith.text!=""
                        onClickedButton: {
                            shareonline_imgur.forgetAccount()
                            authenticatedwith.text = shareonline_imgur.getAccountUsername()
                            authenticationDateTime.datetime = shareonline_imgur.getAuthDateTime()
                        }
                    }

                }

                Rectangle {
                    color: "transparent"
                    width: 1
                    height: 1
                }


                Rectangle {

                    id: authbox

                    color: "transparent"

                    width: childrenRect.width
                    height: 0
                    clip: true
                    property int h: childrenRect.height
                    Behavior on height { NumberAnimation { duration: 200 } }
                    visible: (height!=0)

                    function show() {
                        authbox.enabled = getanddostuff.checkIfConnectedToInternet();
                        inetconnected.visible = !getanddostuff.checkIfConnectedToInternet();
                        authpin.clear();
                        height = h;
                        lineeditAuthorizeUrl.text = shareonline_imgur.authorizeUrlForPin()
                    }
                    function hide() { height = 0; }

                    Row {

                        spacing: 10

                        Text {
                            id: inetconnected
                            color: colour.text_warning
                            y: (parent.height-height)/2
                            text: qsTr("Not connected to internet")
                        }
                        Text {
                            color: enabled ? colour.text : colour.text_disabled
                            y: (parent.height-height)/2
                            text: qsTr("Go to this URL") + ":"
                        }
                        CustomLineEdit {
                            id: lineeditAuthorizeUrl
                            width: 500
                            readOnly: true
                            text: ""
                            emptyMessage: qsTr("loading...")
                        }
                        CustomButton {
                            text: qsTr("open link")
                            onClickedButton: getanddostuff.openLink(shareonline_imgur.authorizeUrlForPin())
                        }
                        Text {
                            color: enabled ? colour.text : colour.text_disabled
                            y: (parent.height-height)/2
                            text: qsTr("Paste PIN here") + ":"
                        }
                        CustomLineEdit {
                            id: authpin
                            width: 100
                        }
                        CustomButton {
                            text: qsTr("Connect")
                            onClickedButton: authenticate()
                        }
                        Rectangle {
                            color: "transparent"
                            width: 1
                        }
                        CustomButton {
                            text: qsTr("Cancel")
                            onClickedButton:
                                authbox.hide()
                        }

                    }

                }

            }

        }

    }

    function authenticate() {
        authbox.enabled = false
        var ret = shareonline_imgur.authorizeHandlePin(authpin.getText())
        if(ret == PImgur.IMGUR_NOERROR) {
            authbox.hide()
            setData()
        } else {
            authbox.enabled = true
            verboseMessage("SettingsManager/Imgur/authenticate", "authenticate() error return value:",ret)
        }
    }

    function setData() {

        shareonline_imgur.authAccount()

        if(shareonline_imgur.authAccount() == PImgur.IMGUR_NOERROR) {
            authenticatedwith.text = shareonline_imgur.getAccountUsername()
            authenticationDateTime.datetime = shareonline_imgur.getAuthDateTime()
        } else
            authenticatedwith.text = ""

    }

    function saveData() {
    }

}
