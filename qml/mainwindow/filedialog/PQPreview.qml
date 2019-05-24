import QtQuick 2.9

Image {

    property string filePath: ""

    asynchronous: true
    source: (filePath==""||!settings.openPreview) ? "" : ("image://thumb/" + filePath)
    fillMode: Image.PreserveAspectFit

    opacity: 0.4

}
