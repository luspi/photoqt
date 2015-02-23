import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

    id: tab

    color: "#00000000"

    anchors {
        fill: parent
        leftMargin: 20
        rightMargin: 20
        topMargin: 15
        bottomMargin: 5
    }

    Flickable {

        id: flickable

        clip: true

        anchors.fill: parent

        contentHeight: contentItem.childrenRect.height+50
        contentWidth: tab.width

        boundsBehavior: Flickable.StopAtBounds

        Column {

            id: maincol

            spacing: 15

            /**********
             * HEADER *
             **********/

            Rectangle {
                id: header
                width: flickable.width
                height: childrenRect.height
                color: "#00000000"
                Text {
                    color: "white"
                    font.pointSize: 18
                    font.bold: true
                    text: "Basic Settings"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            /***************
             * SORT IMAGES *
             ***************/

            SettingsText {

                id: sortimages

                width: tab.width

                text: "<h2>Sort Images</hr><br>Here you can adjust, how the images in a folder are supposed to be sorted. You can sort them by Filename, Natural Name (e.g., file10.jpg comes after file9.jpg and not after file1.jpg), File Size, and Date. Also, you can reverse the sorting order from ascending to descending if wanted.<br><br><b>Hint: You can also change this setting very quickly from the 'Quick Settings'' window, hidden behind the right screen edge.</b>"

            }

            /* SORT IMAGES ELEMENTS */

            // packed in rectangle for centering
            Rectangle {

                id: sortimages_subrect

                color: "#00000000"

                // center rectangle
                width: childrenRect.width
                height: childrenRect.height
                x: (flickable.width-width)/2

                Row {

                    spacing: 10

                    // Label
                    Text {
                        color: "white"
                        text: "Sort by:"
                        y: (sortimages_subrect.height-height)/2
                    }
                    // Choose Criteria
                    CustomComboBox {
                        width: 150
                        model: ["Name", "Natural Name", "Date", "Filesize"]
                    }

                    // Ascending or Descending
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

            /***************
             * WINDOW MODE *
             ***************/

            SettingsText {

                id: windowmode

                width: tab.width

                text: "<h2>Window Mode</hr><br>PhotoQt is designed with the space of a fullscreen app in mind. That's why it by default runs as fullscreen. However, some might prefer to have it as a normal window, e.g. so that they can see the panel."

            }

            /* WINDOW MODE ELEMENTS */

            Rectangle {

                id: windowmode_subrect

                color: "#00000000"

                // center rectangle
                width: childrenRect.width
                height: childrenRect.height
                x: (flickable.width-width)/2

                Row {

                    spacing: 10

                    CustomCheckBox {
                        id: window
                        text: "Run PhotoQt in Window Mode"
                        onButtonCheckedChanged:     // 'Window Decoration' checkbox is only enabled when the 'Window ModeÄ checkbox is checked
                            deco.enabled = checkedButton
                    }

                    CustomCheckBox {
                        id: deco
                        enabled: false
                        text: "Show Window Decoration"
                    }

                }

            }

            /*************
             * TRAY ICON *
             *************/

            SettingsText {

                id: trayicon

                width: tab.width

                text: "<h2>Hide to Tray Icon</h2><br>When started PhotoQt creates a tray icon in the system tray. If desired, you can set PhotoQt to minimise to the tray instead of quitting. This causes PhotoQt to be almost instantaneously available when an image is opened.<br>It is also possible to start PhotoQt already minimised to the tray (e.g. at system startup) when called with \"--start-in-tray\"."

            }

            CustomCheckBox {
                x: (tab.width-width)/2
                text: "Hide to Tray Icon"
            }


            /***************
             * CLOSING 'X' *
             ***************/

            SettingsText {

                id: closingx

                width: tab.width

                text: "<h2>Closing 'X' (top right)</h2><br>There are two looks for the closing 'x' at the top right: a normal 'x', or a slightly more fancy 'x'. Here you can switch back and forth between both of them, and also change their size. If you prefer not to have a closing 'x' at all, see below for an option to hide it."

            }

            /* LOOK OF CLOSING 'X' */

            Rectangle {

                id: closingx_subrect1

                color: "#00000000"

                // center rectangle
                width: childrenRect.width
                height: childrenRect.height
                x: (flickable.width-width)/2

                Row {

                    spacing: 10

                    ExclusiveGroup { id: radiobuttons_closingx }

                    CustomRadioButton {
                        text: "Normal Look"
                        checked: true
                        exclusiveGroup: radiobuttons_closingx
                    }

                    CustomRadioButton {
                        text: "Fancy Look"
                        exclusiveGroup: radiobuttons_closingx
                    }

                }

            }

            /* SIZE OF CLOSING 'X' */

            Rectangle {

                id: closingx_subrect2

                color: "#00000000"

                // center rectangle
                width: childrenRect.width
                height: childrenRect.height
                x: (flickable.width-width)/2

                Row {

                    id: closingx_row
                    spacing: 5

                    Text {
                        color: "white"
                        font.pointSize: 10
                        text: "Small Size"
                    }

                    CustomSlider {
                        width: 300
                        minimumValue: 5
                        maximumValue: 25
                        tickmarksEnabled: true
                        stepSize: 1
                    }

                    Text {
                        color: "white"
                        font.pointSize: 10
                        text: "Large Size"
                    }

                }

            }


            /************************
             * FIT IMAGES IN WINDOW *
             ************************/

            SettingsText {

                id: fitinwindow

                width: tab.width

                text: "<h2>Fit Image in Window</h2><br>If the image dimensions are smaller than the screen dimensions, PhotoQt can zoom those images to make them fir into the window. However, keep in mind, that such images will look pixelated to a certain degree (depending on each image)."

            }

            CustomCheckBox {
                x: (tab.width-width)/2
                text: "Fit Images in Window"
            }



            /******************************
             * HIDE/SHOW QUICKINFO LABELS *
             ******************************/

            SettingsText {

                id: quickinfo

                width: tab.width

                text: "<h2>Hide Quickinfo (Text Labels)</h2><br>Here you can hide the text labels shown in the main area: The Counter in the top left corner, the file path/name following the counter, and the \"X\" displayed in the top right corner. The labels can also be hidden by simply right-clicking on them and selecting \"Hide\"."

            }

            // Checkboxes

            Rectangle {

                id: quickinfo_subrect2

                color: "#00000000"

                // center rectangle
                width: childrenRect.width
                height: childrenRect.height
                x: (flickable.width-width)/2

                Column {

                    id: quick_col
                    spacing: 5

                    CustomCheckBox {
                        text: "Hide Counter"
                    }

                    CustomCheckBox {
                        text: "Hide Filepath (Shows only file name)"
                    }

                    CustomCheckBox {
                        text: "Hide Filename (Including file path)"
                    }

                    CustomCheckBox {
                        text: "Hide \"X\" (Closing)"
                    }

                }

            }



        }

    }

}
