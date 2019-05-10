import QtQuick 2.9
import "./image/"

Item {

    id: container

    anchors.fill: parent

    signal zoomIn()
    signal zoomOut()

    signal hideOldImage()

    signal hideImageTemporary()
    signal showImageTemporary()
    property int hideTempX: 0
    property int hideTempY: 0

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

            PQImageAnimated {
                id: animated
            }

            PQImageNormal {
                id: normal
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
                    if(animated.source != "" && animated.status == Image.Loading)
                        loadingindicator.opacity = 1
                    else if(normal.source != "" && normal.status == Image.Loading)
                        loadingindicator.opacity = 1

                }

            }

            Connections {
                target: animated
                onStatusChanged:
                    if(animated.status == Image.Ready)
                        loadingindicator.opacity = 0
            }

            Connections {
                target: normal
                onStatusChanged:
                    if(normal.status == Image.Ready)
                        loadingindicator.opacity = 0
            }

        }

    }



    function loadImage(src) {
        hideOldImage()
        image_model.append({"src" : handlingFileDialog.cleanPath(src)})
    }

}
