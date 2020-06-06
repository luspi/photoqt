import QtQuick 2.9
import "./image/"

Item {

    id: container

    anchors.fill: parent
    anchors.leftMargin: variables.metaDataWidthWhenKeptOpen
    Behavior on anchors.leftMargin { NumberAnimation { duration: PQSettings.animationDuration*100 } }

    anchors.bottomMargin: ((PQSettings.thumbnailKeepVisible || PQSettings.thumbnailKeepVisibleWhenNotZoomedIn) && PQSettings.thumbnailPosition!="Top" && !PQSettings.thumbnailDisable && !variables.slideShowActive & !variables.faceTaggingActive) ? thumbnails.height : 0
    Behavior on anchors.bottomMargin { NumberAnimation { duration: PQSettings.animationDuration*100 } }

    anchors.topMargin: ((PQSettings.thumbnailKeepVisible || PQSettings.thumbnailKeepVisibleWhenNotZoomedIn) && PQSettings.thumbnailPosition=="Top" && !PQSettings.thumbnailDisable && !variables.slideShowActive && !variables.faceTaggingActive) ? thumbnails.height : 0
    Behavior on anchors.topMargin { NumberAnimation { duration: PQSettings.animationDuration*100 } }

    signal zoomIn()
    signal zoomOut()
    signal zoomReset()
    signal zoomActual()
    signal rotate(var deg)
    signal rotateReset()
    signal mirrorH()
    signal mirrorV()
    signal mirrorReset()

    signal playPauseAnim()

    signal hideAllImages()

    // emitted inside of PQImageNormal/Animated whenever its status changed to Image.Reader
    signal newImageLoaded(var id)

    // id
    property string imageLatestAdded: ""

    // currently shown index
    property int currentlyShownIndex: -1

    Repeater {

        id: repeat

        anchors.fill: parent

        model: ListModel {
            id: image_model
        }

        delegate: Item {

            id: deleg
            x: 0
            y: 0
            width: repeat.width
            height: repeat.height

            Loader {
                id: theimage
                property int imageStatus: Image.Loading
                onImageStatusChanged: {
                    if(imageStatus == Image.Ready && container.imageLatestAdded==deleg.uniqueid) {
                        hideShowAni.showing = true
                        hideShowAni.imageIndex = imageIndex
                        hideShowAni.startAni()
                        container.newImageLoaded(deleg.uniqueid)
                    }
                }
            }

            Connections {
                target: container
                onHideAllImages: {
                    hideShowAni.showing = false
                    hideShowAni.startAni()
                }
            }

            property string uniqueid: handlingGeneral.getUniqueId()

            Component.onCompleted: {
                container.imageLatestAdded = deleg.uniqueid
                theimage.source = (PQImageFormats.enabledFileformatsVideo.indexOf("*."+handlingFileDialog.getSuffix(src))>-1) ?
                                        "image/PQMovie.qml" :
                                        (imageproperties.isAnimated(src) ?
                                             "image/PQImageAnimated.qml" :
                                             "image/PQImageNormal.qml")
            }

            Connections {
                target: container
                onNewImageLoaded: {
                    if(id != deleg.uniqueid) {
                        if(hideShowAni.running) {
                            if(hideShowAni.showing)
                                hideShowAni.continueToDeleteAfterShowing = true
                        } else {
                            if(theimage.imageStatus == Image.Ready) {
                                hideShowAni.showing = false
                                // store pos/zoom/rotation/mirror, can be restored when setting enabled
                                variables.zoomRotationMirror[src] = [Qt.point(theimage.item.x, theimage.item.y),
                                                                     theimage.item.scale,
                                                                     theimage.item.rotation,
                                                                     theimage.item.mirror]
                                hideShowAni.startAni()
                            } else
                                image_model.remove(index)
                        }
                    }
                }
            }

            PropertyAnimation {
                id: hideShowAni
                target: deleg
                property: PQSettings.animationType
                duration: PQSettings.animationDuration*100
                property bool showing: true
                property bool continueToDeleteAfterShowing: false
                alwaysRunToEnd: true

                property int imageIndex: -1

                function startAni() {

                    var hideshow = ""

                    if(showing) {
                        if(imageIndex >= container.currentlyShownIndex)
                            hideshow = "left"
                        else
                            hideshow = "right"

                        container.currentlyShownIndex = imageIndex

                    } else {
                        if(imageIndex >= container.currentlyShownIndex)
                            hideshow = "right"
                        else
                            hideshow = "left"
                    }

                    if(showing) {

                        if(PQSettings.animationType == "x") {

                            if(hideshow == "left") {
                                from = container.width
                                to = PQSettings.marginAroundImage
                            } else {
                                from = -deleg.width
                                to = PQSettings.marginAroundImage
                            }

                        } else if(PQSettings.animationType == "y") {

                            if(hideshow == "left") {
                                from = container.height
                                to = PQSettings.marginAroundImage
                            } else {
                                from = -deleg.height
                                to = PQSettings.marginAroundImage
                            }

                        // we default to opacity
                        } else {
                            from = 0
                            to = 1
                        }

                    } else {

                        if(PQSettings.animationType == "x") {

                            if(hideshow == "left") {
                                from = deleg.x
                                to = -deleg.width
                            } else {
                                from = deleg.x
                                to = container.width
                            }

                        } else if(PQSettings.animationType == "y") {

                            if(hideshow == "left") {
                                from = deleg.x
                                to = -deleg.height
                            } else {
                                from = deleg.x
                                to = container.height
                            }

                        // we default to opacity
                        } else {
                            from = 1
                            to = 0
                        }

                    }

                    start()

                }

                onStopped: {
                    if(!showing)
                        image_model.remove(index)
                    else if(continueToDeleteAfterShowing) {
                        showing = false
                        startAni()
                    } else if(showing)
                        theimage.item.restorePosZoomRotationMirror()
                }

            }

        }

    }

    Connections {
        target: variables
        // The signal to hide old images is emitted whenever the new image has loaded (its status)
        onNewFileLoaded: {
            if(variables.indexOfCurrentImage > -1 && variables.indexOfCurrentImage < variables.allImageFilesInOrder.length) {
                var src = handlingFileDialog.cleanPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                image_model.append({"src" : src, "imageIndex" : variables.indexOfCurrentImage})
            } else if(variables.indexOfCurrentImage == -1 || variables.allImageFilesInOrder.length == 0)
                hideAllImages()
        }
    }

    function loadNextImage() {
        if(variables.indexOfCurrentImage < variables.allImageFilesInOrder.length-1)
            ++variables.indexOfCurrentImage
        else if(variables.indexOfCurrentImage == variables.allImageFilesInOrder.length-1 && PQSettings.loopThroughFolder)
            variables.indexOfCurrentImage = 0
        variables.newFileLoaded()
    }

    function loadPrevImage() {
        if(variables.indexOfCurrentImage > 0)
            --variables.indexOfCurrentImage
        else if(variables.indexOfCurrentImage == 0 && PQSettings.loopThroughFolder)
            variables.indexOfCurrentImage = variables.allImageFilesInOrder.length-1
        variables.newFileLoaded()
    }

    function loadFirstImage() {
        variables.indexOfCurrentImage = 0
        variables.newFileLoaded()
    }

    function loadLastImage() {
        variables.indexOfCurrentImage = variables.allImageFilesInOrder.length-1
        variables.newFileLoaded()
    }

    function playPauseAnimation() {
        container.playPauseAnim()
    }

}
