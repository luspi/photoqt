import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    title: "Meta information"
    helptext: "Which meta information to extract and display."

    property var meta: [["metaCopyright", "Copyright"],
                        ["metaDimensions", "Dimensions"],
                        ["metaExposureTime", "Exposure time"],
                        ["metaFilename", "File name"],
                        ["metaFileType", "File type"],
                        ["metaFileSize", "File size"],
                        ["metaFlash", "Flash"],
                        ["metaFLength", "Focal length"],
                        ["metaFNumber", "F-Number"],
                        ["metaGps", "GPS position"],
                        ["metaImageNumber", "Image #/#"],
                        ["metaIso", "ISO"],
                        ["metaKeywords", "Keywords"],
                        ["metaLightSource", "Light source"],
                        ["metaLocation", "Location"],
                        ["metaMake", "Make"],
                        ["metaModel", "Model"],
                        ["metaSceneType", "Scene type"],
                        ["metaSoftware", "Software"],
                        ["metaTimePhotoTaken", "Time photo was taken"]]

    content: [

        Flow {

            spacing: 5
            width: set.contwidth

            Repeater {
                id: rpt
                model: meta.length
                PQTile {
                    text: meta[index][1]
                }
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            for(var i = 0; i < meta.length; ++i)
                rpt.itemAt(i).checked = PQSettings[meta[i][0]]
        }

        onSaveAllSettings: {
            for(var i = 0; i < meta.length; ++i)
                PQSettings[meta[i][0]] = rpt.itemAt(i).checked
        }

    }

}
