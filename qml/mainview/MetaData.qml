/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick 2.5
import QtQuick.Controls 1.4

import "../elements"

Item {

    id: meta

    // Set up model on first load, afetrwards just change data
    property bool imageLoaded: false

    // make sure settings values are valid
    property int settingsMetadataWindowWidth: Math.max(Math.min(settings.metadataWindowWidth, background.width/2), 300)
    property real settingsMetadataOpacity: Math.min(Math.max(settings.metadataOpacity/255, 0), 1)
    property int settingsMetadataFontSize: Math.max(5, Math.min(20, settings.metadataFontSize))

    // Adjust size
    width: settingsMetadataWindowWidth
    anchors {
        left: mainwindow.left
        top: mainwindow.top
        bottom: mainwindow.bottom
        margins: -1
    }

    // This is for the background color, allows adjusting opacity without affecting the text
    Rectangle {

        id: bgcolor

        anchors.fill: parent

        // Background/Border color
        color: colour.fadein_slidein_bg
        border.width: 1
        border.color: colour.fadein_slidein_border

        // Opacity is between 0 and 1 and depends on settings
        opacity: settingsMetadataOpacity

    }


    property int nonFloatWidth: getButtonState() ? width : 0

    opacity: 0
    visible: opacity!=0
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

    // This mouseare catches all mouse movements and prevents them from being passed on to the background
    MouseArea {
        anchors.fill: parent;
        hoverEnabled: true;
        onPositionChanged: {
            // Make sure the mouse cursor is visible (might be hidden from Timer in HandleMouseMove)
            handlemousemovements.stopHideMouseCursorAfterTimeoutTimer()
            getanddostuff.showCursor()
        }
    }

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

        color: colour.text
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

        color: colour.linecolour
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

        visible: !imageLoaded && !unsupportedLabel.visible && !invalidLabel.visible

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        color: colour.bg_label
        font.bold: true
        font.pointSize: 18
        wrapMode: Text.WordWrap
        text: em.pty+qsTr("No File Loaded")

    }

    Text {

        id: unsupportedLabel

        anchors {
            top: separatorTop.bottom
            left: parent.left
            right: parent.right
            bottom: separatorBottom.bottom
            margins: 10
        }

        visible: false

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        color: colour.bg_label
        font.bold: true
        font.pointSize: 18
        wrapMode: Text.WordWrap

        text: em.pty+qsTr("File Format Not Supported")

    }

    Text {

        id: invalidLabel

        anchors {
            top: separatorTop.bottom
            left: parent.left
            right: parent.right
            bottom: separatorBottom.bottom
            margins: 10
        }

        visible: false

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        color: colour.bg_label
        font.bold: true
        font.pointSize: 18
        wrapMode: Text.WordWrap

        text: em.pty+qsTr("Invalid File")

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

        visible: imageLoaded

        model: ListModel { id: mod; }
        delegate: deleg

    }

    Rectangle {
        id: separatorBottom
        anchors {
            bottom: keepopen.top
            left: parent.left
            right: parent.right
            bottomMargin: 10
        }

        height: 1
        color: colour.linecolour
    }

    Rectangle {

        id: keepopen

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            bottomMargin: 10
        }

        height: check.height
        color: "#00000000"

        CustomCheckBox {

            id: check

            textOnRight: false

            anchors.right: parent.right
            anchors.rightMargin: 5

            fsize: 8
            textColour: "#64" + colour.text.substring(1,colour.text.length)
            //: Used as in 'Keep the metadata element open even if the cursor leaves it'

            text: em.pty+qsTr("Keep Open")

            onButtonCheckedChanged:
                updateNonFloatWidth()

        }
    }
    function updateNonFloatWidth() {
        verboseMessage("MainView/MetaData", "updateNonFloatWidth(): " + check.checkedButton + " - " + nonFloatWidth + " - " + meta.width)
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
                font.pointSize: settingsMetadataFontSize
                lineHeight: (name == "" ? 0.8 : 1.3);
                textFormat: Text.RichText
                width: parent.width
                wrapMode: Text.WordWrap
                text: name !== "" ? "<b>" + name + "</b>: " + value : ""

                ToolTip {
                    text: prop=="Exif.GPSInfo.GPSLongitudeRef" ? em.pty+qsTr("Click to open GPS position with online map")
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

    Connections {
        target: watcher
        onImageUpdated:
            setData(getmetadata.getExiv2(variables.currentDir + "/" + variables.currentFileWithoutExtras))
    }

    function setData(d) {

        verboseMessage("MainView/MetaData", "setData()")

        if(variables.currentFile == "")
            return

        invalidLabel.visible = false
        unsupportedLabel.visible = false
        view.visible = false

        if(d["validfile"] === "0") {
            verboseMessage("MainView/MetaData", "setData(): Invalid file")
            invalidLabel.visible = true
        } else {

            view.visible = true

            mod.clear()

            if(settings.metaFilename) {
                var fname = getanddostuff.removePathFromFilename(variables.currentFileWithoutExtras, false)
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

            if(d["supported"] !== "0") {

                if(settings.metaDimensions) {
                    if("dimensions" in d)
                        //: The dimensions of the loaded image. Keep string short!
                        mod.append({"name" : qsTranslate("metadata", "Dimensions"),
                                    "prop" : "",
                                    "value" : d["dimensions"],
                                    "tooltip" : d["dimensions"]})
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
                    if(d[labels[i]] === undefined && d[labels[i+1]] === undefined)
                        continue
                    if(labels[i] === "" && labels[i+1] === "") {
                        if(!oneEmpty) {
                            oneEmpty = true
                            mod.append({"name" : "", "prop" : "", "value" : "", "tooltip" : ""})
                        }
                    } else if(d[labels[i]] !== "" && d[labels[i+1]] !== "") {
                        oneEmpty = false;
                        mod.append({"name" : labels[i+1],
                                "prop" : labels[i],
                                "value" : d[labels[i]],
                                "tooltip" : d[labels[i+2] === "" ? d[labels[i]] : d[labels[i+2]]]})
                    }
                }

            }

            view.model = mod
            imageLoaded = true

        }

    }

    function gpsClick(value) {

        verboseMessage("MainView/MetaData", "gpsClick(): " + value)

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
        if(opacity == 1) verboseMessage("MainView/MetaData", "hide()")
        if(!check.checkedButton)
            opacity = 0
    }
    function show() {
        if(opacity != 0) verboseMessage("MainView/MetaData", "show()")
        opacity = 1
    }

    function clickInMetaData(pos) {
        verboseMessage("MainView/MetaData", "clickInMetaData(): " + pos)
        var ret = meta.contains(meta.mapFromItem(mainwindow,pos.x,pos.y))
        return ret
    }

}
