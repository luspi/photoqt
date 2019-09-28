import QtQuick 2.9

Item {

    id: load_top

    width: 150
    height: 150

    property int progress: 0

    Behavior on opacity { NumberAnimation { duration: 200 } }

    property var colors: ["#333333", "#444444", "#555555", "#666666", "#777777", "#888888",
                          "#999999", "#aaaaaa", "#bbbbbb", "#cccccc", "#dddddd", "#eeeeee"]

    property int elementWidth: width/5
    property int elementHeight: height/5

    property var xPos: [(width-elementWidth)/2,
                        13*(width-elementWidth)/15,
                        width-elementWidth,
                        13*(width-elementWidth)/15,
                        (width-elementWidth)/2,
                        2*(width-elementWidth)/15,
                        0,
                        2*(width-elementWidth)/15]

    property var yPos: [0,
                        2*(height-elementHeight)/15,
                        (height-elementHeight)/2,
                        13*(height-elementHeight)/15,
                        height-elementHeight,
                        13*(height-elementHeight)/15,
                        (height-elementHeight)/2,
                        2*(height-elementHeight)/15]

    Repeater {
        model: 8
        Rectangle {
            property int start: index*12
            color: colors[Math.max(0, Math.min(progress-start, 11))]
            Behavior on color { ColorAnimation { duration: 200 } }
            x: xPos[index]
            y: yPos[index]
            opacity: 0.75
            width: elementWidth
            height: elementHeight
            radius: width/2
        }
    }

    Rectangle {
        id: rotator
        color: "#333333"
        Behavior on color { ColorAnimation { duration: 3600 } }
        width: elementWidth*1.5
        height: elementHeight*1.5
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        radius: 10

        Component.onCompleted:
            rotator.color = Qt.binding(function() { return (Math.abs(rotation)%360<180) ? "#aaaaaa" : "#333333" })

        Timer {
            repeat: true
            running: load_top.opacity>0
            interval: 10
            onTriggered:
                rotator.rotation -= 1
        }
    }

    Text {
        anchors.centerIn: rotator
        color: "#ffffff"
        text: progress+"%"
    }

}
