import QtQuick 2.5
import QtQuick.Controls 1.4

Item {

    width: 600
    height: 210

    Rectangle {

        id: progressbar

        color: "transparent"
        width: 600
        height: 100
        x: 0
        y: 0

        Row {
            Repeater {
                model: 10
                Rectangle {
                    width: 60; height: 100
                    color: "transparent"
                    Rectangle {
                        color: (10*index+5 > progresspercentage.percentage ? "black" : "white")
                        border.width: 1
                        border.color: "white"
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }
                    }
                }
            }
        }

    }

    Text {
        id: progresspercentage
        x: 0
        y: progressbar.height+10
        property int percentage: 0
        width: progressbar.width
        height: 100
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: percentage + "%"
        font.bold: true
        font.pointSize: 30
        color: "white"
    }

    function setProgress(progress) {
        progresspercentage.percentage = progress
    }

}
