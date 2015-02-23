import QtQuick 2.3

// Convenience Item, so that not every single description text has to be styled individually (they are all the same)
Text {

    property Item sibling: Item

    width: sibling.width

    color: "white"
    font.pointSize: 10
    wrapMode: Text.WordWrap
    textFormat: Text.StyledText

}
