import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager", "meta information")
    helptext: em.pty+qsTranslate("settingsmanager", "Which meta information to extract and display.")

    //: Part of the meta information about the current image.
    property var meta: [["metaFilename", em.pty+qsTranslate("settingsmanager", "file name")],
                        //: Part of the meta information about the current image.
                        ["metaFileType", em.pty+qsTranslate("settingsmanager", "file type")],
                        //: Part of the meta information about the current image.
                        ["metaFileSize", em.pty+qsTranslate("settingsmanager", "file size")],
                        //: Part of the meta information about the current image.
                        ["metaImageNumber", em.pty+qsTranslate("settingsmanager", "image #/#")],
                        //: Part of the meta information about the current image.
                        ["metaDimensions", em.pty+qsTranslate("settingsmanager", "dimensions")],
                        //: Part of the meta information about the current image.
                        ["metaCopyright", em.pty+qsTranslate("settingsmanager", "copyright")],
                        //: Part of the meta information about the current image.
                        ["metaExposureTime", em.pty+qsTranslate("settingsmanager", "exposure time")],
                        //: Part of the meta information about the current image.
                        ["metaFlash", em.pty+qsTranslate("settingsmanager", "flash")],
                        //: Part of the meta information about the current image.
                        ["metaFLength", em.pty+qsTranslate("settingsmanager", "focal length")],
                        //: Part of the meta information about the current image.
                        ["metaFNumber", em.pty+qsTranslate("settingsmanager", "f-number")],
                        //: Part of the meta information about the current image.
                        ["metaGps", em.pty+qsTranslate("settingsmanager", "GPS position")],
                        ["metaIso", "ISO"],
                        //: Part of the meta information about the current image.
                        ["metaKeywords", em.pty+qsTranslate("settingsmanager", "keywords")],
                        //: Part of the meta information about the current image.
                        ["metaLightSource", em.pty+qsTranslate("settingsmanager", "light source")],
                        //: Part of the meta information about the current image.
                        ["metaLocation", em.pty+qsTranslate("settingsmanager", "location")],
                        //: Part of the meta information about the current image.
                        ["metaMake", em.pty+qsTranslate("settingsmanager", "make")],
                        //: Part of the meta information about the current image.
                        ["metaModel", em.pty+qsTranslate("settingsmanager", "model")],
                        //: Part of the meta information about the current image.
                        ["metaSceneType", em.pty+qsTranslate("settingsmanager", "scene type")],
                        //: Part of the meta information about the current image.
                        ["metaSoftware", em.pty+qsTranslate("settingsmanager", "software")],
                        //: Part of the meta information about the current image.
                        ["metaTimePhotoTaken", em.pty+qsTranslate("settingsmanager", "time photo was taken")]]

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
            load()
        }

        onSaveAllSettings: {
            for(var i = 0; i < meta.length; ++i)
                PQSettings[meta[i][0]] = rpt.itemAt(i).checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        for(var i = 0; i < meta.length; ++i)
            rpt.itemAt(i).checked = PQSettings[meta[i][0]]
    }

}
