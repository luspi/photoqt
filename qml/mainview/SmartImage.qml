import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

    id: top

    // Invisible background
    color: "#00000000"

    // These properties can change the zoom and fade behaviour
    property int fadeduration: 400
    property double zoomduration: 150
    property double zoomstep: 0.3
    property bool fitinwindow: false
	property bool enableanimations: true

	property int interpolationThreshold: 100

    // Size and position
    x: 0
    y: 0
    width: parent.width
    height: parent.height

	onWidthChanged: {
		if(!isZoomed() && !_full_image_loaded)
			updateSourceSizeTimer.restart()
	}
	onHeightChanged: {
		if(!isZoomed() && !_full_image_loaded)
			updateSourceSizeTimer.restart()
	}

	function _updateSourceSize() {
		if(_image_currently_in_use == "one")
			one.sourceSize = Qt.size(width,height)
		else if(_image_currently_in_use == "two")
			two.sourceSize = Qt.size(width,height)
		else if(_image_currently_in_use == "three") {
			three.sourceSize.width = width
			three.sourceSize.height = height
		} else if(_image_currently_in_use == "four") {
			four.sourceSize.width = width
			four.sourceSize.height = height
		}
	}
	Timer {
		id: updateSourceSizeTimer
		interval: 150
		repeat: false
		onTriggered: _updateSourceSize()
	}

    // Hide everything outside of rectangle
    clip: true

    // Current image item in use
    property string _image_currently_in_use: "one"
    // Mirrored property
    property bool _vertical_mirrored: false
    // Full image loaded
    property bool _full_image_loaded: false
    // Zoom to where
    property bool _zoomTowardsCenter: false

    // When a filter returns an empty result, we fade out the image, reset the source (using this boolean),
    // so that after removing the filter, the image is faded in again
    property bool resetSourceToEmptyAfterFadeOut: false

    // Scrollarea for image
    Flickable {

        id: flickarea

        // Set content height, adjusted for possible rotations
        contentHeight: (Math.abs(cont.rotation%180 == 90) ? flick_cont.width : flick_cont.height)
        contentWidth: (Math.abs(cont.rotation%180 == 90) ? flick_cont.height : flick_cont.width)

        // Same size and position as parent
        anchors.fill: parent

        // Same as parent, hide everything outside area
        clip: true

        // This Item is used as a container for scrolling any zoomed image
        // The second container below is used for rotations/scaling
        Item {

            id: flick_cont

            // Size and position
            x: (Math.abs(cont.rotation%180 == 90) ? Math.max(0,(top.height-flick_cont.height)/2) : Math.max(0,(top.width-flick_cont.width)/2))
            y: (Math.abs(cont.rotation%180 == 90) ? Math.max(0,(top.width-flick_cont.width)/2) : Math.max(0,(top.height-flick_cont.height)/2))
            width: Math.abs(cont.rotation%180 == 90) ? cont.height*cont.scale : cont.width*cont.scale
            height: Math.abs(cont.rotation%180 == 90) ? cont.width*cont.scale : cont.height*cont.scale

            // Animate scaling - velocity is changed to duration in 'onStatusChanged' below
            // For some reason, setting duration right away here does not work
            Behavior on scale {SmoothedAnimation { id: rotscale_fix; velocity: 0.1; } }

            // Container used for rotation/scaling
            Item {

                id: cont

                // Size and position
                x: 0
                y: 0
                width: _getCurrentlyDisplayedImageSize().width
                height: _getCurrentlyDisplayedImageSize().height

                // Ensure full image visible in flickarea
                transformOrigin: Item.TopLeft

                // Animate rotation
                transform: Rotation {
                    id: imgrot;
                    origin.x: flick_cont.width/2
                    origin.y: flick_cont.height/2
                    NumberAnimation on angle { id: rotani;
						duration: (enableanimations ? 200 : 1);
                        onStopped: { if(imgrot.angle == 0 && !fitinwindow) cont.scale = 1; }
                        onStarted: {
                            var w;
                            var h;
                            var sourcesize = _getCurrentSourceSize()
                            // If image is rotated, we need to adjust the scaling slightly to take account for different ratio
							if(Math.abs((imgrot.angle+90)%180) == 90 && cont.scale == 1) {
                                if(flickarea.width/flickarea.height == sourcesize.width/sourcesize.height) {
                                    flick_cont.scale = 1
                                } else {
                                    h = top.height
                                    w = sourcesize.height*(h/sourcesize.width)
                                    if(flickarea.contentWidth > flickarea.height)
                                        flick_cont.scale = sourcesize.height/sourcesize.width;
                                    else if (flickarea.contentWidth < flickarea.height)
                                        flick_cont.scale = flickarea.height/flickarea.contentWidth
                                }
                            } else
                                flick_cont.scale = 1
                        }
                    }
                }

                // Handle scaling of container
                property real prevScale
                function calculateSize() {
                    if(fitinwindow && _getCurrentlyDisplayedImageSize().width > 0 && _getCurrentlyDisplayedImageSize().height > 0)
                        cont.scale = Math.min(flickarea.width / _getCurrentlyDisplayedImageSize().width, flickarea.height / _getCurrentlyDisplayedImageSize().height);
                    prevScale = Math.min(scale, 1);
                }
                onScaleChanged: {
                    var cursorpos = getCursorPos()
                    var x_ratio = (_zoomTowardsCenter ? flickarea.width/2 : cursorpos.x);
                    var y_ratio = (_zoomTowardsCenter ? flickarea.height/2 : cursorpos.y);
                    if ((width * scale) > flickarea.width) {
                        var xoff = (x_ratio + flickarea.contentX) * scale / prevScale;
                        flickarea.contentX = xoff - x_ratio;
                    }
                    if ((height * scale) > flickarea.height) {
                        var yoff = (y_ratio + flickarea.contentY) * scale / prevScale;
                        flickarea.contentY = yoff - y_ratio;
                    }
                    prevScale = scale;

					var s = _getCurrentSourceSize()
					if(s.width < interpolationThreshold && s.height < interpolationThreshold) {
						if(_image_currently_in_use == "one")
							one.smooth = false
						else if(_image_currently_in_use == "two")
							two.smooth = false
						else if(_image_currently_in_use == "three")
							three.smooth = false
						else if(_image_currently_in_use == "four")
							four.smooth = false
					} else {
						if(_image_currently_in_use == "one")
							one.mipmap = true
						else if(_image_currently_in_use == "two")
							two.mipmap = true
						else if(_image_currently_in_use == "three")
							three.mipmap = true
						else if(_image_currently_in_use == "four")
							four.mipmap = true
					}

                }
                // Animate scaling - velocity is changed to duration in 'onStatusChanged' below
                // For some reason, setting duration right away here does not work
                Behavior on scale {SmoothedAnimation { id: rotscale; velocity: 0.1; } }

                // We use animated images to display normal AND animated images alike
                // We use two images to enable fading into each other

                // First image
                Image {

                    id: one

                    // This one is the first one used by default
                    opacity: 1

                    source: "qrc:///img/empty.png"
					mipmap: true
                    asynchronous: false
                    fillMode: Image.PreserveAspectFit
                    transformOrigin: Item.TopLeft

                    x: (parent.width-width)/2
                    y: (parent.height-height)/2
                    width:  opacity!=0 ? ((sourceSize.width<flickarea.width&&sourceSize.height<flickarea.height) ? sourceSize.width : (sourceSize.width/sourceSize.height > top.width/top.height ? top.width : sourceSize.width*(top.height/sourceSize.height))) : 0
                    height: opacity!=0 ? ((sourceSize.width<flickarea.width&&sourceSize.height<flickarea.height) ? sourceSize.height : (sourceSize.width/sourceSize.height < top.width/top.height ? top.height : sourceSize.height*(top.width/sourceSize.width))) : 0

                    onStatusChanged: {
                        if(status == Image.Ready) {
                            parent.calculateSize();
							rotscale.duration = (enableanimations ? 200 : 1)
							rotscale_fix.duration = (enableanimations ? 200 : 1)
                        }
                    }
                }

                // First image
                Image {

                    id: two

                    // This one is the first one used by default
                    opacity: 1

                    source: "qrc:///img/empty.png"
					mipmap: true
                    asynchronous: false
                    fillMode: Image.PreserveAspectFit
                    transformOrigin: Item.TopLeft

                    x: (parent.width-width)/2
                    y: (parent.height-height)/2
                    width:  opacity!=0 ? ((sourceSize.width<flickarea.width&&sourceSize.height<flickarea.height) ? sourceSize.width : (sourceSize.width/sourceSize.height > top.width/top.height ? top.width : sourceSize.width*(top.height/sourceSize.height))) : 0
                    height: opacity!=0 ? ((sourceSize.width<flickarea.width&&sourceSize.height<flickarea.height) ? sourceSize.height : (sourceSize.width/sourceSize.height < top.width/top.height ? top.height : sourceSize.height*(top.width/sourceSize.width))) : 0

                    onStatusChanged: {
                        if(status == Image.Ready) {
                            parent.calculateSize();
							rotscale.duration = (enableanimations ? 200 : 1)
							rotscale_fix.duration = (enableanimations ? 200 : 1)
                        }
                    }
                }

                // First image
                AnimatedImage {

                    id: three

                    // This one is the first one used by default
                    opacity: 1

                    source: "qrc:///img/empty.png"
                    mipmap: true
                    asynchronous: false
                    fillMode: Image.PreserveAspectFit
                    transformOrigin: Item.TopLeft

                    x: (parent.width-width)/2
                    y: (parent.height-height)/2
                    width:  opacity!=0 ? ((sourceSize.width<flickarea.width&&sourceSize.height<flickarea.height) ? sourceSize.width : (sourceSize.width/sourceSize.height > top.width/top.height ? top.width : sourceSize.width*(top.height/sourceSize.height))) : 0
                    height: opacity!=0 ? ((sourceSize.width<flickarea.width&&sourceSize.height<flickarea.height) ? sourceSize.height : (sourceSize.width/sourceSize.height < top.width/top.height ? top.height : sourceSize.height*(top.width/sourceSize.width))) : 0

                    onStatusChanged: {
                        if(status == Image.Ready) {
                            parent.calculateSize();
							rotscale.duration = (enableanimations ? 200 : 1)
							rotscale_fix.duration = (enableanimations ? 200 : 1)
                        }
                    }
                }

                // Second image
                AnimatedImage {

                    id: four

                    // This one is the second one used when fading is required
                    opacity: 0

                    source: "qrc:///img/empty.png"
                    mipmap: true
                    asynchronous: false
                    fillMode: Image.PreserveAspectFit
                    transformOrigin: Item.TopLeft

                    x: (parent.width-width)/2
                    y: (parent.height-height)/2
                    width:  opacity!=0 ? ((sourceSize.width<flickarea.width&&sourceSize.height<flickarea.height) ? sourceSize.width : (sourceSize.width/sourceSize.height > top.width/top.height ? top.width : sourceSize.width*(top.height/sourceSize.height))) : 0
                    height: opacity!=0 ? ((sourceSize.width<flickarea.width&&sourceSize.height<flickarea.height) ? sourceSize.height : (sourceSize.width/sourceSize.height < top.width/top.height ? top.height : sourceSize.height*(top.width/sourceSize.width))) : 0

                    onStatusChanged: {
                        if(status == Image.Ready) {
                            parent.calculateSize();
							rotscale.duration = (enableanimations ? 200 : 1)
							rotscale_fix.duration = (enableanimations ? 200 : 1)
                        }
                    }
                }

            }

        }

    }

    // Fade-in animations
    PropertyAnimation {
        id: one_fadein
        target: one
        properties: "opacity"
        from: 0
        to: 1
        duration: 300
    }
    PropertyAnimation {
        id: two_fadein
        target: two
        properties: "opacity"
        from: 0
        to: 1
        duration: 300
    }
    PropertyAnimation {
        id: three_fadein
        target: three
        properties: "opacity"
        from: 0
        to: 1
        duration: 300
    }
    PropertyAnimation {
        id: four_fadein
        target: four
        properties: "opacity"
        from: 0
        to: 1
        duration: 300
    }

    // Fade-out animations
    PropertyAnimation {
        id: one_fadeout
        target: one
        properties: "opacity"
        from: 1
        to: 0
        duration: 300
        onStopped: {
            if(resetSourceToEmptyAfterFadeOut) one.source = "qrc:///img/empty.png"
            one.opacity = 0
            flickarea.contentX = 0
            flickarea.contentY = 0
        }
    }
    PropertyAnimation {
        id: two_fadeout
        target: two
        properties: "opacity"
        from: 1
        to: 0
        duration: 300
        onStopped: {
            if(resetSourceToEmptyAfterFadeOut) two.source = "qrc:///img/empty.png"
            two.opacity = 0
            flickarea.contentX = 0
            flickarea.contentY = 0
        }
    }
    PropertyAnimation {
        id: three_fadeout
        target: three
        properties: "opacity"
        from: 1
        to: 0
        duration: 300
        onStopped: {
            if(resetSourceToEmptyAfterFadeOut) three.source = "qrc:///img/empty.png"
            three.opacity = 0
            flickarea.contentX = 0
            flickarea.contentY = 0
        }
    }
    PropertyAnimation {
        id: four_fadeout
        target: four
        properties: "opacity"
        from: 1
        to: 0
        duration: 300
        onStopped: {
            if(resetSourceToEmptyAfterFadeOut) four.source = "qrc:///img/empty.png"
            four.opacity = 0
            flickarea.contentX = 0
            flickarea.contentY = 0
        }
    }

    // Function to get the currently displayed size fo the current image
    function _getCurrentlyDisplayedImageSize() {
        if(_image_currently_in_use == "one")
            return Qt.size(one.width*one.scale,one.height*one.scale)
        else if(_image_currently_in_use == "two")
            return Qt.size(two.width*two.scale,two.height*two.scale)
        else if(_image_currently_in_use == "three")
            return Qt.size(three.width*three.scale,three.height*three.scale)
        else if(_image_currently_in_use == "four")
            return Qt.size(four.width*four.scale,four.height*four.scale)
    }

    function _getCurrentlyLoadedPath() {
        if(_image_currently_in_use == "one")
            return one.source
        else if(_image_currently_in_use == "two")
            return two.source
        else if(_image_currently_in_use == "three")
            return three.source
        else if(_image_currently_in_use == "four")
            return four.source
    }

    // Function to get the sourcesize of the current image
    function _getCurrentSourceSize() {
        if(!_full_image_loaded) {
            return getActualSourceSize(_getCurrentlyLoadedPath())
        } else {
            if(_image_currently_in_use == "one")
                return one.sourceSize
            else if(_image_currently_in_use == "two")
                return two.sourceSize
            else if(_image_currently_in_use == "three")
                return three.sourceSize
            else if(_image_currently_in_use == "four")
                return four.sourceSize
        }
    }


    // Can be called from outside for zooming
    function zoomIn(towardsCenter) {

        if(towardsCenter === undefined)
            towardsCenter = false
        _zoomTowardsCenter = towardsCenter


        var use_zoomstep = zoomstep

        // We increase the zoomstep the more the image is zoomed in. Otherwise it will seem to get incredibly slow very fast
        if(flickarea.contentWidth/cont.width > 2)
            use_zoomstep *= Math.round(flickarea.contentWidth/cont.width)

        // Very small images are sped up, too!
        if(_getCurrentSourceSize().width < flickarea.width/5 && _getCurrentSourceSize().height < flickarea.height/5)
            use_zoomstep *= 5

        // Limit maximum zoom level
        if(flickarea.contentWidth > _getCurrentSourceSize().width*5 && flickarea.contentWidth > flickarea.width*2) return;

        if(cont.scale+use_zoomstep > 1 && !_full_image_loaded)
            _loadFullImage()

        cont.scale += use_zoomstep

    }

    // Can be called from outside for zooming
    function zoomOut(towardsCenter) {

        if(towardsCenter === undefined)
            towardsCenter = false
        _zoomTowardsCenter = towardsCenter

        var use_zoomstep = zoomstep

        // We increase the zoomstep the more the image is zoomed in. Otherwise it will seem to get incredibly slow very fast
        if(flickarea.contentWidth/cont.width > 2)
            use_zoomstep *= Math.round(flickarea.contentWidth/cont.width)

        // Limit minimum zoom level
        if(cont.scale < 0.1)
            return
        else if(cont.scale-use_zoomstep < 0.1)
            use_zoomstep = cont.scale-0.1

        cont.scale -= use_zoomstep

    }

    // Zoom to actual size
    function zoomActual() {
        if(!_full_image_loaded) _loadFullImage()
		cont.scale = _getCurrentSourceSize().width/cont.width
    }

    // Zoom to 250%
    function zoom250() {
        if(!_full_image_loaded) _loadFullImage()
        cont.scale = 2.5
    }

    // Zoom to 500%
    function zoom500() {
        if(!_full_image_loaded) _loadFullImage()
        cont.scale = 5
    }

    // Zoom to 1000%
    function zoom1000() {
        if(!_full_image_loaded) _loadFullImage()
        cont.scale = 10
    }

    // Reset zoom
    function resetZoom() {
		cont.scale = 1
    }

    // Rotate image to the left
    function rotateLeft() {

        rotani.to = imgrot.angle - 90
        rotani.start()

    }

    // Rotate image to the right
    function rotateRight() {

        rotani.to = imgrot.angle + 90
        rotani.start()

    }

    // Reset the rotation
    function resetRotation() {

        // Not necessary to do anything
        if(imgrot.angle%360 == 0) return

        // Get the right direction
        if(imgrot.angle%360 == 270)
            var rotateto = imgrot.angle+90
        else if(imgrot.angle%360 == -270)
            rotateto = imgrot.angle-90
        else
            rotateto = imgrot.angle-(imgrot.angle%360);

        rotani.to = rotateto
        rotani.start()
    }

    // Mirror horizontally
    function mirrorHorizontal() {
        one.mirror = !one.mirror
        two.mirror = !two.mirror
        three.mirror = !three.mirror
        four.mirror = !four.mirror
    }

    // Mirror vertically
    function mirrorVertical() {
        imgrot.angle -= 90;
        one.mirror = !one.mirror
        two.mirror = !two.mirror
        three.mirror = !three.mirror
        four.mirror = !four.mirror
        _vertical_mirrored = !_vertical_mirrored
        imgrot.angle -= 90;
    }

    // Reset mirroring
    function resetMirror() {
        one.mirror = false
        two.mirror = false
        three.mirror = false
        four.mirror = false
        if(_vertical_mirrored) {
            imgrot.angle -= 180
            _vertical_mirrored = false
        }
    }

    function isZoomed() {
        return (cont.scale!=1)
    }

    function _loadFullImage() {

        _full_image_loaded = true
        if(_image_currently_in_use == "one")
            one.sourceSize = undefined
        else if(_image_currently_in_use == "two")
            two.sourceSize = undefined
		else if(_image_currently_in_use == "three") {
			three.sourceSize.width = undefined
			three.sourceSize.height = undefined
		} else if(_image_currently_in_use == "four") {
			four.sourceSize.width = undefined
			four.sourceSize.height = undefined
		}

    }

    // Load a new image
    function loadImage(src, animated) {

        // Initiate resetting of all changes
        // These animations will continue while image is changing
        resetMirror()
        resetRotation()
        cont.scale = 1
        flick_cont.scale = 1

        _full_image_loaded = false

        // Empty result of search/filter
        if(src === "") {

            resetSourceToEmptyAfterFadeOut = true

            one_fadeout.duration = 300
            one_fadeout.start()
            two_fadeout.duration = 300
            two_fadeout.start()
            three_fadeout.duration = 300
            three_fadeout.start()
            four_fadeout.duration = 300
            four_fadeout.start()

            return;

        }

        resetSourceToEmptyAfterFadeOut = false

        // Convert to proper internal source url
        var _source = Qt.resolvedUrl(src)

        // Don't do anything if it's just the same image again
        if(_image_currently_in_use == "one" && one.source == _source)
			return;
        else if(_image_currently_in_use == "two" && two.source == _source)
            return;
        else if(_image_currently_in_use == "three" && three.source == _source)
            return;
        else if(_image_currently_in_use == "four" && four.source == _source)
            return;

        // Stop all animations
        one_fadein.stop()
        one_fadeout.stop()
        two_fadein.stop()
        two_fadeout.stop()
        three_fadein.stop()
        three_fadeout.stop()
        four_fadein.stop()
        four_fadeout.stop()

        // No fading between images
        if(fadeduration === 0) {

            if(animated && (_image_currently_in_use == "one" || _image_currently_in_use == "two")) {

                one.opacity = 0
                two.opacity = 0
                three.opacity = 1
                four.opacity = 0

				three.sourceSize.width = flickarea.width
				three.sourceSize.height =flickarea.height
                three.source = _source

                // This assures, that a possible animation is always running
                three.playing = true
                four.playing = false

				_image_currently_in_use = "three"

            } else if(!animated && (_image_currently_in_use == "three" || _image_currently_in_use  == "four")) {

                one.opacity = 1
                two.opacity = 0
                three.opacity = 0;
                four.opacity = 0;

                one.sourceSize = Qt.size(flickarea.width,flickarea.height)
                one.source = _source

                // This assures, that a possible animation is always running
                three.playing = false
                four.playing = false

				_image_currently_in_use = "one"

            } else if(_image_currently_in_use == "one" || _image_currently_in_use == "two") {

                if((_image_currently_in_use == "one" && one.source == _source) || (_image_currently_in_use == "two" && two.source == _source))
                    return

                one.opacity = 1
                two.opacity = 0
                three.opacity = 0;
                four.opacity = 0;

                one.sourceSize = Qt.size(flickarea.width,flickarea.height)
                one.source = _source

                // This assures, that a possible animation is always running
                three.playing = false
                four.playing = false

				_image_currently_in_use = "one"

            } else if(_image_currently_in_use == "three" || _image_currently_in_use == "four") {

                if((_image_currently_in_use == "three" && three.source == _source) || (_image_currently_in_use == "four" && four.source == _source))
                    return

                one.opacity = 0
                two.opacity = 0
                three.opacity = 1;
                four.opacity = 0;

				three.sourceSize.width = flickarea.width
				three.sourceSize.height =flickarea.height
                three.source = _source

                // This assures, that a possible animation is always running
                three.playing = true
                four.playing = false

				_image_currently_in_use = "three"

            }

        } else {

            // Adjust fade durations
            one_fadein.duration = fadeduration
            one_fadeout.duration = fadeduration
            two_fadein.duration = fadeduration
            two_fadeout.duration = fadeduration

            if(_image_currently_in_use == "one") {

                if(animated) {

                    one.opacity = 1
                    three.opacity = 0

					three.sourceSize.width = flickarea.width
					three.sourceSize.height =flickarea.height
                    three.source = _source

                    one_fadeout.start()
                    three_fadein.start()

                    _image_currently_in_use = "three"

                    // This assures, that a possible animation is always running
                    three.playing = true
                    four.playing = false

                } else {

                    one.opacity = 1
                    two.opacity = 0

                    two.sourceSize = Qt.size(top.width,top.height)
                    two.source = _source

                    one_fadeout.start()
                    two_fadein.start()

                    _image_currently_in_use = "two"

                    // This assures, that a possible animation is always running
                    three.playing = false
                    four.playing = false

                }

            } else if(_image_currently_in_use == "two") {

                if(animated) {

                    two.opacity = 1
                    three.opacity = 0

					three.sourceSize.width = flickarea.width
					three.sourceSize.height =flickarea.height
                    three.source = _source

                    two_fadeout.start()
                    three_fadein.start()

                    _image_currently_in_use = "three"

                    // This assures, that a possible animation is always running
                    three.playing = true
                    four.playing = false

                } else {

                    two.opacity = 1
                    one.opacity = 0

                    one.sourceSize = Qt.size(flickarea.width,flickarea.height)
                    one.source = _source

                    two_fadeout.start()
                    one_fadein.start()

                    _image_currently_in_use = "one"

                    // This assures, that a possible animation is always running
                    three.playing = false
                    four.playing = false

                }

            } else if(_image_currently_in_use == "three") {

                if(animated) {

                    three.opacity = 1
                    four.opacity = 0

					four.sourceSize.width = flickarea.width
					four.sourceSize.height =flickarea.height
                    four.source = _source

                    three_fadeout.start()
                    four_fadein.start()

                    _image_currently_in_use = "four"

                    // This assures, that a possible animation is always running
                    three.playing = true
                    four.playing = true

                } else {

                    three.opacity = 1
                    one.opacity = 0

                    one.sourceSize = Qt.size(flickarea.width,flickarea.height)
                    one.source = _source

                    three_fadeout.start()
                    one_fadein.start()

                    _image_currently_in_use = "one"

                    // This assures, that a possible animation is always running
                    three.playing = true
                    four.playing = false

                }

            } else if(_image_currently_in_use == "four") {

                if(animated) {

                    four.opacity = 1
                    three.opacity = 0

					three.sourceSize.width = flickarea.width
					three.sourceSize.height =flickarea.height
                    three.source = _source

                    four_fadeout.start()
                    three_fadein.start()

                    _image_currently_in_use = "three"

                    // This assures, that a possible animation is always running
                    three.playing = true
                    four.playing = true

                } else {

                    four.opacity = 1
                    one.opacity = 0

                    one.sourceSize = Qt.size(flickarea.width,flickarea.height)
                    one.source = _source

                    four_fadeout.start()
                    one_fadein.start()

                    _image_currently_in_use = "one"

                    // This assures, that a possible animation is always running
                    three.playing = false
                    four.playing = true

                }

            }
        }

        var s = _getCurrentSourceSize();
        if(s.width < flickarea.width && s.height < flickarea.height) {
            _full_image_loaded = true
            if(_image_currently_in_use == "one")
                one.sourceSize = s
            else if(_image_currently_in_use == "two")
                two.sourceSize = s
			else if(_image_currently_in_use == "three") {
				three.sourceSize.width = s.width
				three.sourceSize.height = s.height
			} else if(_image_currently_in_use == "four") {
				four.sourceSize.width = s.width
				four.sourceSize.height = s.height
			}
        }


		if(s.width < interpolationThreshold && s.height < interpolationThreshold) {
			if(_image_currently_in_use == "one")
				one.smooth = false
			else if(_image_currently_in_use == "two")
				two.smooth = false
			else if(_image_currently_in_use == "three")
				three.smooth = false
			else if(_image_currently_in_use == "four")
				four.smooth = false
		} else {
			if(_image_currently_in_use == "one")
				one.mipmap = true
			else if(_image_currently_in_use == "two")
				two.mipmap = true
			else if(_image_currently_in_use == "three")
				three.mipmap = true
			else if(_image_currently_in_use == "four")
				four.mipmap = true
		}

    }
}
