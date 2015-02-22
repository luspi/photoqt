import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

    id: meta

    // Set up model on first load, afetrwards just change data
    property bool imageLoaded: false

    // Background color
    color: "#CC000000"

    // Set position (we pretend that rounded corners are along the right edge only, that's why visible x is off screen)
    x: -width
    y: (parent.height-meta.height)/3

    // Adjust size
    width: ((view.width+2*radius < 350) ? 350 : view.width+2*radius)
    height: ((imageLoaded) ? (view.contentHeight > width/2 ? view.contentHeight : width/2) : width)+2*check.height

    // Corner radius
    radius: 10

    // Label at first start-up
    Text {

        anchors.fill: parent

        color: "grey"

        visible: !imageLoaded
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        font.bold: true
        font.pointSize: 18
        text: "No File Loaded"

    }

    Text {

        id: unsupportedLabel

        anchors.fill: parent

        color: "grey"

        visible: false
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        font.bold: true
        font.pointSize: 18
        text: "File Format Not Supported"

    }

    Text {

        id: invalidLabel

        anchors.fill: parent

        color: "grey"

        visible: false
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        font.bold: true
        font.pointSize: 18
        text: "Invalid File"

    }

    ListView {

        id: view

        x: meta.radius+10
        y: radius

        width: childrenRect.width
        height: meta.height-2*check.height

        visible: imageLoaded
        model: ListModel { id: mod; }
        delegate: deleg

    }

    Rectangle {
        id: keepopen
        color: "#00000000"
        x: 0
        y: view.height+view.y
        width: meta.width
        CustomCheckBox {
            id: check
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Keep Open"
            onCheckedChanged: {
                settingssession.setValue("metadatakeepopen",check.checked)
            }
        }
    }
    function uncheckCheckbox() { check.checked = false; }
    function checkCheckbox() { check.checked = true; }

    Component {

        id: deleg

        Rectangle {

            id: rect

            color: "#00000000";
            height: val.height;

            Text {

                id: val;

                color: "white";
                font.pointSize: settings.exiffontsize
                lineHeight: (name == "" ? 0.8 : 1.3);
                text: name != "" ? "<b>" + name + "</b>: " + value : "";

            }

        }

    }

    function setData(d) {

        invalidLabel.visible = false
        unsupportedLabel.visible = false
        view.visible = false

        if(d["validfile"] == "0")
            invalidLabel.visible = true
        else {

            if(d["supported"] == "0")
                unsupportedLabel.visible = true
            else {

                view.visible = true

                mod.clear()

                mod.append({"name" : "Filesize", "value" : d["filesize"], "tooltip" : d["filesize"]})
                if("dimensions" in d)
                    mod.append({"name" : "Dimensions", "value" : d["dimensions"], "tooltip" : d["dimensions"]})
                else if("Exif.Photo.PixelXDimension" in d && "Exif.Photo.PixelYDimension" in d) {
                    var dim = d["Exif.Photo.PixelXDimension"] + "x" + d["Exif.Photo.PixelYDimension"]
                    mod.append({"name" : "Dimensions", "value" : dim, "tooltip" : dim})
                }

                mod.append({"name" : "", "value" : ""})

                var labels = ["Exif.Image.Make", "Make", "",
                    "Exif.Image.Model", "Model", "",
                    "Exif.Image.Software", "Software", "",
                    "","", "",
                    "Exif.Photo.DateTimeOriginal", "Time Photo was Taken", "",
                    "Exif.Photo.ExposureTime", "Exposure Time", "",
                    "Exif.Photo.Flash", "Flash", "",
                    "Exif.Photo.ISOSpeedRatings", "ISO", "",
                    "Exif.Photo.SceneCaptureType", "Scene Type", "",
                    "Exif.Photo.FocalLength", "Focal Length", "",
                    "Exif.Photo.FNumber", "F Number", "",
                    "Exif.Photo.LightSource", "Light Source", "",
                    "","", "",
                    "Iptc.Application2.Keywords", "Keywords", "",
                    "Iptc.Application2.City", "Location", "",
                    "Iptc.Application2.Copyright", "Copyright", "",
                    "","", "",
                    "Exif.GPSInfo.GPSLongitudeRef", "GPS Position", "Exif.GPSInfo.GPSLatitudeRef",
                    "","",""]


                /*

                  Exif.Image.Orientation


                  */

                var oneEmpty = false;

                for(var i = 0; i < labels.length; i+=3) {
                    if(labels[i] == "" && labels[i+1] == "") {
                        if(!oneEmpty) {
                            oneEmpty = true
                            mod.append({"name" : "", "value" : "", "tooltip" : ""})
                        }
                    } else if(d[labels[i]] != "" && d[labels[i+1]] != "") {
                        oneEmpty = false;
                        mod.append({"name" : labels[i+1],
                                       "value" : d[labels[i]],
                                       "tooltip" : d[labels[i+2] == "" ? d[labels[i]] : d[labels[i+2]]]})
                    }
                }

                view.model = mod
                imageLoaded = true

            }

        }

    }

    function setData2(d) {

        var labels = []

        if(d["amount_found"]*1 < 5)
            labels.push("","")

        labels.push("filesize", "Filesize",
            "dimensions", "Dimensions",
            "","",
            "make", "Make",
            "model", "Model",
            "software", "Software",
            "","",
            "datetime", "Time Photo was Taken",
            "exposuretime", "Exposure Time",
            "flash", "Flash",
            "iso", "ISO",
            "scene", "Scene Type",
            "focal", "Focal Length",
            "fnumber", "F Number",
            "light", "Light Source",
            "","",
            "keywords", "Keywords",
            "location", "Location",
            "copyright", "Copyright",
            "","",
            "gps", "GPS Position",
            "","")

        if(d["amount_found"]*1 < 5)
            labels.push("","")

        // Set up model

        mod.clear()

        var oneEmpty = false;

        for(var i = 0; i < labels.length; i+=2) {
            if(labels[i] == "" && labels[i+1] == "") {
                if(!oneEmpty) {
                    oneEmpty = true
                    mod.append({"name" : "", "value" : ""})
                }
            } else if(d[labels[i]] != "" && d[labels[i+1]] != "") {
                oneEmpty = false;
                mod.append({"name" : labels[i+1], "value" : d[labels[i]]})
            }
        }

        view.model = mod
        imageLoaded = true


    }

}
