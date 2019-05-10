import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "./filedialog"

Rectangle {

    id: filedialog_top

    x: 0
    y: 0
    width: parent.width
    height: parent.height

    opacity: 0
    visible: (opacity != 0)

    color: "#333333"

    property string currentDirectory: handlingFileDialog.getHomeDir()
    property var historyListDirectory: [handlingFileDialog.getHomeDir()]
    property int historyListIndex: 0

    function setCurrentDirectory(dir, addToHistory) {

        if(dir == currentDirectory)
            return

        currentDirectory = dir
        if(addToHistory === true || addToHistory === undefined) {

            // purge old history beyond current point (if not at end already)
            if(historyListIndex < historyListDirectory.length-1)
                historyListDirectory.splice(historyListIndex+1)

            historyListDirectory.push(dir)
            historyListIndex += 1

        }

    }

    Behavior on opacity { NumberAnimation { id: opacityAnim; duration: settings.imageTransition*150 } }
    Behavior on x { NumberAnimation { id: xAnim; duration: 0 } }
    Behavior on y { NumberAnimation { id: yAnim; duration: 0 } }

    SplitView {

        id: splitview

        anchors.fill: parent

        // the dragsource, used to distinguish between dragging new folder and reordering userplaces
        property string dragSource: ""

        Rectangle {

            id: leftcol

            width: 300

            color: "#22222222"

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked:
                    console.log("right clicked")
            }

            PQStandard {
                id: std
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
            }

            PQPlaces {
                anchors.fill: parent
                anchors.topMargin: std.height+15
                anchors.bottomMargin: dev.height+15
            }

            PQDevices {
                id: dev
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

            }

        }

        Item {

            id: rightcol

            Layout.fillWidth: true

            // used for dragging folders to userplaces
            property int dragItemIndex: -1

            PQBreadCrumbs {

                id: breadcrumbs

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

            }

            PQFileView {

                id: fileview

                anchors.fill: parent
                anchors.bottomMargin: tweaks.height
                anchors.topMargin: breadcrumbs.height

            }

            PQTweaks {

                id: tweaks

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

            }

        }

    }

    function showFileDialog() {
        // show in x direction
        if(transitionAnimation == "x") {
            xAnim.duration = 0
            filedialog_top.x = -filedialog_top.width
            xAnim.duration = settings.imageTransition*150
            filedialog_top.x = 0
        // show in y direction
        } else if(transitionAnimation == "y") {
            yAnim.duration = 0
            filedialog_top.y = -filedialog_top.height
            yAnim.duration = settings.imageTransition*150
            filedialog_top.y = 0
        // fade in image
        }
        filedialog_top.opacity = 1
    }

    function hideFileDialog() {
        // hide in x direction
        if(transitionAnimation == "x") {
            xAnim.duration = settings.imageTransition*150
            filedialog_top.x = width
        // hide in y direction
        } else if(transitionAnimation == "y") {
            yAnim.duration = settings.imageTransition*150
            filedialog_top.y = height
        }
        // fade out image
        filedialog_top.opacity = 0
    }

}
