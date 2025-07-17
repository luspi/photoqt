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
import PhotoQt

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:
// - interfaceAllowMultipleInstances

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    PQScrollManager { flickable: setting_top }

    property bool settingChanged: false
    property bool settingsLoaded: false
    property bool catchEscape: false

    Column {

        id: contcol

        spacing: 10

        width: parent.width

        PQSetting {

            id: set_single

            //: Settings title
            title: qsTranslate("settingsmanager", "Single instance")

            helptext: qsTranslate("settingsmanager", "PhotoQt can either run in single-instance mode or allow multiple instances to run at the same time. The former has the advantage that it is possible to interact with a running instance of PhotoQt through the command line (in fact, this is a requirement for that to work). The latter allows, for example, for the comparison of multiple images side by side.")

            content: [

                PQRadioButton {
                    id: sing
                    enforceMaxWidth: set_single.rightcol
                    text: qsTranslate("settingsmanager", "run a single instance only")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: mult
                    enforceMaxWidth: set_single.rightcol
                    text: qsTranslate("settingsmanager", "allow multiple instances")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                mult.checked = PQCSettings.getDefaultForInterfaceAllowMultipleInstances()
                sing.checked = !mult.checked
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (mult.hasChanged() || sing.hasChanged())
            }

            function load() {
                sing.loadAndSetDefault(!PQCSettings.interfaceAllowMultipleInstances) // qmllint disable unqualified
                mult.loadAndSetDefault(PQCSettings.interfaceAllowMultipleInstances)
            }

            function applyChanges() {
                PQCSettings.interfaceAllowMultipleInstances = mult.checked // qmllint disable unqualified
                mult.saveDefault()
                sing.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_reopen

            //: Settings title
            title: qsTranslate("settingsmanager", "Reopen last image")

            helptext: qsTranslate("settingsmanager", "When PhotoQt is started normally, by default an empty window is shown with the prompt to open an image from the file dialog. Alternatively it is also possible to reopen the image that was last loaded in the previous session.")

            content: [

                PQRadioButton {
                    id: blanksession
                    enforceMaxWidth: set_reopen.rightcol
                    text: qsTranslate("settingsmanager", "start with blank session")
                    onCheckedChanged: setting_top.checkDefault()
                },

                PQRadioButton {
                    id: reopenlast
                    enforceMaxWidth: set_reopen.rightcol
                    text: qsTranslate("settingsmanager", "reopen last used image")
                    onCheckedChanged: setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                reopenlast.checked = PQCSettings.getDefaultForInterfaceRememberLastImage()
                blanksession.checked = !reopenlast.checked
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (blanksession.hasChanged() || reopenlast.hasChanged())
            }

            function load() {
                blanksession.loadAndSetDefault(!PQCSettings.interfaceRememberLastImage)
                reopenlast.loadAndSetDefault(PQCSettings.interfaceRememberLastImage)
            }

            function applyChanges() {
                PQCSettings.interfaceRememberLastImage = reopenlast.checked
                blanksession.saveDefault()
                reopenlast.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_rem

            //: Settings title
            title: qsTranslate("settingsmanager", "Remember changes")

            helptext: qsTranslate("settingsmanager", "Once an image has been loaded it can be manipulated freely by zooming, rotating, or mirroring the image. Once another image is loaded any such changes are forgotten. If preferred, it is possible for PhotoQt to remember any such manipulations per session. Note that once PhotoQt is closed these changes will be forgotten in any case.") + "<br><br>" + qsTranslate("settingsmanager", "In addition to on an per-image basis, PhotoQt can also keep the same changes across different images. If enabled and possible, the next image is loaded with the same scaling, rotation, and mirroring as the image before.")

            ButtonGroup { id: changedgroup }

            content: [

                PQRadioButton {
                    id: forget
                    enforceMaxWidth: set_rem.rightcol
                    text: qsTranslate("settingsmanager", "forget changes when other image loaded")
                    onCheckedChanged: setting_top.checkDefault()
                    ButtonGroup.group: changedgroup
                },

                PQRadioButton {
                    id: remember
                    enforceMaxWidth: set_rem.rightcol
                    text: qsTranslate("settingsmanager", "remember changes per session")
                    onCheckedChanged: setting_top.checkDefault()
                    ButtonGroup.group: changedgroup
                },

                Flow {
                    width: set_rem.rightcol
                    PQRadioButton {
                        id: reuse
                        //: this refers to preserving any selection of zoom/rotation/mirror across different images
                        text: qsTranslate("settingsmanager", "preserve across images:")
                        ButtonGroup.group: changedgroup
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    PQCheckBox {
                        id: reuse_zoom
                        text: qsTranslate("settingsmanager", "Zoom")
                        enabled: reuse.checked
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    PQCheckBox {
                        id: reuse_rotation
                        text: qsTranslate("settingsmanager", "Rotation")
                        enabled: reuse.checked
                        onCheckedChanged: setting_top.checkDefault()
                    }
                    PQCheckBox {
                        id: reuse_mirror
                        text: qsTranslate("settingsmanager", "Mirror")
                        enabled: reuse.checked
                        onCheckedChanged: setting_top.checkDefault()
                    }
                }

            ]

            onResetToDefaults: {
                remember.checked = PQCSettings.getDefaultForImageviewRememberZoomRotationMirror()
                forget.checked = !remember.checked

                reuse_zoom.checked = PQCSettings.getDefaultForImageviewPreserveZoom()
                reuse_rotation.checked = PQCSettings.getDefaultForImageviewPreserveRotation()
                reuse_mirror.checked = PQCSettings.getDefaultForImageviewPreserveMirror()
                reuse.checked = (reuse_zoom.checked||reuse_rotation.checked||reuse_mirror.checked)
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (forget.hasChanged() || remember.hasChanged() || reuse.hasChanged() ||
                        reuse_zoom.hasChanged() || reuse_rotation.hasChanged() || reuse_mirror.hasChanged())
            }

            function load() {
                forget.loadAndSetDefault(!PQCSettings.imageviewRememberZoomRotationMirror)
                remember.loadAndSetDefault(PQCSettings.imageviewRememberZoomRotationMirror)

                reuse_zoom.loadAndSetDefault(PQCSettings.imageviewPreserveZoom)
                reuse_rotation.loadAndSetDefault(PQCSettings.imageviewPreserveRotation)
                reuse_mirror.loadAndSetDefault(PQCSettings.imageviewPreserveMirror)
                reuse.loadAndSetDefault(reuse_zoom.checked||reuse_rotation.checked||reuse_mirror.checked)
            }

            function applyChanges() {
                PQCSettings.imageviewRememberZoomRotationMirror = remember.checked
                PQCSettings.imageviewPreserveZoom = (reuse.checked && reuse_zoom.checked)
                PQCSettings.imageviewPreserveRotation = (reuse.checked && reuse_rotation.checked)
                PQCSettings.imageviewPreserveMirror = (reuse.checked && reuse_mirror.checked)
                forget.saveDefault()
                remember.saveDefault()
                reuse.saveDefault()
                reuse_zoom.saveDefault()
                reuse_rotation.saveDefault()
                reuse_mirror.saveDefault()
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_tray

            //: Settings title
            title: qsTranslate("settingsmanager", "Tray Icon")

            helptext: qsTranslate("settingsmanager", "PhotoQt can show a small icon in the system tray. The tray icon provides additional ways to control and interact with the application. It is also possible to hide PhotoQt to the system tray instead of closing. By default a colored version of the tray icon is used, but it is also possible to use a monochrome version.")

            content: [

                PQCheckBox {
                    id: trayicon_show
                    enforceMaxWidth: set_tray.rightcol
                    text: qsTranslate("settingsmanager", "Show tray icon")
                    onCheckedChanged: setting_top.checkDefault()
                },

                Column {

                    spacing: set_tray.spacing
                    clip: true

                    enabled: trayicon_show.checked
                    height: enabled ? trayicon_mono.height+trayicon_hide.height+spacing : 0
                    Behavior on height { NumberAnimation { duration: 200 } }
                    opacity: enabled ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    PQCheckBox {
                        id: trayicon_mono
                        enforceMaxWidth: set_tray.rightcol
                        enabled: trayicon_show.checked
                        text: qsTranslate("settingsmanager", "monochrome icon")
                        onCheckedChanged: setting_top.checkDefault()
                    }

                    PQCheckBox {
                        id: trayicon_hide
                        enforceMaxWidth: set_tray.rightcol
                        enabled: trayicon_show.checked
                        text: qsTranslate("settingsmanager", "hide to tray icon instead of closing")
                        checked: (PQCSettings.interfaceTrayIcon===1) // qmllint disable unqualified
                        onCheckedChanged: setting_top.checkDefault()
                    }

                }

            ]

            onResetToDefaults: {
                trayicon_show.checked = PQCSettings.getDefaultForInterfaceTrayIcon()
                trayicon_hide.checked = PQCSettings.getDefaultForInterfaceTrayIcon()
                trayicon_mono.checked = PQCSettings.getDefaultForInterfaceTrayIconMonochrome()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return (trayicon_show.hasChanged() || trayicon_mono.hasChanged() || trayicon_hide.hasChanged())
            }

            function load() {
                trayicon_show.loadAndSetDefault(PQCSettings.interfaceTrayIcon>0)
                trayicon_hide.loadAndSetDefault(PQCSettings.interfaceTrayIcon===1)
                trayicon_mono.loadAndSetDefault(PQCSettings.interfaceTrayIconMonochrome)
            }

            function applyChanges() {

                if(trayicon_show.checked) {
                    if(trayicon_hide.checked)
                        PQCSettings.interfaceTrayIcon = 1
                    else
                        PQCSettings.interfaceTrayIcon = 2
                } else
                    PQCSettings.interfaceTrayIcon = 0

                PQCSettings.interfaceTrayIconMonochrome = trayicon_mono.checked

                trayicon_show.saveDefault()
                trayicon_hide.saveDefault()
                trayicon_mono.saveDefault()

            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_reset

            //: Settings title
            title: qsTranslate("settingsmanager", "Reset when hiding")

            helptext: qsTranslate("settingsmanager", "When hiding PhotoQt in the system tray, it is possible to reset PhotoQt to its initial state, thus freeing most of the memory tied up by caching. Note that this will also unload any loaded folder and image.")

            content: [
                PQCheckBox {
                    id: trayicon_reset
                    enforceMaxWidth: set_reset.rightcol
                    text: qsTranslate("settingsmanager", "reset session when hiding")
                    onCheckedChanged: setting_top.checkDefault()
                }
            ]

            onResetToDefaults: {
                trayicon_reset.checked = PQCSettings.getDefaultForInterfaceTrayIconHideReset()
            }

            function handleEscape() {
            }

            function hasChanged() {
                return trayicon_reset.hasChanged()
            }

            function load() {
                trayicon_reset.loadAndSetDefault(PQCSettings.interfaceTrayIconHideReset)
            }

            function applyChanges() {
                PQCSettings.interfaceTrayIconHideReset = trayicon_reset.checked
                trayicon_reset.saveDefault()
            }

        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
        set_single.handleEscape()
        set_reopen.handleEscape()
        set_rem.handleEscape()
        set_tray.handleEscape()
        set_reset.handleEscape()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { // qmllint disable unqualified
            applyChanges()
            return
        }

        settingChanged = (set_single.hasChanged() || set_reopen.hasChanged() || set_rem.hasChanged() ||
                          set_tray.hasChanged() || set_reset.hasChanged())

    }

    function load() {

        set_single.load()
        set_reopen.load()
        set_rem.load()
        set_tray.load()
        set_reset.load()

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        set_single.applyChanges()
        set_reopen.applyChanges()
        set_rem.applyChanges()
        set_tray.applyChanges()
        set_reset.applyChanges()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
