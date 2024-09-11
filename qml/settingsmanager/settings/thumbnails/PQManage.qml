/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick
import QtQuick.Controls

import PQCNotify
import PQCScriptsFilesPaths
import PQCScriptsOther

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
    property bool settingsLoaded: false

    Column {

        id: contcol

        spacing: 10

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "To disable thumbnail altogether remove it from all screen edges in the Interface category.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_cache

            //: Settings title
            title: qsTranslate("settingsmanager", "Cache")

            helptext: qsTranslate("settingsmanager", "PhotoQt can cache thumbnails so that each subsequent time they can be generated near instantaneously. PhotoQt implements the standard for thumbnails defined by freedesktop.org. On Windows it can also load (but not write) existing thumbnails from the thumbnail cache built into Windows.")

            content: [
                PQCheckBox {
                    id: cache_enable
                    enforceMaxWidth: set_cache.rightcol
                    text: qsTranslate("settingsmanager", "enable cache")
                    onCheckedChanged: checkDefault()
                },

                Column {

                    spacing: 0

                    height: cache_enable.checked ? (cache_dir_default.height+cache_dir_custom_container.height) : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    clip: true

                    PQCheckBox {
                        id: cache_dir_default
                        enforceMaxWidth: set_cache.rightcol
                        text: qsTranslate("settingsmanager", "use default cache directory")
                        onCheckedChanged: checkDefault()
                    }

                    Item {
                        id: cache_dir_custom_container
                        width: cache_dir_custom.width
                        height: (cache_dir_default.checked || !cache_enable.checked) ? 0 : (cache_dir_custom.height+10)
                        Behavior on height { NumberAnimation { duration: 200 } }
                        clip: true
                        PQButton {
                            id: cache_dir_custom
                            y: 10
                            smallerVersion: true
                            property string customdir: ""
                            text: customdir == "" ? "..." : customdir
                            tooltip: qsTranslate("settingsmanager", "Click to select custom base directory for thumbnail cache")

                            onClicked: {
                                var path = PQCScriptsFilesPaths.selectFolderFromDialog("Select", (customdir == "" ? PQCScriptsFilesPaths.getHomeDir() : customdir))
                                if(path !== "") {
                                    cache_dir_custom.customdir = path
                                    checkDefault()
                                }
                            }

                        }
                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_excl

            //: Settings title
            title: qsTranslate("settingsmanager", "Exclude folders")

            helptext: qsTranslate("settingsmanager", "When an image is loaded PhotoQt preloads thumbnails for all images found in the current folder. Some cloud providers do not fully sync their files unless accessed. To avoid unnecessarily downloading large amount of files, it is possible to exclude specific directories from any sort of caching and preloading. Note that for files in these folders you will still see thumbnails consisting of filetype icons.")

            content: [

                PQText {
                    id: cloudheader
                    width: set_excl.rightcol
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTranslate("settingsmanager", "Cloud providers to exclude from caching:")
                    visible: nextcloud.visible||owncloud.visible||dropbox.visible
                },

                PQCheckBox {
                    id: nextcloud
                    enforceMaxWidth: set_excl.rightcol
                    property string folder: PQCSettings.thumbnailsExcludeNextcloud
                    visible: folder!=""
                    text: "Nextcloud: " + folder
                    onCheckedChanged: checkDefault()
                },

                PQCheckBox {
                    id: owncloud
                    enforceMaxWidth: set_excl.rightcol
                    property string folder: PQCSettings.thumbnailsExcludeOwnCloud
                    visible: folder!=""
                    text: "ownCloud: " + folder
                    onCheckedChanged: checkDefault()
                },

                PQCheckBox {
                    id: dropbox
                    enforceMaxWidth: set_excl.rightcol
                    property string folder: PQCSettings.thumbnailsExcludeDropBox
                    visible: folder!=""
                    text: "DropBox: " + folder
                    onCheckedChanged: checkDefault()
                },

                Item {
                    width: 1
                    height: 10
                },

                PQText {
                    text: qsTranslate("settingsmanager", "Do not cache these folders:")
                },

                PQTextArea {
                    id: exclude_folders
                    implicitWidth: Math.min(400, set_excl.rightcol)
                    implicitHeight: 100
                    placeholderText: qsTranslate("settingsmanager", "One folder per line")
                    onControlActiveFocusChanged: {
                        PQCNotify.ignoreKeysExceptEsc = controlActiveFocus
                    }
                    onTextChanged: checkDefault()
                },

                PQButton {

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

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_thrd

            //: Settings title
            title: qsTranslate("settingsmanager", "How many threads")

            helptext: qsTranslate("settingsmanager", "In order to speed up loading all the thumbnails in a folder PhotoQt uses multiple threads simultaneously. On more powerful systems, a larger number of threads can result in much faster loading of all the thumbnails of a folder. Too many threads, however, might make a system feel slow for a short time.")

            content: [

                PQSliderSpinBox {
                    id: threads
                    width: set_thrd.rightcol
                    minval: 1
                    maxval: 32
                    title: ""
                    suffix: " threads"
                    onValueChanged:
                        checkDefault()
                }

            ]

        }

    }

    Component.onCompleted:
        load()

    Component.onDestruction:
        PQCNotify.ignoreKeysExceptEsc = false

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        settingChanged = (cache_enable.hasChanged() || nextcloud.hasChanged() || owncloud.hasChanged() || dropbox.hasChanged() ||
                          exclude_folders.text !== PQCSettings.thumbnailsExcludeFolders.join("\n") || threads.hasChanged() ||
                          cache_dir_default.hasChanged() || cache_dir_custom.customdir !== PQCSettings.thumbnailsCacheBaseDirLocation)

    }

    function load() {

        cache_enable.loadAndSetDefault(PQCSettings.thumbnailsCache)
        cache_dir_default.loadAndSetDefault(PQCSettings.thumbnailsCacheBaseDirDefault)
        cache_dir_custom.customdir = PQCSettings.thumbnailsCacheBaseDirLocation

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
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.thumbnailsCache = cache_enable.checked
        PQCSettings.thumbnailsCacheBaseDirDefault = cache_dir_default.checked
        PQCSettings.thumbnailsCacheBaseDirLocation = cache_dir_custom.customdir

        PQCScriptsFilesPaths.setThumbnailBaseCacheDir(cache_dir_default.checked ? "" : cache_dir_custom.customdir)

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
        // without this conversion crashes are possible
        PQCSettings.thumbnailsExcludeFolders = PQCScriptsOther.convertJSArrayToStringList(parts)

        PQCSettings.thumbnailsMaxNumberThreads = threads.value

        cache_enable.saveDefault()
        cache_dir_default.saveDefault()
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
