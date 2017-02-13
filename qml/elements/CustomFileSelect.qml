import QtQuick 2.3

Rectangle {

    id: ele_top

    // default sizing
    width: 300
    height: 30

    // no bg color
    color: "transparent"

    // this will hold any changed filepath
    property string file: filepath.text

    Rectangle {

        id: ed1

        // some geometry
        x: 3
        y: (parent.height-height)/2
        height: 30
        width: parent.width-selbut.width-6

        // some styling
        color: colour.element_bg_color_disabled
        radius: 5
        border.width: 1
        border.color: colour.element_border_color_disabled

        // Rectangle that will hold the selected filename
        Text {
            id: filepath
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            color: colour.text
            verticalAlignment: Text.AlignVCenter
            clip: true
            elide: Text.ElideLeft

            // Empty info message displayed when no file is selected
            Text {
                anchors.fill: parent
                color: colour.text_inactive
                opacity: 0.7
                verticalAlignment: Text.AlignVCenter
                visible: filepath.text == ""
                clip: true
                text: qsTr("Click here to select a configuration file")
            }

        }

        // Click on rectangle requests new file
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: getConfigFile()
        }

    }

    // Button to request new file
    CustomButton {
        id: selbut
        text: "..."
        x: ed1.x+ed1.width+3
        width: 50
        onClickedButton: getConfigFile()
    }

    // request user to select a new file
    function getConfigFile() {
        var startfolder = getanddostuff.getHomeDir()
        if(filepath.text != "")
            startfolder = filepath.text
        var str = getanddostuff.getFilename(qsTr("Select PhotoQt config file..."),startfolder,qsTr("PhotoQt Config Files") + " (*.pqt);;" + qsTr("All Files") + " (*.*)")
        if(str !== "")
            filepath.text = str
    }

    // clear file selection
    function clearText() {
        filepath.text = ""
    }

}
