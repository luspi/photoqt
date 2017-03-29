import QtQuick 2.4
import "../elements"

Rectangle {

    color: colour.fadein_slidein_block_bg

    // Visibility handlers
    visible: false
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 300 } }
    onOpacityChanged: {
        if(opacity == 0) visible = false
        else visible = true
    }

    // Catch mouse events (background)
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: hide()
    }

    // Outer content rectangle
    Rectangle {

        // Geometry
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: 600
        height: 500

        // Some styling
        color: colour.fadein_slidein_bg
        border.width: 1
        border.color: colour.fadein_slidein_border
        radius: global_element_radius

        // Click on content does nothing (overrides big MouseArea above)
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        // Inner content rectangle
        Rectangle {

            id: contrect

            // same as outer rectangle with margin
            anchors.fill: parent
            anchors.margins: 10
            color: "transparent"

            // Column content
            Column {

                spacing: 20

                // some spacing at the top
                Rectangle {
                    color: "transparent"
                    width: contrect.width
                    height: 5
                }

                // Header
                Text {
                    text: qsTr("Export/Import settings and shortcuts")
                    color: "white"
                    font.pointSize: 18
                    width: contrect.width
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }

                // A short explanation text
                Text {
                    text: qsTr("Here you can export all settings and shortcuts into a single packed file and, e.g., import it in another installation of PhotoQt.")
                    color: "white"
                    width: contrect.width
                    font.pointSize: 12
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                // Separator line
                Rectangle {
                    color: "#55ffffff"
                    width: contrect.width
                    height: 1
                }

                // Button to export config to file
                CustomButton {
                    text: qsTr("Export everything to file")
                    x: (contrect.width-width)/2
                    fontsize: 18
                    onClickedButton: {
                        // execute export, return value is error message
                        var ret = getanddostuff.exportConfig()
                        // if there's an error message, display it
                        if(ret == "-") {
                            // do nothing, QFileDialog cancelled by user
                        } else if(ret != "") {
                            errormsg.error = ret
                            errormsg.exp = true
                            errormsg.show()
                        // else hide element
                        } else
                            hide()
                    }
                }

                // Separator line
                Rectangle {
                    color: "#55ffffff"
                    width: contrect.width
                    height: 1
                }

                // Selector for a file
                CustomFileSelect {
                    id: importfilename
                    x: (contrect.width-width)/2
                    width: 400
                }

                // Import selected config file
                CustomButton {
                    x: (contrect.width-width)/2
                    text: qsTr("Import settings and shortcuts")
                    enabled: importfilename.file!=""
                    fontsize: 18
                    onClickedButton: {
                        // Import files, return value is error message
                        var ret = getanddostuff.importConfig(importfilename.file)
                        // If error message, display error
                        if(ret != "") {
                            errormsg.exp = false
                            errormsg.error = ret
                            errormsg.show()
                        // else restart PhotoQt
                        } else
                            getanddostuff.restartPhotoQt(thumbnailBar.currentFile)
                    }
                }

                // Info text below import button
                Text {
                    color: enabled ? colour.text : colour.text_disabled
                    width: parent.width
                    enabled: importfilename.file!=""
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: qsTr("PhotoQt will attempt to automatically restart after a successful import!")
                }

                // Separator line
                Rectangle {
                    height: 1
                    width: parent.width
                    color: "white"
                }

                // Cancel and close
                CustomButton {
                    x: (parent.width-width)/2
                    fontsize: 15
                    text: qsTr("I don't want to do this")
                    onClickedButton: hide()
                }

            }

        }

    }

    // Error message box
    CustomConfirm {
        id: errormsg
        header: qsTr("Error")
        property string error: ""
        property bool exp: false
        description: (exp ? qsTr("Exporting the configuration file failed with the following error message:") : qsTr("Importing the configuration file failed with the following error message:")) + "<br><br>" + error
        rejectbuttontext: qsTr("Oh, okay")
        actAsErrorMessage: true
    }

    // Show element
    function show() {
        importfilename.clearText()
        opacity = 1
    }

    // Hide element
    function hide() {
        opacity = 0;
    }

}
