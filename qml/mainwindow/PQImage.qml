import QtQuick 2.9
import "./image/"

Item {

    id: container

    anchors.fill: parent

    signal zoomIn()
    signal zoomOut()
    signal zoomReset()

    // emitted inside of PQImageNormal/Animated whenever its status changed to Image.Reader
    signal hideOldImage(var forwards)

    property int hideTempX: 0
    property int hideTempY: 0

    property bool imageSwitchingForwards: true
    property string imageLatestAdded: ""

    MouseArea {

        anchors.fill: parent

        onWheel: {
            if(wheel.angleDelta.y < 0)
                zoomOut()
            else if(wheel.angleDelta.y > 0)
                zoomIn()
        }

    }

    Repeater {

        id: repeat

        anchors.fill: parent

        model: ListModel {
            id: image_model
        }

        delegate: Item {

            Loader {
                id: theimage
                property int imageStatus: Image.Null
            }

            Component.onCompleted: {
                theimage.source = (imageproperties.isAnimated(src) ? "image/PQImageAnimated.qml" : "image/PQImageNormal.qml")
            }

            PQLoading {
                id: loadingindicator
            }

            // This timer allows for a little timeout before the loading indicator is shown
            // Most images are loaded pretty quickly, no need to bother with this indicator for those
            Timer {

                id: showLoadingImage

                // show indicator if the image takes more than 500ms to load
                interval: 1000
                repeat: false
                running: true

                // show indicator only if the mainimage hasn't finished loading in the meantime
                onTriggered: {
                    if(theimage.imageStatus == Image.Loading)
                        loadingindicator.opacity = 1

                }

            }

            Connections {
                target: theimage
                onImageStatusChanged:
                    if(theimage.imageStatus == Image.Ready)
                        loadingindicator.opacity = 0
            }

        }

    }

    Connections {
        target: variables
        // we load the new image whenever one of the below properties has changed. The signal to hide old images is emitted whenever the new image has loaded (its status)
        onIndexOfCurrentImageChanged: {
            if(variables.allImageFilesInOrder.length > 0 && variables.indexOfCurrentImage > -1) {
                image_model.append({"src" : handlingFileDialog.cleanPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage]), "forwards" : imageSwitchingForwards})
                imageLatestAdded = handlingFileDialog.cleanPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
            }
        }
        onAllImageFilesInOrderChanged: {
            if(variables.allImageFilesInOrder.length > 0 && variables.indexOfCurrentImage > -1) {
                image_model.append({"src" : handlingFileDialog.cleanPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage]), "forwards" : imageSwitchingForwards})
                imageLatestAdded = handlingFileDialog.cleanPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
            }
        }
    }


    function loadNextImage() {
        imageSwitchingForwards = true
        if(variables.indexOfCurrentImage < variables.allImageFilesInOrder.length-1)
            ++variables.indexOfCurrentImage
        else if(variables.indexOfCurrentImage == variables.allImageFilesInOrder.length-1 && settings.loopThroughFolder)
            variables.indexOfCurrentImage = 0
    }

    function loadPrevImage() {
        imageSwitchingForwards = false
        if(variables.indexOfCurrentImage > 0)
            --variables.indexOfCurrentImage
        else if(variables.indexOfCurrentImage == 0 && settings.loopThroughFolder)
            variables.indexOfCurrentImage = variables.allImageFilesInOrder.length-1
    }

    function loadFirstImage() {
        imageSwitchingForwards = false
        variables.indexOfCurrentImage = 0
    }

    function loadLastImage() {
        imageSwitchingForwards = true
        variables.indexOfCurrentImage = variables.allImageFilesInOrder.length-1
    }

    function resetZoom() {

    }

}
