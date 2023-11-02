import QtQuick
import QtQuick.Controls

import PQCScriptsShareImgur
import PQCNotify

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - imgur.com connection

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    property bool settingChanged: false

    Column {

        id: contcol

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "imgur.com")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "It is possible to share an image from PhotoQt directly to imgur.com. This can either be done anonymously or to an imgur.com account. For the former, no setup is required, after a successful upload you are presented with the URL to access and the URL to delete the image. For the latter, PhotoQt first needs to be authenticated to an imgur.com user account.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQText {
            width: setting_top.width
            font.weight: PQCLook.fontWeightBold
            text: qsTranslate("settingsmanager", "Note that any change here is saved immediately!")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQTextL {
            id: account
            x: (parent.width-width)/2
            visible: acc!=""
            property string acc: ""
            text: qsTranslate("settingsmanager", "Authenticated with user account:") + " <b>" + acc + "</b>"
        }

        Item {
            visible: account.acc!=""
            width: 1
            height: 10
        }

        PQButton {
            x: (parent.width-width)/2
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
        }

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
                width: setting_top.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTranslate("settingsmanager", "Switch to your browser and log into your imgur.com account. Then paste the displayed PIN in the field below. Click on the button above again to reopen the website.")
            }

            Row {
                id: authpinrow
                x: (parent.width-width)/2
                spacing: 5
                PQLineEdit {
                    id: pinholder
                    placeholderText: "PIN"
                    onControlActiveFocusChanged:
                        PQCNotify.ignoreKeysExceptEnterEsc = controlActiveFocus
                }
                PQButton {
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

        }

        PQText {
            id: error
            width: setting_top.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            font.weight: PQCLook.fontWeightBold
            color: "red"
            property string err: ""
            visible: err!=""
            text: qsTranslate("settingsmanager", "An error occured:") + " " + err
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

    Component.onDestruction:
        PQCNotify.ignoreKeysExceptEnterEsc = false

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
