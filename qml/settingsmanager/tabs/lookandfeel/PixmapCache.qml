import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: entrytitle

            title: qsTr("Pixmap Cache")
            helptext: qsTr("Here you can adjust the size of the pixmap cache. This cache holds the loaded image elements that have been displayed. This doesn't help when first displaying an image, but can speed up its second display significantly. On the other hand, it does increase the memory in use, up to the limit set here. If you disable the cache altogether (value of 0), then each time an image is displayed, it is loaded fresh from the harddrive.") + "<br><br><b>" + qsTr("Note: Any change will only take effect after you restart PhotoQt!") + "</b>"

        }

        EntrySetting {

            id: entry

            // This variable is needed to avoid a binding loop of slider<->spinbox
            property int val: 20

            Row {

                spacing: 10

                CustomSlider {

                    id: pixmapcache_sizeslider

                    width: Math.min(400, settings_top.width-entrytitle.width-pixmapcache_sizespinbox.width-60)
                    y: (parent.height-height)/2

                    minimumValue: 0
                    maximumValue: 1000

                    stepSize: 1
                    scrollStep: 5

                    onValueChanged:
                        entry.val = value

                }

                CustomSpinBox {

                    id: pixmapcache_sizespinbox

                    width: 85

                    minimumValue: 0
                    maximumValue: 1000

                    suffix: " MB"

                    value: entry.val

                    onValueChanged: {
                        if(value%5 == 0)
                            pixmapcache_sizeslider.value = value
                    }

                }

            }

        }

    }

    function setData() {
        pixmapcache_sizeslider.value = settings.pixmapCache
    }

    function saveData() {
        settings.pixmapCache = pixmapcache_sizeslider.value
    }

}
