import QtQuick 2.9

Image {

    property string filePath: ""

    asynchronous: true
    source: (filePath==""||!PQSettings.openPreview) ? "" : ("image://thumb/" + filePath)
    fillMode: Image.PreserveAspectFit

    opacity: 0.4

}
