import QtQuick 2.3
import QtQuick.Controls 1.2

import "./"
import "../elements"

Rectangle {

    id: tabrect

    // Positioning and basic look
    anchors.fill: background
    color: colour_fadein_bg

    // Invisible at startup
    visible: false
    opacity: 0

    CustomTabView {

        id: view

        x: 0
        y: 0
        width: parent.width
        height: parent.height-butrow.height

        tabCount: 5     // We currently have 5 tabs in the settings

        Tab {

            id: look

            title: "Look and Feel"

            CustomTabView {

                subtab: true   // this is a subtab
                tabCount: 2    // and we have 2 tabs in it

                Tab {
                    title: "Basic"
                    TabLookAndFeelBasic { }
                }
                Tab {
                    title: "Advanced"
                    TabLookAndFeelAdvanced { }
                }
            }
        }

        Tab {

            title: "Thumbnails"

            CustomTabView {

                subtab: true
                tabCount: 2

                Tab {
                    title: "Basic"
                    TabThumbnailsBasic { }
                }
                Tab {
                    title: "Advanced"
                    TabThumbnailsAdvanced { }
                }
            }
        }

        Tab {

            title: "Details"
            TabDetails { }

        }

        Tab {

            title: "Other Settings"

            CustomTabView {

                subtab: true
                tabCount: 2

                Tab {
                    title: "Other"
                    TabOther { }
                }
                Tab {
                    title: "Filetypes"
                    TabFiletypes { }
                }
            }
        }

        Tab {

            title: "Shortcuts"
            TabShortcuts { }

        }

    }

    // Line between settings and buttons
    Rectangle {

        id: sep

        x: 0
        y: butrow.y-1
        height: 1
        width: parent.width

        color: colour_linecolour

    }

    // A rectangle holding the three buttons at the bottom
    Rectangle {

        id: butrow

        x: 0
        y: parent.height-40
        width: parent.width
        height: 40

        color: "#33000000"

        // Button to restore default settings - bottom left
        CustomButton {

            id: restoredefault

            x: 5
            y: 5
            height: parent.height-10

            text: "Restore Default Settings"

        }

        // Button to exit without saving - bottom right
        CustomButton {
            id: exitnosave

            x: parent.width-width-10
            y: 5
            height: parent.height-10

            text: "Exit and Discard Changes"

        }

        // Button to exit with saving - bottom right, next to exitnosave button
        CustomButton {
            id: exitsave

            x: exitnosave.x-width-10
            y: 5
            height: parent.height-10

            text: "Save Changes and Exit"

        }

    }

    function showSettings() {
        showAboutAni.start()
    }
    function hideSettings() {
        hideAboutAni.start()
    }

    PropertyAnimation {
        id: hideAboutAni
        target: tabrect
        property: "opacity"
        to: 0
        onStopped: {
            visible = false
            blocked = false
            if(image.url == "")
                openFile()
        }
    }

    PropertyAnimation {
        id: showAboutAni
        target: tabrect
        property: "opacity"
        to: 1
        onStarted: {
            visible = true
            blocked = true
        }
    }

}
