/**************************************************************************
 * *                                                                      **
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
import PhotoQt

PQSetting {

    id: set_mana

    content: [

        PQSettingSubtitle {

            showLineAbove: false

            //: A settings title
            title: qsTranslate("settingsmanager", "Cache")

            helptext: qsTranslate("settingsmanager", "PhotoQt can cache thumbnails so that each subsequent time they can be generated near instantaneously. PhotoQt implements the standard for thumbnails defined by freedesktop.org. On Windows it can also load (but not write) existing thumbnails from the thumbnail cache built into Windows.")

        },

        Column {

            spacing: 5

            PQCheckBox {
                id: cache_enable
                enforceMaxWidth: set_mana.contentWidth
                text: qsTranslate("settingsmanager", "enable cache")
                onCheckedChanged: set_mana.checkForChanges()
            }

            PQCheckBox {
                id: cache_dir_default
                enforceMaxWidth: set_mana.contentWidth
                enabled: cache_enable.checked
                text: qsTranslate("settingsmanager", "use default cache directory")
                onCheckedChanged: set_mana.checkForChanges()
            }

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
                        cache_dir_default.checked = false
                        cache_dir_custom.customdir = path
                        set_mana.checkForChanges()
                    }
                }

            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                cache_enable.checked = PQCSettings.getDefaultForThumbnailsCache
                cache_dir_default.checked = PQCSettings.getDefaultForThumbnailsCacheBaseDirDefault()
                cache_dir_custom.customdir = PQCSettings.getDefaultForThumbnailsCacheBaseDirLocation()

                set_mana.checkForChanges()

            }
        },

        /**************************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Exclude folders")

            helptext: qsTranslate("settingsmanager", "When an image is loaded PhotoQt preloads thumbnails for all images found in the current folder. Certain types of network folders and some cloud providers do not fully sync their files unless accessed. To avoid unnecessarily downloading large amount of files, it is possible to exclude specific directories from any sort of caching and preloading. Note that for files in these folders you will still see thumbnails consisting of filetype icons.")

        },

        Column {

            spacing: 5

            PQCheckBox {
                id: excludenetwork
                text: qsTranslate("settingsmanager", "Exclude network shares (if any) from caching")
                onCheckedChanged: set_mana.checkForChanges()
            }

            Item {
                width: 1
                height: 1
                visible: nextcloud.visible||owncloud.visible||dropbox.visible
            }

            PQText {
                id: cloudheader
                width: set_mana.contentWidth
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTranslate("settingsmanager", "Cloud providers to exclude from caching:")
                visible: nextcloud.visible||owncloud.visible||dropbox.visible
            }

            PQCheckBox {
                id: nextcloud
                enforceMaxWidth: set_mana.contentWidth
                property string folder: PQCSettings.thumbnailsExcludeNextcloud
                visible: folder!=""
                text: "Nextcloud: " + folder
                onCheckedChanged: set_mana.checkForChanges()
            }

            PQCheckBox {
                id: owncloud
                enforceMaxWidth: set_mana.contentWidth
                property string folder: PQCSettings.thumbnailsExcludeOwnCloud
                visible: folder!=""
                text: "ownCloud: " + folder
                onCheckedChanged: set_mana.checkForChanges()
            }

            PQCheckBox {
                id: dropbox
                enforceMaxWidth: set_mana.contentWidth
                property string folder: PQCSettings.thumbnailsExcludeDropBox
                visible: folder!=""
                text: "DropBox: " + folder
                onCheckedChanged: set_mana.checkForChanges()
            }

            Item {
                width: 1
                height: 10
            }

            PQText {
                text: qsTranslate("settingsmanager", "Do not cache these folders:")
            }

            PQTextArea {
                id: exclude_folders
                implicitWidth: Math.min(400, set_mana.contentWidth)
                implicitHeight: 100
                placeholderText: qsTranslate("settingsmanager", "One folder per line")
                onTextChanged: set_mana.checkForChanges()
            }

            PQButton {
                id: butaddfolder
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

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                excludenetwork.checked = PQCSettings.getDefaultForThumbnailsExcludeNetworkShares()

                nextcloud.folder = PQCScriptsFilesPaths.findNextcloudFolder()
                nextcloud.checked = false

                owncloud.folder = PQCScriptsFilesPaths.findOwnCloudFolder()
                owncloud.checked = false

                dropbox.folder = PQCScriptsFilesPaths.findDropBoxFolder()
                dropbox.checked = false

                exclude_folders.text = PQCSettings.getDefaultForThumbnailsExcludeFolders()

                set_mana.checkForChanges()

            }
        },

        /********************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "How many threads")

            helptext: qsTranslate("settingsmanager", "In order to speed up loading all the thumbnails in a folder PhotoQt uses multiple threads simultaneously. On more powerful systems, a larger number of threads can result in much faster loading of all the thumbnails of a folder. Too many threads, however, might make a system feel slow for a short time.")

        },

        PQAdvancedSlider {
            id: threads
            width: set_mana.contentWidth
            minval: 1
            maxval: 32
            title: ""
            suffix: " threads"
            onValueChanged:
                set_mana.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                threads.setValue(PQCSettings.getDefaultForThumbnailsMaxNumberThreads())

                set_mana.checkForChanges()

            }
        }

    ]

    function handleEscape() {
        threads.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (cache_enable.hasChanged() || cache_dir_default.hasChanged() ||
                                                      cache_dir_custom.customdir !== PQCSettings.thumbnailsCacheBaseDirLocation) ||
                                                     (nextcloud.hasChanged() || owncloud.hasChanged() || dropbox.hasChanged() ||
                                                      exclude_folders.text !== PQCSettings.thumbnailsExcludeFolders.join("\n") ||
                                                      excludenetwork.hasChanged()) || threads.hasChanged()

    }

    function load() {

        settingsLoaded = false

        cache_enable.loadAndSetDefault(PQCSettings.thumbnailsCache)
        cache_dir_default.loadAndSetDefault(PQCSettings.thumbnailsCacheBaseDirDefault)
        cache_dir_custom.customdir = PQCSettings.thumbnailsCacheBaseDirLocation


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


        threads.loadAndSetDefault(PQCSettings.thumbnailsMaxNumberThreads)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.thumbnailsCache = cache_enable.checked
        PQCSettings.thumbnailsCacheBaseDirDefault = cache_dir_default.checked
        PQCSettings.thumbnailsCacheBaseDirLocation = cache_dir_custom.customdir
        PQCScriptsFilesPaths.setThumbnailBaseCacheDir(cache_dir_default.checked ? "" : cache_dir_custom.customdir)
        cache_enable.saveDefault()
        cache_dir_default.saveDefault()

        PQCSettings.thumbnailsExcludeNetworkShares = excludenetwork.checked
        excludenetwork.saveDefault()

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


        PQCSettings.thumbnailsMaxNumberThreads = threads.value
        threads.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
