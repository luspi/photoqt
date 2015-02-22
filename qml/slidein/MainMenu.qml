import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

    id: mainmenu

    // Background/Border color
    color: "#AA000000"
    border.width: 1
    border.color: "#55bbbbbb"

    // Set position (we pretend that rounded corners are along the bottom edge only, that's why visible y is off screen)
    x: mainmenu.width-width-100
    y: -height

    // Adjust size
    width: 350
    height: view.contentHeight+3*radius

    // Corner radius
    radius: 10

    // [id, icon, text]
    property var allitems: [["open", "open", "Open File"],
        ["settings", "settings", "Settings"],
        ["wallpaper", "settings", "Set as Wallpaper"],
        ["slideshow", "slideshow", "Start Slideshow"],
        ["filter", "filter", "Filter Images in Folder"],
        ["metadata", "metadata", "Show/Hide Metadata"],
        ["about", "about", "About PhotoQt"],
        ["hide", "quit", "Hide (System Tray)"],
        ["quit", "quit", "Quit"]]

    // All entries in the menu
    ListView {

        id: view

        // No scrolling/flicking!
        boundsBehavior: ListView.StopAtBounds

        // Same size as parent
        anchors {
            fill: parent
            margins: mainmenu.radius
            topMargin: 2*mainmenu.radius
        }

        // Simple model and delegate
        model: allitems.length
        delegate: deleg

    }

    Component {

        id: deleg

        // Icon and entry text in a row
        Row {

            // Icon
            Image {
                y: 2.5
                width: val.height*0.5
                height: val.height*0.5
                sourceSize.width: width
                sourceSize.height: height
                source: "qrc:/img/mainmenu/" + allitems[index][1] + ".png"
            }

            // Entry text
            Text {

                id: val;

                color: "#dddddd";
                lineHeight: 1.5

                font.pointSize: 10
                font.bold: true

                // The spaces guarantee a bit of space betwene icon and text
                text: "  " + allitems[index][2];

                MouseArea {

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: val.color = "#ffffff"
                    onExited: val.color = "#cccccc"
                    onClicked: mainmenuDo(allitems[index][0])

                }

            }

            // This is a second text entry - currently only used for Slideshow Quickstart entry (two in a row)
            Text {

                id: val2

                visible: allitems[index][0] === "slideshow"

                color: "#dddddd"
                lineHeight: 1.5

                font.pointSize: 10
                font.bold: true

                text: " (Quickstart)"

                MouseArea {

                    anchors.fill: parent
                    hoverEnabled: true

                    cursorShape: Qt.PointingHandCursor
                    onEntered: val2.color = "#ffffff"
                    onExited: val2.color = "#cccccc"

                }
            }

        }

    }

    // Do stuff on clicking on an entry
    function mainmenuDo(what) {

        // Hide menu when an entry was clicked
        if(what !== "metadata") hideMainmenu.start()

        if(what === "open") openFile()

        else if(what === "quit") Qt.quit();

        else if(what == "about") about.showAbout()

        else if(what === "metadata") {
            if(metaData.x > -2*metaData.radius) {
                metaData.uncheckCheckbox()
                background.hideMetadata()
            } else {
                metaData.checkCheckbox()
                background.showMetadata()
            }
        }
    }

    // 'Hide' animation
    PropertyAnimation {
        id: hideMainmenu
        target: mainmenu
        property: "y"
        to: -mainmenu.height
    }

}
