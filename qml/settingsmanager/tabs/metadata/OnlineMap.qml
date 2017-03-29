import QtQuick 2.4
import QtQuick.Controls 1.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Online Map for GPS")
            helptext: qsTr("If your image includes a GPS location, then a click on the location text will load this location in an online map using your default external browser. Here you can choose which online service to use (suggestions for other online maps always welcome).")

        }

        EntrySetting {

            id: entry

            ExclusiveGroup { id: mapgroup; }

            Row {

                spacing: 10

                CustomRadioButton {
                    id: openstreetmap
                    text: "openstreetmap.org"
                    exclusiveGroup: mapgroup
                    checked: true
                }
                CustomRadioButton {
                    id: googlemaps
                    text: "maps.google.com"
                    exclusiveGroup: mapgroup
                }
                CustomRadioButton {
                    id: bingmaps
                    text: "bing.com/maps"
                    exclusiveGroup: mapgroup
                }

            }

        }

    }

    function setData() {
        openstreetmap.checked = (settings.exifgpsmapservice === "openstreetmap.org")
        googlemaps.checked = (settings.exifgpsmapservice === "maps.google.com")
        bingmaps.checked = (settings.exifgpsmapservice === "bing.com/maps")
    }

    function saveData() {
        settings.exifgpsmapservice = openstreetmap.checked ? "openstreetmap.org" : (googlemaps.checked ? "maps.google.com" : "bing.com/maps")
    }

}
