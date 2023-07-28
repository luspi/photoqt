import QtQuick

Image {

    id: image

    source: "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(deleg.imageSource)

    onWidthChanged:
        image_wrapper.width = width
    onHeightChanged:
        image_wrapper.height = height

    onStatusChanged: {
        console.log(width, height, sourceSize)
        image_wrapper.status = status
    }

    Component.onCompleted:
        console.log("normal...")

}
