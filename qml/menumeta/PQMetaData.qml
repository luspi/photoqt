import QtQuick 2.9
import QtQuick.Controls 2.2

import "../elements"

Rectangle {

    id: metadata_top

    color: Qt.rgba(0, 0, 0, PQSettings.metadataOpacity/256)
    Behavior on color { ColorAnimation { duration: PQSettings.animationDuration*100 } }

    border.color: "#55bbbbbb"
    border.width: 1

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    width: (PQSettings.metadataPopoutElement ? parentWidth : PQSettings.metadataWindowWidth)
    height: parentHeight+2
    x: -1
    y: -1

    opacity: 0
    visible: opacity!=0
    Behavior on opacity { NumberAnimation { duration: PQSettings.metadataPopoutElement ? 0 : PQSettings.animationDuration*150 } }

    Connections {
        target: variables
        onMousePosChanged: {
            if(PQSettings.metadataPopoutElement || keepopen.checked)
                return
            if(variables.mousePos.x < (PQSettings.hotEdgeWidth+5) && PQSettings.metadataEnableHotEdge)
                metadata_top.opacity = 1
            else
                metadata_top.opacity = 0
        }
    }

    Component.onCompleted: {
        if(PQSettings.metadataPopoutElement)
                metadata_top.opacity = 1
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        PQMouseArea {

            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            width: 5

            cursorShape: Qt.SizeHorCursor

            enabled: !PQSettings.metadataPopoutElement

            tooltip: "Click and drag to resize meta data"

            property int oldMouseX

            onPressed:
                oldMouseX = mouse.x

            onReleased:
                PQSettings.metadataWindowWidth = metadata_top.width

            onPositionChanged: {
                if (pressed) {
                    var w = metadata_top.width + (mouse.x-oldMouseX)
                    if(w < 2*toplevel.width/3)
                        metadata_top.width = w
                }
            }

        }

    }

    property var allMetaData: [
        //: Keep string short!
        qsTranslate("metadata", "File name"), handlingGeneral.getFileNameFromFullPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage]),
        //: Keep string short!
        qsTranslate("metadata", "File size"), handlingGeneral.getFileSize(variables.allImageFilesInOrder[variables.indexOfCurrentImage]),
        //: Used as in "Image 3/16". The numbers (position of image in folder) are added on automatically. Keep string short!
        qsTranslate("metadata", "Image #/#"), (variables.indexOfCurrentImage+"/"+variables.allImageFilesInOrder.length),
        //: The dimensions of the loaded image. Keep string short!
        qsTranslate("metadata", "Dimensions"), cppmetadata.dimensions,
        "", "",
        //: Exif image metadata: the make of the camera used to take the photo. Keep string short!
        qsTranslate("metadata", "Make"), cppmetadata.exifImageMake,
        //: Exif image metadata: the model of the camera used to take the photo. Keep string short!
        qsTranslate("metadata", "Model"), cppmetadata.exifImageModel,
        //: Exif image metadata: the software used to create the photo. Keep string short!
        qsTranslate("metadata", "Software"), cppmetadata.exifImageSoftware,
        "", "",
        //: Exif image metadata: when the photo was taken. Keep string short!
        qsTranslate("metadata", "Time Photo was Taken"), cppmetadata.exifPhotoDateTimeOriginal,
        //: Exif image metadata: how long the sensor was exposed to the light. Keep string short!
        qsTranslate("metadata", "Exposure Time"), cppmetadata.exifPhotoExposureTime,
        //: Exif image metadata: the flash setting when the photo was taken. Keep string short!
        qsTranslate("metadata", "Flash"), cppmetadata.exifPhotoFlash,
        "ISO", cppmetadata.exifPhotoISOSpeedRatings,
        //: Exif image metadata: the specific scene type the camera used for the photo. Keep string short!
        qsTranslate("metadata", "Scene Type"), cppmetadata.exifPhotoSceneCaptureType,
        //: Exif image metadata: https://en.wikipedia.org/wiki/Focal_length . Keep string short!
        qsTranslate("metadata", "Focal Length"), cppmetadata.exifPhotoFocalLength,
        //: Exif image metadata: https://en.wikipedia.org/wiki/F-number . Keep string short!
        qsTranslate("metadata", "F Number"), cppmetadata.exifPhotoFNumber,
        //: Exif image metadata: What type of light the camera detected. Keep string short!
        qsTranslate("metadata", "Light Source"), cppmetadata.exifPhotoLightSource,
        "","",
        //: IPTC image metadata: A description of the image by the user/software. Keep string short!
        qsTranslate("metadata", "Keywords"), cppmetadata.iptcApplication2Keywords,
        //: IPTC image metadata: The CITY and COUNTRY the imge was taken in. Keep string short!
        qsTranslate("metadata", "Location"), cppmetadata.iptcLocation,
        //: IPTC image metadata. Keep string short!
        qsTranslate("metadata", "Copyright"), cppmetadata.iptcApplication2Copyright,
        "","",
        //: Exif image metadata. Keep string short!
        qsTranslate("metadata", "GPS Position"), cppmetadata.exifGPS
    ]

    // HEADING OF RECTANGLE
    Text {

        id: heading

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 10
        }

        horizontalAlignment: Qt.AlignHCenter

        color: "#ffffff"
        font.pointSize: 15
        font.bold: true

        text: em.pty+qsTr("Metadata")

    }

    Rectangle {

        id: separatorTop

        anchors {
            top: heading.bottom
            left: parent.left
            right: parent.right
            topMargin: 10
        }

        color: "#cccccc"
        height: 1

    }

    // Label at first start-up
    Text {

        anchors {
            top: separatorTop.bottom
            left: parent.left
            right: parent.right
            bottom: separatorBottom.bottom
            margins: 10
        }

        visible: variables.indexOfCurrentImage==-1

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        color: "#888888"
        font.bold: true
        font.pointSize: 18
        wrapMode: Text.WordWrap
        text: em.pty+qsTr("No File Loaded")

    }

    ListView {

        id: view

        anchors {
            top: separatorTop.bottom
            left: parent.left
            right: parent.right
            bottom: separatorBottom.top
            margins: 10
        }

        visible: variables.indexOfCurrentImage!==-1

        ScrollBar.vertical: PQScrollBar { id: scroll }

        model: allMetaData.length/2
        delegate: Item {

            width: parent.width
            height: (allMetaData[2*index+1] !== "" || (allMetaData[2*index]===""&&allMetaData[2*index+1]==="")) ? val.height : 0

            Text {

                id: val;

                visible: allMetaData[2*index+1] !== "" || (allMetaData[2*index]===""&&allMetaData[2*index+1]==="")

                color: "#ffffff"
                font.pointSize: PQSettings.metadataFontSize
                lineHeight: ((allMetaData[2*index] == "" ? 0.8 : 1.3))
                textFormat: Text.RichText
                width: parent.width
                wrapMode: Text.WordWrap
                text: (allMetaData[2*index] !== "") ? ("<b>" + allMetaData[2*index] + "</b>: " + allMetaData[2*index +1]) : ""

            }

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                tooltip: (index==((allMetaData.length/2) -1)) ?
                             em.pty+qsTr("Click to open GPS position with online map") :
                             (visible ? "<b>" + allMetaData[2*index] + "</b><br>" + allMetaData[2*index+1] : "")
                cursorShape: index==(allMetaData.length/2 -1) ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if(index == allMetaData.length/2 -1) {

                        if(PQSettings.metaGpsMapService == "bing.com/maps")
                            Qt.openUrlExternally("http://www.bing.com/maps/?sty=r&q=" + allMetaData[2*index+1] + "&obox=1")
                        else if(PQSettings.metaGpsMapService == "maps.google.com")
                            Qt.openUrlExternally("http://maps.google.com/maps?t=h&q=" + allMetaData[2*index+1])
                        else {

                            // For openstreetmap.org, we need to convert the GPS location into decimal format

                            var one = allMetaData[2*index+1].split(", ")[0]
                            var one_dec = 1*one.split("°")[0] + (1*(one.split("°")[1].split("'")[0]))/60 + (1*(one.split("'")[1].split("''")[0]))/3600
                            if(one.indexOf("S") !== -1)
                                one_dec *= -1;

                            var two = allMetaData[2*index+1].split(", ")[1]
                            var two_dec = 1*two.split("°")[0] + (1*(two.split("°")[1].split("'")[0]))/60 + (1*(two.split("'")[1].split("''")[0]))/3600
                            if(two.indexOf("W") !== -1)
                                two_dec *= -1;

                            Qt.openUrlExternally("http://www.openstreetmap.org/#map=15/" + "" + one_dec + "/" + two_dec)
                        }

                    }
                }
            }

        }

    }



    Rectangle {
        id: separatorBottom
        anchors {
            bottom: keepopen.top
            left: parent.left
            right: parent.right
            bottomMargin: 5
        }

        height: PQSettings.metadataPopoutElement ? 0 : 1
        color: "#cccccc"
    }

    PQCheckbox {

        id: keepopen

        visible: !PQSettings.metadataPopoutElement

        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: 5
            bottomMargin: 5
        }

        onCheckedChanged:
            variables.metaDataWidthWhenKeptOpen = (checked ? metadata_top.width : 0)

        //: Used as in 'Keep the metadata element open even if the cursor leaves it'
        text: PQSettings.metadataPopoutElement ? "" : (em.pty+qsTr("Keep Open"))

    }

    Connections {
        target: loader
        onMetadataPassOn: {
            if(what == "toggle") {
                if(keepopen.checked) {
                    keepopen.checked = false
                    opacity = 0
                    variables.metaDataWidthWhenKeptOpen = 0
                } else {
                    keepopen.checked = true
                    opacity = 1
                    variables.metaDataWidthWhenKeptOpen = metadata_top.width
                }
            }
        }
    }

}
