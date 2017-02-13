import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: entrytitle

            title: qsTr("Animation and Window Geometry")
            helptext: qsTr("There are four things that can be adjusted here:") + "<ol><li>" + qsTr("Animation of fade-in elements (e.g., Settings or About)") + "</li><li>" + qsTr("Save and restore of Window Geometry: On quitting PhotoQt, it stores the size and position of the window and can restore it the next time started.") + "</li><li>" + qsTr("Keep PhotoQt above all other windows at all time") + "</li><li>" + qsTr("Force PhotoQt to always open on a specific screen") + "</li></ol>"

        }

        EntrySetting {

            Row {

                spacing: 10

                CustomCheckBox {

                    id: animate_elements
                    text: qsTr("Animate all fade-in elements")

                }

                CustomCheckBox {

                    id: save_restore_geometry
                    text: qsTr("Save and restore window geometry")
                    onCheckedButtonChanged:
                        if(checkedButton) screenCheck.checkedButton = false

                }

                CustomCheckBox {

                    id: keep_on_top
                    wrapMode: Text.WordWrap
                    text: qsTr("Keep above other windows")

                }

                Rectangle {
                    color: "transparent"
                    width: childrenRect.width
                    height: childrenRect.height
                    Row {
                        property string ttip: qsTr("Make PhotoQt appear on Screen #") + (screenCombo.currentIndex+1) + ": " + screenCombo.currentText
                        CustomCheckBox {
                            id: screenCheck
                            text: qsTr("Make PhotoQt appear on Screen #") + ": "
                            tooltip: parent.ttip
                            onCheckedButtonChanged:
                                if(checkedButton) save_restore_geometry.checkedButton = false
                        }
                        CustomComboBox {
                            id: screenCombo
                            model: []
                            enabled: screenCheck.checkedButton
                            disabledOpacity: 0.3
                            tooltip: parent.ttip
                        }
                    }
                }

            }

        }

    }

    function setData() {

        animate_elements.checkedButton = settings.myWidgetAnimated
        save_restore_geometry.checkedButton = settings.saveWindowGeometry
        keep_on_top.checkedButton = settings.keepOnTop

        var allScreens = getanddostuff.getScreenNames()
        var model = []
        for(var i = 0; i < allScreens.length; ++i)
            model[i] = "" + i + " (" + allScreens[i] + ")"
        screenCombo.model = model

        screenCheck.checkedButton = settings.openOnScreen
        for(var i = 0; i < allScreens.length; ++i)
            if(allScreens[i] == settings.openOnScreenName)
                screenCombo.currentIndex = i

    }

    function saveData() {
        settings.myWidgetAnimated = animate_elements.checkedButton
        settings.saveWindowGeometry = save_restore_geometry.checkedButton
        settings.keepOnTop = keep_on_top.checkedButton

        settings.openOnScreen = screenCheck.checkedButton
        settings.openOnScreenName = screenCombo.currentText.split("(")[1].split(")")[0]
    }

}
