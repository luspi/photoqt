import QtQuick 2.9
import Qt.labs.platform 1.0

ListView {

    boundsBehavior: Flickable.StopAtBounds

    model: 5

    height: childrenRect.height

    property var locs: [StandardPaths.displayName(StandardPaths.HomeLocation), handlingFileDialog.cleanPath(StandardPaths.writableLocation(StandardPaths.HomeLocation)), "user-home",
                        StandardPaths.displayName(StandardPaths.DesktopLocation), handlingFileDialog.cleanPath(StandardPaths.writableLocation(StandardPaths.DesktopLocation)), "user-desktop",
                        StandardPaths.displayName(StandardPaths.PicturesLocation), handlingFileDialog.cleanPath(StandardPaths.writableLocation(StandardPaths.PicturesLocation)), "folder-pictures",
                        StandardPaths.displayName(StandardPaths.DownloadLocation), handlingFileDialog.cleanPath(StandardPaths.writableLocation(StandardPaths.DownloadLocation)), "folder-downloads"]

    delegate: Rectangle {

        id: deleg_container

        width: parent.width
        height: 30

        color: "transparent"
        Behavior on color { ColorAnimation { duration: 200 } }

        // the icon for this entry (e.g., folder, ...)
        Item {

            id: entryicon

            // its size is square (height==width)
            width: deleg_container.height
            height: width

            // the icon image
            Image {

                // fill parent (with margin for better looks)
                anchors.fill: parent
                anchors.margins: 5

                // not shown for first entry (first entry is category title)
                visible: index>0

                // the image icon is taken from image loader (i.e., from system theme if available)
                source: ((locs[(index-1)*3 + 2]!==undefined) ? ("image://icon/" + locs[(index-1)*3 + 2]) : "")

            }

        }

        // The text of each entry
        Text {

            id: entrytextUser

            // size and position
            anchors.fill: parent
            anchors.leftMargin: entryicon.width

            // vertically center text
            verticalAlignment: Qt.AlignVCenter

            // some styling
            color: index==0 ? "grey" : "white"
            font.bold: true
            font.pixelSize: 15
            elide: Text.ElideRight

            //: This is the category title of user-set folders (or favorites) in the file dialog
            text: index==0 ? em.pty+qsTr("Standard") : locs[(index-1)*3 + 0]
        }

        // mouse area handling clicks
        MouseArea {

            id: mouseArea

            // fills full entry
            anchors.fill: parent

            // some properties
            hoverEnabled: true
            acceptedButtons: Qt.RightButton|Qt.LeftButton
            cursorShape: index > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor

            // clicking an entry loads the location or shows a context menu (depends on which button was used)
            onClicked: {
                    if(mouse.button == Qt.LeftButton)
                        filedialog_top.setCurrentDirectory(locs[(index-1)*3 + 1])
//                            openvariables.currentDirectory = path
//                        else
//                            delegcontext.popup()
            }

            onEntered: {
                if(index > 0)
                    deleg_container.color = "#444444"
            }
            onExited:
                deleg_container.color = "transparent"

        }

    }

}
