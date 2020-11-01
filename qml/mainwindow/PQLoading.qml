import QtQuick 2.9

Rectangle {

    id: loading_top

    anchors.fill: parent
    color: "#88000000"
    visible: false

    Repeater {

        model: 3

        delegate: Canvas {
            id: load
            x: (parent.width-width)/2
            y: (parent.height-height)/2
            width: 206 - index*25
            height: 206 - index*25
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = "#ffffff";
                ctx.lineWidth = 3
                ctx.beginPath();
                ctx.arc(width/2, height/2, width/2-3, 0, 3.14, false);
                ctx.stroke();
            }
            RotationAnimator {
                target: load
                from: index%2 ? 360 : 0
                to: index%2 ? 0 : 360
                duration: 1000 - index*100
                running: loading_top.visible&&variables.visibleItem==""
                onStopped: {
                    if(loading_top.visible && variables.visibleItem=="")
                        start()
                }
            }
        }

    }

}
