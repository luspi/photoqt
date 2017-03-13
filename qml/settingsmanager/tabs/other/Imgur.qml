import QtQuick 2.3
import QtQuick.Controls 1.2
import Imgur 1.0

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
                        text: qsTr("Authenticated with account:")
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
                        text: "(" + qsTr("authenticated on:") + " " + datetime + ")"
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
                        onClickedButton: {
                            imgurwebview.show()
                            imgurwebview.setUrl(shareonline_imgur.authorizeUrlForPin())
                        }
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

            }

        }

    }

    Connections {
        target: imgurwebview
        onObtainedPin: {
            var ret = shareonline_imgur.authorizeHandlePin(pin)
            if(ret == Imgur.NOERROR) {
                authenticatedwith.text = shareonline_imgur.getAccountUsername()
                authenticationDateTime.datetime = shareonline_imgur.getAuthDateTime()
            }
        }
        onErrorEncountered:
            console.error("An error occured authenticating with imgur.com:", msg)

    }

    function setData() {

        shareonline_imgur.authAccount()

        if(shareonline_imgur.authAccount() == Imgur.NOERROR) {
            authenticatedwith.text = shareonline_imgur.getAccountUsername()
            authenticationDateTime.datetime = shareonline_imgur.getAuthDateTime()
        } else
            authenticatedwith.text = ""

    }

    function saveData() {
    }

}
