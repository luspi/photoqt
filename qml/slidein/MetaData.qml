import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

    id: meta

    // Set up model on first load, afetrwards just change data
    property bool modelSetup: false

    // Background color
    color: "#CC000000"

    // Set position (we pretend that rounded corners are along the right edge only, that's why visible x is off screen)
    x: -width
    y: (parent.height-meta.height)/3

    // Adjust size
    width: ((view.width+2*radius < 350) ? 350 : view.width+2*radius)
    height: modelSetup ? view.contentHeight : width

    // Corner radius
    radius: 10

    // Label at first start-up
    Text {

        anchors.fill: parent

        color: "grey"

        visible: !modelSetup
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        font.bold: true
        font.pointSize: 18
        text: "No File Loaded"

    }

    // Label displaying which type of data was extracted
    Text {

        id: type

        color: "grey"
        font.bold: true
        font.italic: true
        font.pointSize: settings.exiffontsize+2

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: radius

        text: ""

    }

    ListView {

        id: view

        x: meta.radius+10
        y: radius

        width: childrenRect.width
        height: meta.height

        visible: modelSetup
        model: ListModel { id: mod; }
        delegate: deleg

    }

    Component {

        id: deleg

        Rectangle {

            id: rect

            color: "#00000000";
            height: val.height;

            Text {
                id: val;
                color: "white";
                font.pointSize: settings.exiffontsize+(name == "exiv2_type" ? 2 : 0)
                lineHeight: 1.3;
                text: name != "" ? "<b>" + name + "</b>: " + value : "";
            }

       }
    }

    function setData(d) {

        var labels = ["filename", "Filename",
            "filetype", "Filetype",
            "filesize", "Filesize",
            "dimensions", "Dimensions",
            "", "",
            "make", "Make",
            "model", "Model",
            "software", "Software",
            "datetime", "Time Photo was Taken",
            "", "",
            "exposuretime", "Exposure Time",
            "flash", "Flash",
            "iso", "ISO",
            "scene", "Scene Type",
            "focal", "Focal Length",
            "fnumber", "F Number",
            "light", "Light Source",
            "", "",
            "gps", "GPS Position",
            "", ""]

        type.text = d["exiv2_type"]

        // Set up model
        if(!modelSetup) {

            mod.clear()

            for(var i = 0; i < labels.length; i+=2)
                mod.append({"name" : labels[i+1], "value" : d[labels[i]]})

            view.model = mod
            modelSetup = true

        // Update model
        } else {

            for(var i = 0; i < labels.length; i+=2)
                mod.set(i/2,{"name" : labels[i+1], "value" : d[labels[i]]})

        }

    }

}
