import QtQuick
import QtQuick.Controls

import PQCNotify
import PQCScriptsFilesPaths

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

// settings in this file:
// - thumbnailsCache
// - thumbnailsMaxNumberThreads
// - thumbnailsExcludeFolders
// - thumbnailsExcludeDropBox
// - thumbnailsExcludeNextcloud
// - thumbnailsExcludeOwnCloud

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    property bool settingChanged: false

    Column {

        id: contcol

        spacing: 10

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "PhotoQt shows all images in the currently loaded folder as thumbnails along one of the screen edges. If you want to disable thumbnails altogether, you can do so by removing it from all screen edges in the interface settings.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Cache")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "PhotoQt can cache thumbnails so that each subsequent time they can be generated near instantaneously. PhotoQt implements the standard for thumbnails defined by freedesktop.org. On Windows it can also load (but not write) existing thumbnails from the thumbnail cache built into Windows.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQCheckBox {
            id: cache_enable
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "enable cache")
            checked: PQCSettings.thumbnailsCache
            onCheckedChanged: checkDefault()
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Exclude folders")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "When an image is loaded PhotoQt preloads thumbnails for all images found in the current folder. Some cloud providers do not fully sync their files unless accessed. To avoid unnecessarily downloading large amount of files, it is possible to exclude specific directories from any sort of caching and preloading. Note that for files in these folders you will still see thumbnails consisting of filetype icons.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Column {

            x: (parent.width-width)/2
            spacing: 10

            PQText {
                id: cloudheader
                text: qsTranslate("settingsmanager", "Cloud providers to exclude from caching:")
                visible: nextcloud.visible||owncloud.visible||dropbox.visible
            }

            PQCheckBox {
                id: nextcloud
                property string folder: PQCSettings.thumbnailsExcludeNextcloud
                visible: folder!=""
                text: "Nextcloud: " + folder
                checked: PQCSettings.thumbnailsExcludeNextcloud!==""
                onCheckedChanged: checkDefault()
            }

            PQCheckBox {
                id: owncloud
                property string folder: PQCSettings.thumbnailsExcludeOwnCloud
                visible: folder!=""
                text: "ownCloud: " + folder
                checked: PQCSettings.thumbnailsExcludeOwnCloud!==""
                onCheckedChanged: checkDefault()
            }

            PQCheckBox {
                id: dropbox
                property string folder: PQCSettings.thumbnailsExcludeDropBox
                visible: folder!=""
                text: "DropBox: " + folder
                checked: PQCSettings.thumbnailsExcludeDropBox!==""
                onCheckedChanged: checkDefault()
            }

        }

        Item {
            width: 1
            height: 10
        }

        Column {

            x: (parent.width-width)/2
            spacing: 10

            PQText {
                text: qsTranslate("settingsmanager", "Do not cache these folders:")
            }

            PQTextArea {
                id: exclude_folders
                implicitWidth: 400
                implicitHeight: 100
                text: PQCSettings.thumbnailsExcludeFolders.join("\n")
                placeholderText: qsTranslate("settingsmanager", "One folder per line")
                onControlActiveFocusChanged: {
                    PQCNotify.ignoreKeysExceptEsc = controlActiveFocus
                }
                onTextChanged: checkDefault()
            }

            PQButton {

                x: (parent.width-width)/2

                //: Written on a button
                text: qsTranslate("settingsmanager", "Add folder")
                onClicked: {
                    var newdir = PQCScriptsFilesPaths.getExistingDirectory()
                    if(newdir !== "") {
                        if(exclude_folders.text === "")
                            exclude_folders.text = newdir+"\n"
                        else {
                            if(exclude_folders.text.endsWith("\n"))
                                exclude_folders.text += newdir+"\n"
                            else
                                exclude_folders.text += "\n"+newdir+"\n"
                        }
                        exclude_folders.cursorPosition = exclude_folders.text.length
                    }
                }
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "How many threads")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "In order to speed up loading all the thumbnails in a folder PhotoQt uses multiple threads simultaneously. On more powerful systems, a larger number of threads can result in much faster loading of all the thumbnails of a folder. Too many threads, however, might make a system feel slow for a short time.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {

            x: (parent.width-width)/2

            PQText {
                text: "1"
            }

            PQSlider {
                id: threads
                from: 1
                to: 8
                value: PQCSettings.thumbnailsMaxNumberThreads
                onValueChanged: checkDefault()
            }

            PQText {
                text: "8"
            }

        }

        PQText {
            x: (parent.width-width)/2
            //: Important: Please do not forget the placeholder!
            text: qsTranslate("settingsmanager", "current value: %1 thread(s)").arg(threads.value)
        }

    }

    Component.onCompleted:
        load()

    Component.onDestruction:
        PQCNotify.ignoreKeysExceptEsc = false

    function checkDefault() {

        settingChanged = (cache_enable.hasChanged() || nextcloud.hasChanged() || owncloud.hasChanged() || dropbox.hasChanged() ||
                          exclude_folders.text !== PQCSettings.thumbnailsExcludeFolders.join("\n") || threads.hasChanged())

    }

    function load() {

        cache_enable.loadAndSetDefault(PQCSettings.thumbnailsCache)

        if(PQCSettings.thumbnailsExcludeNextcloud !== "") {
            nextcloud.folder = PQCSettings.thumbnailsExcludeNextcloud
            nextcloud.loadAndSetDefault(true)
        } else {
            nextcloud.folder = PQCScriptsFilesPaths.findNextcloudFolder()
            nextcloud.loadAndSetDefault(false)
        }

        if(PQCSettings.thumbnailsExcludeOwnCloud !== "") {
            owncloud.folder = PQCSettings.thumbnailsExcludeOwnCloud
            owncloud.loadAndSetDefault(true)
        } else {
            owncloud.folder = PQCScriptsFilesPaths.findOwnCloudFolder()
            owncloud.loadAndSetDefault(false)
        }

        if(PQCSettings.thumbnailsExcludeDropBox !== "") {
            dropbox.folder = PQCSettings.thumbnailsExcludeDropBox
            dropbox.loadAndSetDefault(true)
        } else {
            dropbox.folder = PQCScriptsFilesPaths.findDropBoxFolder()
            dropbox.loadAndSetDefault(false)
        }

        exclude_folders.text = PQCSettings.thumbnailsExcludeFolders.join("\n")
        if(!exclude_folders.text.endsWith("\n") && exclude_folders.text.length > 0)
            exclude_folders.text += "\n"
        exclude_folders.cursorPosition = exclude_folders.text.length

        threads.loadAndSetDefault(PQCSettings.thumbnailsMaxNumberThreads)

        settingChanged = false

    }

    function applyChanges() {

        PQCSettings.thumbnailsCache = cache_enable.checked

        PQCSettings.thumbnailsExcludeNextcloud = (nextcloud.checked ? nextcloud.folder : "")
        PQCSettings.thumbnailsExcludeOwnCloud = (owncloud.checked ? owncloud.folder : "")
        PQCSettings.thumbnailsExcludeDropBox = (dropbox.checked ? dropbox.folder : "")

        // split by linebreak and remove empty entries
        var parts = exclude_folders.text.split("\n").filter(function(el) { return el.length !== 0});
        // trim each entry
        for(var p = 0; p < parts.length; ++p) {
            parts[p] = parts[p].trim()
            if(parts[p].endsWith("/"))
                parts[p] = parts[p].slice(0,parts[p].length-1)
        }
        PQCSettings.thumbnailsExcludeFolders = parts

        PQCSettings.thumbnailsMaxNumberThreads = threads.value

        cache_enable.saveDefault()
        nextcloud.saveDefault()
        owncloud.saveDefault()
        dropbox.saveDefault()
        threads.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
