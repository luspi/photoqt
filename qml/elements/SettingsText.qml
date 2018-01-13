import QtQuick 2.5

// Convenience Item, so that not every single description text has to be styled individually (they are all the same)
Text {

    color: enabled ? colour.text : colour.text_disabled
    Behavior on color { ColorAnimation { duration: 50; } }
    font.pointSize: 10
    wrapMode: Text.WordWrap
    textFormat: Text.StyledText

}
