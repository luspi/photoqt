import QtQuick

Item {

    id: image_top

    x: PQCSettings.imageviewMargin
    y: PQCSettings.imageviewMargin
    width: toplevel.width-2*PQCSettings.imageviewMargin
    height: toplevel.height-2*PQCSettings.imageviewMargin

    property int currentlyVisibleIndex: -1

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
                property int itemIndex: index
                property real imageScale: defaultScale
                property real defaultScale: 1

                Connections {
                    target: image_top
                    function onZoomIn() {
                        deleg.imageScale /= 0.9
                    }
                    function onZoomOut() {
                        deleg.imageScale *= 0.9
                    }
                    function onZoomReset() {
                        deleg.imageScale = deleg.defaultScale
                    }
                    function onZoomActual() {
                        deleg.imageScale = 1
                    }
                }

                Loader {
                    id: l
                    asynchronous: true
                    active: PQCFileFolderModel.currentIndex===index || (image_top.currentlyVisibleIndex === index)
                    sourceComponent: Image {

                        id: img

                        parent: deleg
                        anchors.centerIn: parent
                        clip: false
                        asynchronous: true
                        mipmap: true
                        scale: deleg.defaultScale

                        Connections {
                            target: deleg
                            function onImageScaleChanged() {
                                scaleAnimation.restart()
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
                                deleg.defaultScale = Qt.binding(function() { return Math.min(1, Math.min(deleg.width/sourceSize.width, deleg.height/sourceSize.height)) })
                                image_top.currentlyVisibleIndex = deleg.itemIndex
                            }
                        }

                    }
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
