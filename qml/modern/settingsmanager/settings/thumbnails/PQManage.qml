/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
import PQCScriptsFilesPaths
import PQCScriptsConfig
import PhotoQt

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

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

    PQScrollManager { flickable: setting_top }

    property bool settingChanged: false
    property bool settingsLoaded: false

    property bool catchEscape: cache_dir_custom.contextmenu.visible || butaddfolder.contextmenu.visible || threads.editMode

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
                    onCheckedChanged: setting_top.checkDefault()
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
                        onCheckedChanged: setting_top.checkDefault()
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
                                var path = PQCScriptsFilesPaths.selectFolderFromDialog("Select", (customdir == "" ? PQCScriptsFilesPaths.getHomeDir() : customdir)) // qmllint disable unqualified
                                if(path !== "") {
                                    cache_dir_custom.customdir = path
                                    setting_top.checkDefault()
                                }
                            }

                        }
                    }

                }

            ]

            onResetToDefaults: {
                cache_enable.checked = PQCSettings.getDefaultForThumbnailsCache
                cache_dir_default.checked = PQCSettings.getDefaultForThumbnailsCacheBaseDirDefault()
                cache_dir_custom.customdir = PQCSettings.getDefaultForThumbnailsCacheBaseDirLocation()
            }

            function handleEscape() {
                cache_dir_custom.contextmenu.close()
            }

            function hasChanged() {
                return (cache_enable.hasChanged() || cache_dir_default.hasChanged() || cache_dir_custom.customdir !== PQCSettings.thumbnailsCacheBaseDirLocation)
            }

            function load() {
                cache_enable.loadAndSetDefault(PQCSettings.thumbnailsCache) // qmllint disable unqualified
                cache_dir_default.loadAndSetDefault(PQCSettings.thumbnailsCacheBaseDirDefault)
                cache_dir_custom.customdir = PQCSettings.thumbnailsCacheBaseDirLocation
            }

            function applyChanges() {
                PQCSettings.thumbnailsCache = cache_enable.checked // qmllint disable unqualified
                PQCSettings.thumbnailsCacheBaseDirDefault = cache_dir_default.checked
                PQCSettings.thumbnailsCacheBaseDirLocation = cache_dir_custom.customdir
                PQCScriptsFilesPaths.setThumbnailBaseCacheDir(cache_dir_default.checked ? "" : cache_dir_custom.customdir)
                cache_enable.saveDefault()
                cache_dir_default.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_excl

            //: Settings title
            title: qsTranslate("settingsmanager", "Exclude folders")

            helptext: qsTranslate("settingsmanager", "When an image is loaded PhotoQt preloads thumbnails for all images found in the current folder. Certain types of network folders and some cloud providers do not fully sync their files unless accessed. To avoid unnecessarily downloading large amount of files, it is possible to exclude specific directories from any sort of caching and preloading. Note that for files in these folders you will still see thumbnails consisting of filetype icons.")

            content: [

                PQCheckBox {
                    id: excludenetwork
                    text: qsTranslate("settingsmanager", "Exclude network shares (if any) from caching")
                },

                Item {
                    width: 1
                    height: 1
                    visible: nextcloud.visible||owncloud.visible||dropbox.visible
                },

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
                    property string folder: PQCSettings.thumbnailsExcludeNextcloud // qmllint disable unqualified
                    visible: folder!=""
                    text: "Nextcloud: " + folder
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: owncloud
                    enforceMaxWidth: set_excl.rightcol
                    property string folder: PQCSettings.thumbnailsExcludeOwnCloud // qmllint disable unqualified
                    visible: folder!=""
                    text: "ownCloud: " + folder
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQCheckBox {
                    id: dropbox
                    enforceMaxWidth: set_excl.rightcol
                    property string folder: PQCSettings.thumbnailsExcludeDropBox // qmllint disable unqualified
                    visible: folder!=""
                    text: "DropBox: " + folder
                    onCheckedChanged: setting_top.checkDefault()
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
                        PQCNotify.ignoreKeysExceptEsc = controlActiveFocus // qmllint disable unqualified
                    }
                    onTextChanged: setting_top.checkDefault()
                },

                PQButton {
                    id: butaddfolder
                    //: Written on a button
                    text: qsTranslate("settingsmanager", "Add folder")
                    onClicked: {
                        var newdir = PQCScriptsFilesPaths.getExistingDirectory() // qmllint disable unqualified
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

            onResetToDefaults: {

                excludenetwork.checked = PQCSettings.getDefaultForThumbnailsExcludeNetworkShares()

                nextcloud.folder = PQCScriptsFilesPaths.findNextcloudFolder()
                nextcloud.checked = false

                owncloud.folder = PQCScriptsFilesPaths.findOwnCloudFolder()
                owncloud.checked = false

                dropbox.folder = PQCScriptsFilesPaths.findDropBoxFolder()
                dropbox.checked = false

                exclude_folders.text = PQCSettings.getDefaultForThumbnailsExcludeFolders()
            }

            function handleEscape() {
                butaddfolder.contextmenu.close()
            }

            function hasChanged() {
                return (nextcloud.hasChanged() || owncloud.hasChanged() || dropbox.hasChanged() ||
                        exclude_folders.text !== PQCSettings.thumbnailsExcludeFolders.join("\n") ||
                        excludenetwork.hasChanged())
            }

            function load() {

                excludenetwork.loadAndSetDefault(PQCSettings.thumbnailsExcludeNetworkShares)

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

            }

            function applyChanges() {

                PQCSettings.thumbnailsExcludeNetworkShares = excludenetwork.checked

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

                nextcloud.saveDefault()
                owncloud.saveDefault()
                dropbox.saveDefault()

            }

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
                        setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                threads.setValue(PQCSettings.getDefaultForThumbnailsMaxNumberThreads())
            }

            function handleEscape() {
                threads.closeContextMenus()
                threads.acceptValue()
            }

            function hasChanged() {
                return threads.hasChanged()
            }

            function load() {
                threads.loadAndSetDefault(PQCSettings.thumbnailsMaxNumberThreads)
            }

            function applyChanges() {
                PQCSettings.thumbnailsMaxNumberThreads = threads.value
                threads.saveDefault()
            }

        }

    }

    Component.onCompleted:
        load()

    Component.onDestruction:
        PQCNotify.ignoreKeysExceptEsc = false // qmllint disable unqualified

    function handleEscape() {
        set_cache.handleEscape()
        set_excl.handleEscape()
        set_thrd.handleEscape()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { // qmllint disable unqualified
            applyChanges()
            return
        }

        settingChanged = (set_cache.hasChanged() || set_excl.hasChanged() || set_thrd.hasChanged())

    }

    function load() {

        set_cache.load()
        set_excl.load()
        set_thrd.load()

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        set_cache.applyChanges()
        set_excl.applyChanges()
        set_thrd.applyChanges()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
