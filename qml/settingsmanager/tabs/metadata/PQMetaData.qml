import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    title: "meta information"
    helptext: "Which meta information to extract and display."

    property var meta: [["metaCopyright", "copyright"],
                        ["metaDimensions", "dimensions"],
                        ["metaExposureTime", "exposure time"],
                        ["metaFilename", "file name"],
                        ["metaFileType", "file type"],
                        ["metaFileSize", "file size"],
                        ["metaFlash", "flash"],
                        ["metaFLength", "focal length"],
                        ["metaFNumber", "f-number"],
                        ["metaGps", "GPS position"],
                        ["metaImageNumber", "image #/#"],
                        ["metaIso", "ISO"],
                        ["metaKeywords", "keywords"],
                        ["metaLightSource", "light source"],
                        ["metaLocation", "location"],
                        ["metaMake", "make"],
                        ["metaModel", "model"],
                        ["metaSceneType", "scene type"],
                        ["metaSoftware", "software"],
                        ["metaTimePhotoTaken", "time photo was taken"]]

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
