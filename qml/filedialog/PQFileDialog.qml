import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "./parts"
import "../elements"

Rectangle {

    id: filedialog_top

    x: 0
    y: 0
    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: PQSettings.openPopoutElement ? 1 : 0
    visible: (opacity != 0)

    color: "#333333"

    property var historyListDirectory: [handlingFileDialog.getHomeDir()]
    property int historyListIndex: 0

    function setCurrentDirectory(dir, addToHistory) {

        if(dir == variables.openCurrentDirectory)
            return

        variables.openCurrentDirectory = dir
        if(addToHistory === true || addToHistory === undefined) {

            // purge old history beyond current point (if not at end already)
            if(historyListIndex < historyListDirectory.length-1)
                historyListDirectory.splice(historyListIndex+1)

            historyListDirectory.push(dir)
            historyListIndex += 1

        }

    }

    Behavior on opacity { NumberAnimation { id: opacityAnim; duration: (PQSettings.animations ? PQSettings.animationDuration*150 : 0) } }
    Behavior on x { NumberAnimation { id: xAnim; duration: 0 } }
    Behavior on y { NumberAnimation { id: yAnim; duration: 0 } }

    SplitView {

        id: splitview

        anchors.fill: parent

        // the dragsource, used to distinguish between dragging new folder and reordering userplaces
        property string dragSource: ""
        property string dragItemPath: ""

        Rectangle {

            id: leftcol

            width: 300

            color: "#22222222"

            Layout.minimumWidth: 200

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked:
                    rightclickmenu.popup()
            }

            PQMenu {

                id: rightclickmenu

                PQMenuItem {
                    text: PQSettings.openUserPlacesStandard ? em.pty+qsTranslate("filedialog", "Hide standard locations") : em.pty+qsTranslate("filedialog", "Show standard locations")
                    width: rightclickmenu.width
                    onTriggered: {
                        var old = PQSettings.openUserPlacesStandard
                        PQSettings.openUserPlacesStandard = !old
                    }
                }

                PQMenuItem {
                    text: PQSettings.openUserPlacesUser ? em.pty+qsTranslate("filedialog", "Hide favorite locations") : em.pty+qsTranslate("filedialog", "Show favorite locations")
                    width: rightclickmenu.width
                    onTriggered: {
                        var old = PQSettings.openUserPlacesUser
                        PQSettings.openUserPlacesUser = !old
                    }
                }

                PQMenuItem {
                    text: PQSettings.openUserPlacesVolumes ? em.pty+qsTranslate("filedialog", "Hide storage devices") : em.pty+qsTranslate("filedialog", "Show storage devices")
                    width: rightclickmenu.width
                    onTriggered: {
                        var old = PQSettings.openUserPlacesVolumes
                        PQSettings.openUserPlacesVolumes = !old
                    }
                }

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
                id: upl
                anchors.fill: parent
                anchors.topMargin: std.visible ? std.height+15 : 0
                anchors.bottomMargin: dev.visible ? dev.height+15 : 0
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

            Layout.minimumWidth: 200

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

                PQPreview {

                    z: -1

                    anchors.fill: parent
                    filePath: fileview.model.getFileIsDir(fileview.currentlyHoveredIndex) ? "" : fileview.model.getFilePath(fileview.currentlyHoveredIndex)

                }

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

    Connections {
        target: loader
        onFiledialogPassOn: {
            if(what == "show")
                filedialog_top.showFileDialog()
            else if(what == "keyevent")
                fileview.keyEvent(param[0], param[1])
        }
    }

    function showFileDialog() {
        if(!PQSettings.openPopoutElement) {
            // show in x direction
            if(PQSettings.animationType == "x") {
                xAnim.duration = 0
                filedialog_top.x = -filedialog_top.width
                xAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                filedialog_top.x = 0
            // show in y direction
            } else if(PQSettings.animationType == "y") {
                yAnim.duration = 0
                filedialog_top.y = -filedialog_top.height
                yAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                filedialog_top.y = 0
            }
            // fade in item
            filedialog_top.opacity = 1
        } else
            filedialog_window.visible = true
        if(!PQSettings.openPopoutElementKeepOpen)
            variables.visibleItem = "filedialog"
    }

    function hideFileDialog() {
        if(PQSettings.openPopoutElementKeepOpen)
            return
        if(!PQSettings.openPopoutElement) {
            // hide in x direction
            if(PQSettings.animationType == "x") {
                xAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                filedialog_top.x = -width
            // hide in y direction
            } else if(PQSettings.animationType == "y") {
                yAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                filedialog_top.y = -height
            }
            // fade out item
            filedialog_top.opacity = 0
        } else
            filedialog_window.visible = false

        variables.visibleItem = ""
    }

}
