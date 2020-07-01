import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    title: "animation"
    helptext: "What type of animation to show, and how fast."
    content: [

        Flow {

            spacing: 5
            width: set.contwidth

            PQComboBox {
                id: anim_type
                tooltip: "type of animation"
                y: (parent.height-height)/2
                model: ["opacity", "along x-axis", "along y-axis"]
            }

            Item {
                width: 10
                height: 2
            }

            Row {

                spacing: 5

                Text {
                    height: anim_type.height
                    verticalAlignment: Text.AlignVCenter
                    text: "no animation"
                    color: "white"
                }

                PQSlider {
                    id: anim_dur
                    height: anim_type.height
                    from: 1
                    to: 10
                }

                Text {
                    height: anim_type.height
                    verticalAlignment: Text.AlignVCenter
                    text: "long animation"
                    color: "white"
                }

            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.animationDuration = anim_dur.value
            if(anim_type.currentIndex == 1)
                PQSettings.animationType = "x"
            else if(anim_type.currentIndex == 2)
                PQSettings.animationType = "y"
            else
                PQSettings.animationType = "opacity"
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        anim_dur.value = PQSettings.animationDuration
        if(PQSettings.animationType == "x")
            anim_type.currentIndex = 1
        else if(PQSettings.animationType == "y")
            anim_type.currentIndex = 2
        else
            anim_type.currentIndex = 0
    }

}
