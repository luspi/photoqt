import QtQuick 2.9
import "./image/"

Item {

    id: container

    anchors.fill: parent
    anchors.leftMargin: variables.metaDataWidthWhenKeptOpen
    Behavior on anchors.leftMargin { NumberAnimation { duration: PQSettings.animationDuration*100 } }

    anchors.bottomMargin: ((PQSettings.thumbnailKeepVisible || PQSettings.thumbnailKeepVisibleWhenNotZoomedIn) && PQSettings.thumbnailPosition!="Top" && !PQSettings.thumbnailDisable && !variables.slideShowActive) ? thumbnails.height : 0
    Behavior on anchors.bottomMargin { NumberAnimation { duration: 150 } }

    anchors.topMargin: ((PQSettings.thumbnailKeepVisible || PQSettings.thumbnailKeepVisibleWhenNotZoomedIn) && PQSettings.thumbnailPosition=="Top" && !PQSettings.thumbnailDisable && !variables.slideShowActive) ? thumbnails.height : 0
    Behavior on anchors.topMargin { NumberAnimation { duration: 150 } }

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

    property string imageLatestAdded: ""

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
                        hideShowAni.start()
                        container.newImageLoaded(deleg.uniqueid)
                    }
                }
            }

            Connections {
                target: container
                onHideAllImages: {
                    hideShowAni.showing = false
                    hideShowAni.start()
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
                                hideShowAni.start()
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
                duration: (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                property bool showing: true
                property bool continueToDeleteAfterShowing: false
                alwaysRunToEnd: true
                from: showing ?
                          (hideShowAni.property=="opacity" ?
                              0 :
                              (hideShowAni.property=="x" ?
                                  -deleg.width :
                                  -deleg.height)) :
                          (hideShowAni.property=="opacity" ?
                              1 :
                              (hideShowAni.property=="x" ?
                                  deleg.x:
                                  deleg.y))
                to: showing ?
                        (hideShowAni.property=="opacity" ?
                            1 :
                            (hideShowAni.property=="x" ?
                                PQSettings.marginAroundImage :
                                PQSettings.marginAroundImage)) :
                        (hideShowAni.property=="opacity" ?
                            0 :
                            (hideShowAni.property=="x" ?
                                container.width:
                                container.height))
                onStopped: {
                    if(!showing)
                        image_model.remove(index)
                    else if(continueToDeleteAfterShowing) {
                        showing = false
                        start()
                    }
                }

            }

        }

    }

    Connections {
        target: variables
        // we load the new image whenever one of the below properties has changed. The signal to hide old images is emitted whenever the new image has loaded (its status)
        onIndexOfCurrentImageChanged: {
            if(variables.indexOfCurrentImage > -1 && variables.indexOfCurrentImage < variables.allImageFilesInOrder.length)
                image_model.append({"src" : handlingFileDialog.cleanPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage])})
            else if(variables.indexOfCurrentImage == -1 || variables.allImageFilesInOrder.length == 0)
                hideAllImages()
        }
        onAllImageFilesInOrderChanged: {
            if(variables.indexOfCurrentImage > -1 && variables.indexOfCurrentImage < variables.allImageFilesInOrder.length)
                image_model.append({"src" : handlingFileDialog.cleanPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage])})
            else if(variables.indexOfCurrentImage == -1 || variables.allImageFilesInOrder.length == 0)
                hideAllImages()
        }
    }


    function loadNextImage() {
        if(variables.indexOfCurrentImage < variables.allImageFilesInOrder.length-1)
            ++variables.indexOfCurrentImage
        else if(variables.indexOfCurrentImage == variables.allImageFilesInOrder.length-1 && PQSettings.loopThroughFolder)
            variables.indexOfCurrentImage = 0
    }

    function loadPrevImage() {
        if(variables.indexOfCurrentImage > 0)
            --variables.indexOfCurrentImage
        else if(variables.indexOfCurrentImage == 0 && PQSettings.loopThroughFolder)
            variables.indexOfCurrentImage = variables.allImageFilesInOrder.length-1
    }

    function loadFirstImage() {
        variables.indexOfCurrentImage = 0
    }

    function loadLastImage() {
        variables.indexOfCurrentImage = variables.allImageFilesInOrder.length-1
    }

    function playPauseAnimation() {
        container.playPauseAnim()
    }

}
