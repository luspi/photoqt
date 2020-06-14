import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Animation"
    helptext: "What type of animation to show, and how fast."
    content: [

        Row {

            spacing: 5

            Text {
                y: (parent.height-height)/2
                text: "no animation"
                color: "white"
            }

            PQSlider {
                id: anim_dur
                y: (parent.height-height)/2
                from: 1
                to: 10
            }

            Text {
                y: (parent.height-height)/2
                text: "long animation"
                color: "white"
            }

            Item {
                width: 10
                height: 2
            }

            PQComboBox {
                id: anim_type
                tooltip: "Type of animation"
                y: (parent.height-height)/2
                model: ["opacity", "x-axis", "y-axis"]
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            anim_dur.value = PQSettings.animationDuration
            if(PQSettings.animationType == "x")
                anim_type.currentIndex = 1
            else if(PQSettings.animationType == "y")
                anim_type.currentIndex = 2
            else
                anim_type.currentIndex = 0
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

}
