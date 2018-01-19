import QtQuick 2.5
import QtQuick.Controls 1.4

import "../elements"

Rectangle {

    id: meta

    // Set up model on first load, afetrwards just change data
    property bool imageLoaded: false

    property string orientation: ""

    // Background/Border color
    color: colour.fadein_slidein_bg
    border.width: 1
    border.color: colour.fadein_slidein_border

    // Set position (we pretend that rounded corners are along the right edge only, that's why visible x is off screen)
    x: -1
    y: -1

    // Adjust size
    width: settings.metadataWindowWidth
    height: parent.height+2

    property int nonFloatWidth: getButtonState() ? width : 0

    opacity: 0
    visible: opacity!=0
    Behavior on opacity { NumberAnimation { duration: 250; } }

    // This mouseare catches all mouse movements and prevents them from being passed on to the background
    MouseArea { anchors.fill: parent; hoverEnabled: true }

    // HEADING OF RECTANGLE
    Text {

        id: heading
        y: 10
        x: (parent.width-width)/2
        font.pointSize: 15
        color: colour.text
        font.bold: true
        text: qsTr("Metadata")

    }

    Rectangle {
        id: spacingbelowheader
        x: 5
        y: heading.y+heading.height+10
        height: 1
        width: parent.width-10
        color: "white"
    }

    // Label at first start-up
    Text {

        anchors.fill: parent

        color: colour.bg_label

        visible: !imageLoaded && !unsupportedLabel.visible && !invalidLabel.visible
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        font.bold: true
        font.pointSize: 18
        wrapMode: Text.WordWrap
        text: qsTr("No File Loaded")

    }

    Text {

        id: unsupportedLabel

        anchors.fill: parent

        color: colour.bg_label

        visible: false
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        font.bold: true
        font.pointSize: 18
        wrapMode: Text.WordWrap
        text: qsTr("File Format Not Supported")

    }

    Text {

        id: invalidLabel

        anchors.fill: parent

        color: colour.bg_label

        visible: false
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        font.bold: true
        font.pointSize: 18
        wrapMode: Text.WordWrap
        text: qsTr("Invalid File")

    }

    ListView {

        id: view

        x: 10
        y: spacingbelowheader.y + spacingbelowheader.height + 10

        width: childrenRect.width
        height: parent.height - spacingbelowheader.y-spacingbelowheader.height-20 - check.height-10

        visible: imageLoaded
        model: ListModel { id: mod; }
        delegate: deleg

    }

    Rectangle {
        id: spacing
        width: meta.width
        height: 1
        x: 0
        y: view.height+view.y
        color: colour.linecolour
    }

    Rectangle {
        id: keepopen
        color: "#00000000"
        x: 0
        y: view.height+view.y+spacing.height+3 + 5
        width: meta.width
        CustomCheckBox {
            id: check
            textOnRight: false
            anchors.right: parent.right
            anchors.rightMargin: 5
            fsize: 8
            textColour: "#64" + colour.text.substring(1,colour.text.length)
            //: Used as in 'Keep the metadata element open even if the cursor leaves it'
            text: qsTr("Keep Open")
            onButtonCheckedChanged:
                updateNonFloatWidth()
        }
    }
    function updateNonFloatWidth() {
        verboseMessage("MetaData::updateNonFloatWidth()",check.checkedButton + " - " + nonFloatWidth + " - " + meta.width)
        if(check.checkedButton)
            nonFloatWidth = meta.width
        else
            nonFloatWidth = 0
    }

    function uncheckCheckbox() { check.checkedButton = false; }
    function checkCheckbox() { check.checkedButton = true; }
    function getButtonState() { return check.checkedButton; }

    Component {

        id: deleg

        Rectangle {

            id: rect

            color: "#00000000";
            height: val.height;
            width: meta.width-view.x*2

            Text {

                id: val;

                visible: imageLoaded
                color: colour.text
                font.pointSize: settings.metadataFontSize
                lineHeight: (name == "" ? 0.8 : 1.3);
                textFormat: Text.RichText
                width: parent.width
                wrapMode: Text.WordWrap
                text: name !== "" ? "<b>" + name + "</b>: " + value : ""

                ToolTip {
                    text: prop=="Exif.GPSInfo.GPSLongitudeRef" ? qsTr("Click to open GPS position with online map")
                                    : (name !== "" ? "<b>" + name + "</b><br>" + value : "")
                    anchors.fill: parent
                    cursorShape: prop == "Exif.GPSInfo.GPSLongitudeRef" ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if(prop == "Exif.GPSInfo.GPSLongitudeRef")
                            gpsClick(value)
                    }
                }

            }

        }

    }

    MouseArea {
        x: parent.width-8
        width: 8
        y: 0
        height: parent.height
        cursorShape: Qt.SplitHCursor
        property int oldMouseX

        onPressed:
            oldMouseX = mouseX

        onReleased: {
            updateNonFloatWidth()
            settings.metadataWindowWidth = parent.width
        }

        onPositionChanged: {
            if (pressed) {
                var w = parent.width + (mouseX - oldMouseX)
                if(w >= 250 && w <= background.width/2)
                    parent.width = w
            }
        }
    }

    Connections {
        target: variables
        onFilterNoMatchChanged:
            if(variables.filterNoMatch)
                clear()
        onDeleteNothingLeftChanged:
            if(variables.deleteNothingLeft)
                clear()
        onGuiBlockedChanged: {
            if(variables.guiBlocked && meta.opacity == 1)
                meta.opacity = 0.2
            else if(!variables.guiBlocked && meta.opacity == 0.2)
                meta.opacity = 1
        }
    }

    function setData(d) {

        if(variables.currentFile == "")
            return

        invalidLabel.visible = false
        unsupportedLabel.visible = false
        view.visible = false

        if(d["validfile"] == "0") {
            verboseMessage("MetaData::setData()","Invalid file")
            invalidLabel.visible = true
        } else {

            if(d["supported"] == "0") {
                verboseMessage("MetaData::setData()","Unsupported file format")
                unsupportedLabel.visible = true
            } else {

                verboseMessage("MetaData::setData()","Setting data")

                orientation = d["Exif.Image.Orientation"]

                view.visible = true

                mod.clear()

                if(settings.metaFilename) {
                    var fname = getanddostuff.removePathFromFilename(variables.currentFile, false)
                    //: Keep string short!
                    mod.append({"name" : qsTranslate("metadata", "Filename"), "prop" : "", "value" : fname, "tooltip" : fname })
                }

                if(settings.metaFileSize)
                    //: Keep string short!
                    mod.append({"name" : qsTranslate("metadata", "Filesize"), "prop" : "", "value" : d["filesize"], "tooltip" : d["filesize"]})

                if(settings.metaImageNumber) {
                    var pos = (variables.currentFilePos+1) + "/" + variables.totalNumberImagesCurrentFolder
                    //: Used as in "Image 3/16". The numbers (position of image in folder) are added on automatically. Keep string short!
                    mod.append({"name" : qsTranslate("metadata", "Image") + " #/#", "prop" : "", "value" : pos, "tooltip" : pos })
                }

                if(settings.metaDimensions) {
                    if("dimensions" in d)
                        //: The dimensions of the loaded image. Keep string short!
                        mod.append({"name" : qsTranslate("metadata", "Dimensions"), "prop" : "", "value" : d["dimensions"], "tooltip" : d["dimensions"]})
                    else if("Exif.Photo.PixelXDimension" in d && "Exif.Photo.PixelYDimension" in d) {
                        var dim = d["Exif.Photo.PixelXDimension"] + "x" + d["Exif.Photo.PixelYDimension"]
                        //: The dimensions of the loaded image. Keep string short!
                        mod.append({"name" : qsTranslate("metadata", "Dimensions"), "prop" : "", "value" : dim, "tooltip" : dim})
                    }
                }

                mod.append({"name" : "", "prop" : "", "value" : ""})

                //: Exif image metadata: the make of the camera used to take the photo. Keep string short!
                var labels = ["Exif.Image.Make", qsTranslate("metadata", "Make"), "",
                        //: Exif image metadata: the model of the camera used to take the photo. Keep string short!
                        "Exif.Image.Model", qsTranslate("metadata", "Model"), "",
                        //: Exif image metadata: the software used to create the photo. Keep string short!
                        "Exif.Image.Software", qsTranslate("metadata", "Software"), "",
                        "","", "",
                        //: Exif image metadata: when the photo was taken. Keep string short!
                        "Exif.Photo.DateTimeOriginal", qsTranslate("metadata", "Time Photo was Taken"), "",
                        //: Exif image metadata: how long the sensor was exposed to the light. Keep string short!
                        "Exif.Photo.ExposureTime", qsTranslate("metadata", "Exposure Time"), "",
                        //: Exif image metadata: the flash setting when the photo was taken. Keep string short!
                        "Exif.Photo.Flash", qsTranslate("metadata", "Flash"), "",
                        "Exif.Photo.ISOSpeedRatings", "ISO", "",
                        //: Exif image metadata: the specific scene type the camera used for the photo. Keep string short!
                        "Exif.Photo.SceneCaptureType", qsTranslate("metadata", "Scene Type"), "",
                        //: Exif image metadata: https://en.wikipedia.org/wiki/Focal_length . Keep string short!
                        "Exif.Photo.FocalLength", qsTranslate("metadata", "Focal Length"), "",
                        //: Exif image metadata: https://en.wikipedia.org/wiki/F-number . Keep string short!
                        "Exif.Photo.FNumber", qsTranslate("metadata", "F Number"), "",
                        //: Exif image metadata: What type of light the camera detected. Keep string short!
                        "Exif.Photo.LightSource", qsTranslate("metadata", "Light Source"), "",
                        "","", "",
                        //: IPTC image metadata: A description of the image by the user/software. Keep string short!
                        "Iptc.Application2.Keywords", qsTranslate("metadata", "Keywords"), "",
                        //: IPTC image metadata: The CITY the imge was taken in. Keep string short!
                        "Iptc.Application2.City", qsTranslate("metadata", "Location"), "",
                        //: IPTC image metadata. Keep string short!
                        "Iptc.Application2.Copyright", qsTranslate("metadata", "Copyright"), "",
                        "","", "",
                        //: Exif image metadata. Keep string short!
                        "Exif.GPSInfo.GPSLongitudeRef", qsTranslate("metadata", "GPS Position"), "Exif.GPSInfo.GPSLatitudeRef",
                        "","",""]

                var oneEmpty = false;

                for(var i = 0; i < labels.length; i+=3) {
                    if(labels[i] == "" && labels[i+1] == "") {
                        if(!oneEmpty) {
                            oneEmpty = true
                            mod.append({"name" : "", "prop" : "", "value" : "", "tooltip" : ""})
                        }
                    } else if(d[labels[i]] != "" && d[labels[i+1]] != "") {
                        oneEmpty = false;
                        mod.append({"name" : labels[i+1],
                                "prop" : labels[i],
                                "value" : d[labels[i]],
                                "tooltip" : d[labels[i+2] == "" ? d[labels[i]] : d[labels[i+2]]]})
                    }
                }

                view.model = mod
                imageLoaded = true

            }

        }

    }

    function gpsClick(value) {

        verboseMessage("MetaData::gpsClick()",value + " - " + settings.metaGpsMapService)

        if(settings.metaGpsMapService == "bing.com/maps")
            Qt.openUrlExternally("http://www.bing.com/maps/?sty=r&q=" + value + "&obox=1")
        else if(settings.metaGpsMapService == "maps.google.com")
            Qt.openUrlExternally("http://maps.google.com/maps?t=h&q=" + value)
        else {

            // For openstreetmap.org, we need to convert the GPS location into decimal format

            var one = value.split(", ")[0]
            var one_dec = 1*one.split("°")[0] + (1*(one.split("°")[1].split("'")[0]))/60 + (1*(one.split("'")[1].split("''")[0]))/3600
            if(one.indexOf("S") !== -1)
                one_dec *= -1;

            var two = value.split(", ")[1]
            var two_dec = 1*two.split("°")[0] + (1*(two.split("°")[1].split("'")[0]))/60 + (1*(two.split("'")[1].split("''")[0]))/3600
            if(two.indexOf("W") !== -1)
                two_dec *= -1;

            Qt.openUrlExternally("http://www.openstreetmap.org/#map=15/" + "" + one_dec + "/" + two_dec)
        }

    }

    function clear() {
        imageLoaded = false
    }



    function hide() {
        if(!check.checkedButton) {
            if(opacity != 0) verboseMessage("MetaData::hide()", opacity + " to 0")
            opacity = 0
        }
    }
    function show() {
        if(opacity != 1) verboseMessage("MetaData::show()", opacity + " to 1")
        opacity = 1
    }

    function clickInMetaData(pos) {
        var ret = meta.contains(meta.mapFromItem(mainwindow,pos.x,pos.y))
        verboseMessage("MetaData::clickInMetaData()", pos)
        return ret
    }

}
