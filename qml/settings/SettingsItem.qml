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

        anchors.fill: parent
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
