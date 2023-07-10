import QtQuick
import "../elements"

Item {

    id: image_top

    x: PQCSettings.imageviewMargin
    y: PQCSettings.imageviewMargin
    width: toplevel.width-2*PQCSettings.imageviewMargin
    height: toplevel.height-2*PQCSettings.imageviewMargin

    Rectangle {
        color: "red"
        width: 50
        height: 50
        z: 999
        Text {
            anchors.centerIn: parent
            text: PQCFileFolderModel.currentIndex
        }
    }

    property int currentlyVisibleIndex: -1

    property int curZ: 0

    signal zoomIn()
    signal zoomOut()
    signal zoomReset()
    signal zoomActual()

    Repeater {

        id: repeater

        model: PQCFileFolderModel.countMainView

        delegate:
            Item {
                id: deleg

                width: image_top.width
                height: image_top.height

                visible: false

                property int itemIndex: index
                property real imageScale: defaultScale
                property real defaultScale: 1

                Connections {
                    target: image_top
                    function onZoomIn() {
                        if(PQCFileFolderModel.currentIndex===index)
                            deleg.imageScale /= 0.9
                    }
                    function onZoomOut() {
                        if(PQCFileFolderModel.currentIndex===index)
                            deleg.imageScale *= 0.9
                    }
                    function onZoomReset() {
                        if(PQCFileFolderModel.currentIndex===index)
                            deleg.imageScale = deleg.defaultScale
                    }
                    function onZoomActual() {
                        if(PQCFileFolderModel.currentIndex===index)
                            deleg.imageScale = 1
                    }
                }

                signal zoomResetWithoutAnimation()

                Loader {
                    id: l
                    asynchronous: true
                    active: shouldBeShown || hasBeenSetup
                    property bool shouldBeShown: PQCFileFolderModel.currentIndex===index || (image_top.currentlyVisibleIndex === index)
                    property bool hasBeenSetup: false
                    onShouldBeShownChanged: {
                        if(shouldBeShown) {
                            if(hasBeenSetup)
                                deleg.showImage()
                        } else {
                            deleg.hideImage()
                        }
                    }
                    sourceComponent: Image {

                        id: img

                        x: (deleg.width-width)/2
                        y: (deleg.height-height)/2
                        clip: false
                        asynchronous: true
                        mipmap: true
                        scale: deleg.defaultScale

                        property bool startupScale: false

                        Connections {
                            target: deleg
                            function onImageScaleChanged() {
                                if(img.startupScale) {
                                    img.startupScale = false
                                    img.scale = deleg.imageScale
                                } else
                                    scaleAnimation.restart()
                            }
                            function onZoomResetWithoutAnimation() {
                                img.scale = deleg.defaultScale
                                deleg.imageScale = img.scale
                            }
                        }

                        PropertyAnimation {
                            id: scaleAnimation
                            target: img
                            property: "scale"
                            from: img.scale
                            to: deleg.imageScale
                            duration: 200
                        }

                        source: "image://full/" + PQCFileFolderModel.entriesMainView[deleg.itemIndex]
                        onStatusChanged: {
                            if(status == Image.Ready) {
                                if(PQCFileFolderModel.currentIndex === index) {
                                    console.log("make visible:", deleg.itemIndex)
                                    startupScale = true
                                    deleg.defaultScale = Qt.binding(function() { return Math.min(1, Math.min(deleg.width/sourceSize.width, deleg.height/sourceSize.height)) })
                                    l.hasBeenSetup = true
                                    deleg.showImage()
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            drag.target: parent
                        }

                    }
                }

                PropertyAnimation {
                    id: opacityAnimation
                    target: deleg
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                    onFinished:
                        if(deleg.opacity < 1e-6)
                            deleg.visible = false
                }

                function showImage() {

                    image_top.currentlyVisibleIndex = deleg.itemIndex

                    deleg.zoomResetWithoutAnimation()

                    opacityAnimation.stop()

                    deleg.opacity = 0
                    deleg.z = image_top.curZ
                    deleg.visible = true

                    opacityAnimation.from = 0
                    opacityAnimation.to = 1
                    opacityAnimation.restart()

                    image_top.curZ += 1
                }

                function hideImage() {

                    opacityAnimation.stop()
                    opacityAnimation.from = deleg.opacity
                    opacityAnimation.to = 0
                    opacityAnimation.restart()

                }

            }

    }

    function showNext() {
        PQCFileFolderModel.currentIndex = Math.min(PQCFileFolderModel.currentIndex+1, PQCFileFolderModel.countMainView-1)
    }

    function showPrev() {
        PQCFileFolderModel.currentIndex = Math.max(PQCFileFolderModel.currentIndex-1, 0)
    }

}
