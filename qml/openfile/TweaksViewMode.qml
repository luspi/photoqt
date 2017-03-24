import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "../elements"

Rectangle {

    id: iconlist

    color: "#00000000"

    width: 60
    y: 10
    height: parent.height-20

    ExclusiveGroup {
        id: view_grp;
        onCurrentChanged:
            settings.openDefaultView = getView()
    }

    Button {
        id: viewmode_list
        anchors.right: viewmode_icon.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width/2
        checkable: true
        exclusiveGroup: view_grp
        checked: settings.openDefaultView === "list"
        style: ButtonStyle {
            background: Rectangle {
                implicitWidth: iconlist.height
                implicitHeight: implicitWidth
                anchors.fill: parent
                radius: 5
                color: control.checked ? "#696969" : "#313131"
                Image {
                    opacity: control.checked ? 1: 0.2
                    width: parent.width
                    height: parent.height
                    source: Qt.resolvedUrl("qrc:/img/openfile/listview.png")
                }
            }
        }
        ToolTip {
            anchors.fill: parent
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.RightButton|Qt.LeftButton
            text: qsTr("Show files as list")
            onClicked: {
                if(!viewmode_list.checked) {
                    viewmode_list.checked = true
                    displayList()
                }
            }
        }
    }

    Button {
        id: viewmode_icon
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width/2
        checkable: true
        exclusiveGroup: view_grp
        checked: settings.openDefaultView === "icons"
        style: ButtonStyle {
            background: Rectangle {
                implicitWidth: iconlist.height
                implicitHeight: implicitWidth
                anchors.fill: parent
                radius: 5
                color: control.checked ? "#696969" : "#313131"
                Image {
                    opacity: control.checked ? 1: 0.2
                    width: parent.width
                    height: parent.height
                    source: Qt.resolvedUrl("qrc:/img/openfile/iconview.png")
                }
            }
        }
        ToolTip {
            anchors.fill: parent
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor
            text: qsTr("Show files as grid")
            acceptedButtons: Qt.RightButton|Qt.LeftButton
            onClicked: {
                if(!viewmode_icon.checked) {
                    viewmode_icon.checked = true
                    displayIcons()
                }
            }
        }
    }

    function getView() {
        return viewmode_icon.checked ? "icons" : "list"
    }

}
