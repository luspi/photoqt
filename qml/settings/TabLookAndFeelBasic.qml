import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

    id: tab

    color: "#00000000"

    anchors.fill: parent
    anchors.margins: 20

    Flickable {

        id: flickable

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 25
        }

        contentHeight: childrenRect.height
        contentWidth: childrenRect.width

        Column {

            spacing: 10

            Rectangle {
                id: header
                width: flickable.width
                color: "#00000000"
                Text {
                    color: "white"
                    font.pointSize: 18
                    font.bold: true
                    text: "Basic Settings"
                    anchors.centerIn: parent
                }
            }

            SettingsText {

                id: sortimages

                sibling: header

                text: "<h2>Sort Images</hr><br>Here you can adjust, how the images in a folder are supposed to be sorted. You can sort them by Filename, Natural Name (e.g., file10.jpg comes after file9.jpg and not after file1.jpg), File Size, and Date. Also, you can reverse the sorting order from ascending to descending if wanted.<br><br><b>Hint: You can also change this setting very quickly from the 'Quick Settings'' window, hidden behind the right screen edge.</b>"

            }

            Rectangle {

                id: sortimages_subrect

                color: "#00000000"

                width: childrenRect.width
                height: childrenRect.height
                x: (flickable.width-width)/2

                Row {

                    spacing: 10

                    Text {
                        color: "white"
                        text: "Sort by:"
                        y: (sortimages_subrect.height-height)/2
                    }
                    CustomComboBox {
                        width: 150
                        model: ["Name", "Natural Name", "Date", "Filesize"]
                    }

                    ExclusiveGroup { id: radiobuttons_sorting }
                    CustomRadioButton {
                        text: "Ascending"
                        icon: "qrc:/img/settings/sortascending.png"
                        y: (sortimages_subrect.height-height)/2
                        exclusiveGroup: radiobuttons_sorting
                        checked: true
                    }
                    CustomRadioButton {
                        text: "Descending"
                        y: (sortimages_subrect.height-height)/2
                        icon: "qrc:/img/settings/sortdescending.png"
                        exclusiveGroup: radiobuttons_sorting
                    }
                }

            }

        }

    }

}
