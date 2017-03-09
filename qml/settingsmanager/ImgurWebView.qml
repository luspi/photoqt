import QtQuick 2.3
import QtQuick.Controls 1.0
import QtWebKit 3.0

import "../elements"

Rectangle {

    id: top

    anchors.fill: parent
    color: "#ee000000"

    opacity: 0
    visible: opacity!=0
    // Animate element by controlling opacity
    Behavior on opacity { NumberAnimation { duration: 200; } }

    signal obtainedPin(var pin)
    signal errorEncountered(var msg)

    // Catch mouse events (background)
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: hide()
    }

    ScrollView {

        // Click on content does nothing (overrides big MouseArea above)
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        id:viewwebscroll
        width: Math.min(1200, parent.width-200)
        height: Math.min(800, parent.height-200)
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        visible: parent.opacity!=0
        WebView {
            id: webview
            url: ""
            anchors.fill: parent
            onUrlChanged: {
                var urlStr = url.toString()
                if(urlStr.indexOf("?error=") != -1) {
                    var msg = urlStr.split("?error=")[1].split("&")[0];
                    errorEncountered(msg)
                    stop()
                    hide()
                } else if(urlStr.indexOf("https://api.imgur.com/oauth2") == -1) {
                    errorEncountered("Invalid webpage")
                    stop()
                    hide()
                } else if(urlStr.indexOf("state=requestaccess&pin=") != -1) {
                    var pin = urlStr.split("state=requestaccess&pin=")[1]
                    obtainedPin(pin)
                    stop()
                    hide()
                }
            }
        }
    }

    Rectangle {
        id: loader
        color: "#88000000"
        anchors.fill: viewwebscroll
        opacity: webview.loading ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200; } }
        visible: opacity!=0
        Text {
            color: "white"
            font.pointSize: 50
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.fill: parent
            font.capitalization: Font.SmallCaps
            text: qsTr("Loading imgur.com") + (dotcount == 1 ? ".  " : (dotcount == 2 ? ".. " : "..."))
            property int dotcount: 1
            Timer {
                running: loader.visible
                interval: 200
                repeat: true
                onTriggered: {
                    parent.dotcount = (parent.dotcount+1)%3
                }
            }
        }

        CustomButton {
            text: qsTr("Cancel loading")
            y: 4*(parent.height-height)/5
            fontsize: 20
            x: (parent.width-width)/2
            onClickedButton: {
                webview.url = ""
                hide()
            }
        }

    }

    function setUrl(url) {
        webview.url = url
    }

    // Show element
    function show() {
        verboseMessage("WebView::show()", opacity + " to 1")
        webview.url = ""
        opacity = 1
    }
    // Hide element
    function hide() {
        verboseMessage("WebView::hide()", opacity + " to 0")
        opacity = 0
    }

}
