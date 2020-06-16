import QtQuick 2.9

Rectangle {
    property bool expertModeOnly: false
    visible: !expertModeOnly || (expertModeOnly && variables.settingsManagerExpertMode)
    width: parent.width
    height: 1
    color: "#88333333"
}
