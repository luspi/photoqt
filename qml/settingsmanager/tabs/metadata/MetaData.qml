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
            items = [["filename",qsTranslate("metadata", "Filename"), settings.exiffilename],
                        //: Keep string short!
                        ["filesize",qsTranslate("metadata", "Filesize"), settings.exiffilesize],
                        //: Used as in "Image 3/16". The numbers (position of image in folder) are added on automatically. Keep string short!
                        ["imagenumber",qsTranslate("metadata", "Image") + " #/#", settings.exifimagenumber],
                        //: The dimensions of the loaded image. Keep string short!
                        ["dimensions",qsTranslate("metadata", "Dimensions"), settings.exifdimensions],
                        //: Exif image metadata: the make of the camera used to take the photo. Keep string short!
                        ["make",qsTranslate("metadata", "Make"), settings.exifmake],
                        //: Exif image metadata: the model of the camera used to take the photo. Keep string short!
                        ["model",qsTranslate("metadata", "Model"),settings.exifmodel],
                        //: Exif image metadata: the software used to create the photo. Keep string short!
                        ["software",qsTranslate("metadata", "Software"),settings.exifsoftware],
                        //: Exif image metadata: when the photo was taken. Keep string short!
                        ["time",qsTranslate("metadata", "Time Photo was Taken"),settings.exifphototaken],
                        //: Exif image metadata: how long the sensor was exposed to the light. Keep string short!
                        ["exposure",qsTranslate("metadata", "Exposure Time"),settings.exifexposuretime],
                        //: Exif image metadata: the flash setting when the photo was taken. Keep string short!
                        ["flash",qsTranslate("metadata", "Flash"),settings.exifflash],
                        ["iso","ISO",settings.exifiso],
                        //: Exif image metadata: the specific scene type the camera used for the photo. Keep string short!
                        ["scenetype",qsTranslate("metadata", "Scene Type"),settings.exifscenetype],
                        //: Exif image metadata: https://en.wikipedia.org/wiki/Focal_length . Keep string short!
                        ["focal",qsTranslate("metadata", "Focal Length"),settings.exifflength],
                        //: Exif image metadata: https://en.wikipedia.org/wiki/F-number . Keep string short!
                        ["fnumber",qsTranslate("metadata", "F-Number"),settings.exiffnumber],
                        //: Exif image metadata: What type of light the camera detected. Keep string short!
                        ["light",qsTranslate("metadata", "Light Source"),settings.exiflightsource],
                        //: IPTC image metadata: A description of the image by the user/software. Keep string short!
                        ["keywords",qsTranslate("metadata", "Keywords"),settings.iptckeywords],
                        //: IPTC image metadata: The CITY the imge was taken in. Keep string short!
                        ["location",qsTranslate("metadata", "Location"),settings.iptclocation],
                        //: IPTC image metadata. Keep string short!
                        ["copyright",qsTranslate("metadata", "Copyright"),settings.iptccopyright],
                        //: Exif image metadata. Keep string short!
                        ["gps",qsTranslate("metadata", "GPS Position"),settings.exifgps]]

        else
            //: Keep string short!
            items = [["filename",qsTranslate("metadata", "Filename"), settings.exiffilename],
                        //: Keep string short!
                        ["filesize",qsTranslate("metadata", "Filesize"), settings.exiffilesize],
                        //: Used as in "Image 3/16". The numbers (position of image in folder) are added on automatically. Keep string short!
                        ["imagenumber",qsTranslate("metadata", "Image") + " #/#", settings.exifimagenumber],
                        //: The dimensions of the loaded image. Keep string short!
                        ["dimensions",qsTranslate("metadata", "Dimensions"), settings.exifdimensions]]

        grid.metadataitems = items

    }

    function saveData() {

        settings.exiffilename = grid.metadachecked["filename"]
        settings.exifimagenumber = grid.metadachecked["imagenumber"]
        settings.exiffilesize = grid.metadachecked["filesize"]
        settings.exifdimensions = grid.metadachecked["dimensions"]
        if(getanddostuff.isExivSupportEnabled()) {
            settings.exifmake = grid.metadachecked["make"]
            settings.exifmodel = grid.metadachecked["model"]
            settings.exifsoftware = grid.metadachecked["software"]
            settings.exifphototaken = grid.metadachecked["time"]
            settings.exifexposuretime = grid.metadachecked["exposure"]
            settings.exifflash = grid.metadachecked["flash"]
            settings.exifiso = grid.metadachecked["iso"]
            settings.exifscenetype = grid.metadachecked["scenetype"]
            settings.exifflength = grid.metadachecked["focal"]
            settings.exiffnumber = grid.metadachecked["fnumber"]
            settings.exiflightsource = grid.metadachecked["light"]
            settings.iptckeywords = grid.metadachecked["keywords"]
            settings.iptclocation = grid.metadachecked["location"]
            settings.iptccopyright = grid.metadachecked["copyright"]
            settings.exifgps = grid.metadachecked["gps"]
        } else {
            // If PhotoQt was compiled WITHOUT Exiv2 support, we set the setting values to true,
            // so that if a version is installed/compiled WITH support, they are enabled by default
            settings.exifmake = true
            settings.exifmodel = true
            settings.exifsoftware = true
            settings.exifphototaken = true
            settings.exifexposuretime = true
            settings.exifflash = true
            settings.exifiso = true
            settings.exifscenetype = true
            settings.exifflength = true
            settings.exiffnumber = true
            settings.exiflightsource = true
            settings.iptckeywords = true
            settings.iptclocation = true
            settings.iptccopyright = true
            settings.exifgps = true
        }

    }

}
