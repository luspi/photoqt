import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: title
            title: qsTr("Meta Information")
            helptext: qsTr("PhotoQt can display a number of meta information about the image. Here you can choose which ones to show and which ones to hide.")

        }

        EntrySetting {

            id: entry

            GridView {

                property var metadataitems: [["","",false]]
                property var metadachecked: { "" : "" }

                id: grid
                width: Math.floor((item_top.width-title.width-title.x-parent.parent.spacing-5)/(cellWidth)) * (cellWidth)
                height: childrenRect.height
                cellWidth: 200
                cellHeight: 30 + 2*spacing
                property int spacing: 3

                model: metadataitems.length
                delegate: MetaDataTile {
                    id: tile
                    text: grid.metadataitems[index][1]
                    checked: grid.metadataitems[index][2]
                    width: grid.cellWidth-grid.spacing*2
                    x: grid.spacing
                    height: grid.cellHeight-grid.spacing*2
                    y: grid.spacing
                    onCheckedChanged:
                        grid.metadachecked[grid.metadataitems[index][0]] = checked
                    Component.onCompleted:
                        grid.metadachecked[grid.metadataitems[index][0]] = checked
                }


            }

        }

    }

    function setData() {

        var items;

        if(getanddostuff.isExivSupportEnabled())

            //: Keep string short!
            items = [["filename",qsTranslate("metadata", "Filename"), settings.metaFilename],
                        //: Keep string short!
                        ["filesize",qsTranslate("metadata", "Filesize"), settings.metaFileSize],
                        //: Used as in "Image 3/16". The numbers (position of image in folder) are added on automatically. Keep string short!
                        ["imagenumber",qsTranslate("metadata", "Image") + " #/#", settings.metaImageNumber],
                        //: The dimensions of the loaded image. Keep string short!
                        ["dimensions",qsTranslate("metadata", "Dimensions"), settings.metaDimensions],
                        //: Exif image metadata: the make of the camera used to take the photo. Keep string short!
                        ["make",qsTranslate("metadata", "Make"), settings.metaMake],
                        //: Exif image metadata: the model of the camera used to take the photo. Keep string short!
                        ["model",qsTranslate("metadata", "Model"),settings.metaModel],
                        //: Exif image metadata: the software used to create the photo. Keep string short!
                        ["software",qsTranslate("metadata", "Software"),settings.metaSoftware],
                        //: Exif image metadata: when the photo was taken. Keep string short!
                        ["time",qsTranslate("metadata", "Time Photo was Taken"),settings.metaTimePhotoTaken],
                        //: Exif image metadata: how long the sensor was exposed to the light. Keep string short!
                        ["exposure",qsTranslate("metadata", "Exposure Time"),settings.metaExposureTime],
                        //: Exif image metadata: the flash setting when the photo was taken. Keep string short!
                        ["flash",qsTranslate("metadata", "Flash"),settings.metaFlash],
                        ["iso","ISO",settings.metaIso],
                        //: Exif image metadata: the specific scene type the camera used for the photo. Keep string short!
                        ["scenetype",qsTranslate("metadata", "Scene Type"),settings.metaSceneType],
                        //: Exif image metadata: https://en.wikipedia.org/wiki/Focal_length . Keep string short!
                        ["focal",qsTranslate("metadata", "Focal Length"),settings.metaFLength],
                        //: Exif image metadata: https://en.wikipedia.org/wiki/F-number . Keep string short!
                        ["fnumber",qsTranslate("metadata", "F-Number"),settings.metaFNumber],
                        //: Exif image metadata: What type of light the camera detected. Keep string short!
                        ["light",qsTranslate("metadata", "Light Source"),settings.metaLightSource],
                        //: IPTC image metadata: A description of the image by the user/software. Keep string short!
                        ["keywords",qsTranslate("metadata", "Keywords"),settings.metaKeywords],
                        //: IPTC image metadata: The CITY the imge was taken in. Keep string short!
                        ["location",qsTranslate("metadata", "Location"),settings.metaLocation],
                        //: IPTC image metadata. Keep string short!
                        ["copyright",qsTranslate("metadata", "Copyright"),settings.metaCopyright],
                        //: Exif image metadata. Keep string short!
                        ["gps",qsTranslate("metadata", "GPS Position"),settings.metaGps]]

        else
            //: Keep string short!
            items = [["filename",qsTranslate("metadata", "Filename"), settings.metaFilename],
                        //: Keep string short!
                        ["filesize",qsTranslate("metadata", "Filesize"), settings.metaFileSize],
                        //: Used as in "Image 3/16". The numbers (position of image in folder) are added on automatically. Keep string short!
                        ["imagenumber",qsTranslate("metadata", "Image") + " #/#", settings.metaImageNumber],
                        //: The dimensions of the loaded image. Keep string short!
                        ["dimensions",qsTranslate("metadata", "Dimensions"), settings.metaDimensions]]

        grid.metadataitems = items

    }

    function saveData() {

        settings.metaFilename = grid.metadachecked["filename"]
        settings.metaImageNumber = grid.metadachecked["imagenumber"]
        settings.metaFileSize = grid.metadachecked["filesize"]
        settings.metaDimensions = grid.metadachecked["dimensions"]
        if(getanddostuff.isExivSupportEnabled()) {
            settings.metaMake = grid.metadachecked["make"]
            settings.metaModel = grid.metadachecked["model"]
            settings.metaSoftware = grid.metadachecked["software"]
            settings.metaTimePhotoTaken = grid.metadachecked["time"]
            settings.metaExposureTime = grid.metadachecked["exposure"]
            settings.metaFlash = grid.metadachecked["flash"]
            settings.metaIso = grid.metadachecked["iso"]
            settings.metaSceneType = grid.metadachecked["scenetype"]
            settings.metaFLength = grid.metadachecked["focal"]
            settings.metaFNumber = grid.metadachecked["fnumber"]
            settings.metaLightSource = grid.metadachecked["light"]
            settings.metaKeywords = grid.metadachecked["keywords"]
            settings.metaLocation = grid.metadachecked["location"]
            settings.metaCopyright = grid.metadachecked["copyright"]
            settings.metaGps = grid.metadachecked["gps"]
        } else {
            // If PhotoQt was compiled WITHOUT Exiv2 support, we set the setting values to true,
            // so that if a version is installed/compiled WITH support, they are enabled by default
            settings.metaMake = true
            settings.metaModel = true
            settings.metaSoftware = true
            settings.metaTimePhotoTaken = true
            settings.metaExposureTime = true
            settings.metaFlash = true
            settings.metaIso = true
            settings.metaSceneType = true
            settings.metaFLength = true
            settings.metaFNumber = true
            settings.metaLightSource = true
            settings.metaKeywords = true
            settings.metaLocation = true
            settings.metaCopyright = true
            settings.metaGps = true
        }

    }

}
