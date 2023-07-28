import QtQuick

AnimatedImage {

    id: image

    source: "file:/" + PQCScriptsFilesPaths.toPercentEncoding(deleg.imageSource)

    onWidthChanged:
        image_wrapper.width = width
    onHeightChanged:
        image_wrapper.height = height

    onSourceSizeChanged: {
        console.log("ss:", sourceSize)
        width = sourceSize.width
        height = sourceSize.height
        image_wrapper.status = Image.Ready
    }

    Component.onCompleted:
        console.log("animated...")

}
