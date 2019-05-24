import QtQuick 2.9

Rectangle {

    id: loadingimage_top

    // it fills the full background, including the margins possibly set
    x: 0
    y: 0
    width: container.width
    height: container.height

    // darken background a little
    color: "#44000000"

    // Animate opacity slightly
    opacity: 0
    visible: (opacity!=0)
    Behavior on opacity { NumberAnimation { duration: 200 } }

    // When the opacity changes, we need to adjust the animation
    onOpacityChanged: {

        // If item is shown and the animation is not running, then ...
        if(opacity != 0 && !motionPath.running)

            // ... we start it with a short delay
            waitAFewMs.start()

        // if the item is not shown (opacity of 0), then ...
        else if(opacity == 0) {

            // ... we pause the animation and ...
            motionPath.stop()

            // ... and the timer that could possibly restart it and ...
            waitAFewMs.stop()

            // ... reset the indicator circle position
            movingaround.x = width/2 - movingaround.width/2
            movingaround.y = (loadingimage_top.height-movingaround.height)/2

        }

    }

    // This is the circle that moves around the screen
    Rectangle {

        id: movingaround

        // the position is in the center
        x: parent.width/2 - width/2
        y: (loadingimage_top.height-height)/2

        // the size of the circle (only that size in middle of screen, around the edges the scale goes down)
        width: Math.max(parent.width/15, 150)
        height: Math.max(parent.width/15, 150)

        // in order to turn the rectangle into a circle, we set the radius to half its width/height
        radius: width/2

        // the size of the circle depends on where on the screen it is located (largest when in middle, smallest at left/right end)
        scale: (parent.width/2-Math.abs(parent.width/2 -x))/(parent.width/2)

        // it all looks best when circle is not fully opaque
        opacity: 0.8

        // some styling to make it look good
        color: "white"
        border.width: radius/10
        border.color: "#555555"

        // Inside the circle is a short text to tell the user what's going on
        Text {

            // full circle width ...
            anchors.fill: parent
            // ... except for the border, nothing can be written on that
            anchors.margins: parent.border.width

            // center text in middle of circle
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter

            // some styling
            color: "black"
            font.pixelSize: movingaround.width/10
            font.bold: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            //: Used as in 'Loading the image at the moment'. Please try to keep as short as possible!
            text: em.pty+qsTranslate("other", "Loading")

        }

    }

    // This timer is called when the animation has stopped to restart it after a short delay
    Timer {

        id: waitAFewMs

        // Delay is currently set to 500 ms
        interval: 500

        onTriggered: {
            // Start animation if still needed. The animation is always stopped when not needed, never just paused!
            if(loadingimage_top.opacity != 0)
                motionPath.restart()
        }
    }

    // The path animation
    PathAnimation {

        id: motionPath

        // the circle is the thing moving around
        target: movingaround

        // by default, the animation is not running
        running: false

        // 5 seconds seems like a reasonable time, giving a nice animation speed
        duration: 2000

        // don't move linear, but vary speed slightly
        easing.type: Easing.InOutQuad

        // when the naimation has finished, we restart it after a delay
        onStopped: {
            if(loadingimage_top.opacity != 0)
                waitAFewMs.start()
        }

        // the path
        path: Path {

            // starting from center:

            // 1) move circle HALF WAY to the RIGHT
            PathCurve { x: (3*loadingimage_top.width)/4 -movingaround.width/2; y: (loadingimage_top.height-movingaround.height)/2 }

            // 2) move circle HALF WAY to the LEFT
            PathCurve { x: (loadingimage_top.width)/4 -movingaround.width/2; y: (loadingimage_top.height-movingaround.height)/2 }

            // 3) move circle back to the center
            PathCurve { x: loadingimage_top.width/2 -movingaround.width/2; y: (loadingimage_top.height-movingaround.height)/2 }


        }

    }

}
