/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.9
import QtQuick.Controls 2.2

import "./shortcuts"
import "../../elements"

Item {

    id: tab_shortcuts

    Flickable {

        id: cont

        contentHeight: col.height
        onContentHeightChanged: {
            if(visible)
                settingsmanager_top.scrollBarVisible = scroll.visible
        }

        width: stack.width
        height: stack.height

        ScrollBar.vertical: PQScrollBar { id: scroll }

        Column {

            id: col

            x: 10

            spacing: 15

            Item {
                width: 1
                height: 1
            }

            Text {
                id: title
                width: cont.width-30
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 25
                font.bold: true
                color: "white"
                text: em.pty+qsTranslate("settingsmanager", "Shortcuts")
            }

            Item {
                width: 1
                height: 1
            }

            Text {
                id: desc
                color: "white"
                font.pointSize: 12
                width: cont.width-30
                wrapMode: Text.WordWrap
                text: em.pty+qsTranslate("settingsmanager", "Here the shortcuts can be managed. Below you can add a new shortcut for any one of the available actions, both key combinations and mouse gestures are supported.") + "\n" + em.pty+qsTranslate("settingsmanager", "You can also set the same shortcut for multiple actions or multiple times for the same action. All actions for a shortcut will be executed sequentially, allowing a lot more flexibility in using PhotoQt.")
            }

            PQContainer {

                //: A shortcuts category: navigation
                category: em.pty+qsTranslate("settingsmanager", "Navigation")

                available: [
                                            //: Name of shortcut action
                    ["__open",              em.pty+qsTranslate("settingsmanager", "Open new file")],
                                            //: Name of shortcut action
                    ["__filterImages",      em.pty+qsTranslate("settingsmanager", "Filter images in folder")],
                                            //: Name of shortcut action
                    ["__next",              em.pty+qsTranslate("settingsmanager", "Next image")],
                                            //: Name of shortcut action
                    ["__prev",              em.pty+qsTranslate("settingsmanager", "Previous image")],
                                            //: Name of shortcut action
                    ["__goToFirst",         em.pty+qsTranslate("settingsmanager", "Go to first image")],
                                            //: Name of shortcut action
                    ["__goToLast",          em.pty+qsTranslate("settingsmanager", "Go to last image")],
                                            //: Name of shortcut action
                    ["__viewerMode",        em.pty+qsTranslate("settingsmanager", "Enter viewer mode")],
                                            //: Name of shortcut action
                    ["__quickNavigation",   em.pty+qsTranslate("settingsmanager", "Show quick navigation buttons")],
                                            //: Name of shortcut action
                    ["__close",             em.pty+qsTranslate("settingsmanager", "Close window (hides to system tray if enabled)")],
                                            //: Name of shortcut action
                    ["__quit",              em.pty+qsTranslate("settingsmanager", "Quit PhotoQt")]
                ]

            }

            PQContainer {

                //: A shortcuts category: image manipulation
                category: em.pty+qsTranslate("settingsmanager", "Image")

                available: [
                                        //: Name of shortcut action
                    ["__zoomIn",        em.pty+qsTranslate("settingsmanager", "Zoom In")],
                                        //: Name of shortcut action
                    ["__zoomOut",       em.pty+qsTranslate("settingsmanager", "Zoom Out")],
                                        //: Name of shortcut action
                    ["__zoomActual",    em.pty+qsTranslate("settingsmanager", "Zoom to Actual Size")],
                                        //: Name of shortcut action
                    ["__zoomReset",     em.pty+qsTranslate("settingsmanager", "Reset Zoom")],
                                        //: Name of shortcut action
                    ["__rotateR",       em.pty+qsTranslate("settingsmanager", "Rotate Right")],
                                        //: Name of shortcut action
                    ["__rotateL",       em.pty+qsTranslate("settingsmanager", "Rotate Left")],
                                        //: Name of shortcut action
                    ["__rotate0",       em.pty+qsTranslate("settingsmanager", "Reset Rotation")],
                                        //: Name of shortcut action
                    ["__flipH",         em.pty+qsTranslate("settingsmanager", "Flip Horizontally")],
                                        //: Name of shortcut action
                    ["__flipV",         em.pty+qsTranslate("settingsmanager", "Flip Vertically")],
                                        //: Name of shortcut action
                    ["__scale",         em.pty+qsTranslate("settingsmanager", "Scale Image")],
                                        //: Name of shortcut action
                    ["__playPauseAni",  em.pty+qsTranslate("settingsmanager", "Play/Pause animation/video")],
                                        //: Name of shortcut action
                    ["__showFaceTags",  em.pty+qsTranslate("settingsmanager", "Hide/Show face tags (stored in metadata)")],
                                        //: Name of shortcut action
                    ["__tagFaces",      em.pty+qsTranslate("settingsmanager", "Tag faces (stored in metadata)")]
                ]

            }

            PQContainer {

                //: A shortcuts category: file management
                category: em.pty+qsTranslate("settingsmanager", "File")

                available: [
                                            //: Name of shortcut action
                    ["__rename",            em.pty+qsTranslate("settingsmanager", "Rename File")],
                                            //: Name of shortcut action
                    ["__delete",            em.pty+qsTranslate("settingsmanager", "Delete File")],
                                            //: Name of shortcut action
                    ["__deletePermanent",   em.pty+qsTranslate("settingsmanager", "Delete File (without confirmation)")],
                                            //: Name of shortcut action
                    ["__copy",              em.pty+qsTranslate("settingsmanager", "Copy File to a New Location")],
                                            //: Name of shortcut action
                    ["__move",              em.pty+qsTranslate("settingsmanager", "Move File to a New Location")],
                                            //: Name of shortcut action
                    ["__clipboard",         em.pty+qsTranslate("settingsmanager", "Copy Image to Clipboard")],
                                            //: Name of shortcut action
                    ["__saveAs",            em.pty+qsTranslate("settingsmanager", "Save image in another format")]
                ]

            }

            PQContainer {

                //: A shortcuts category: other functions
                category: em.pty+qsTranslate("settingsmanager", "Other")

                available: [
                                            //: Name of shortcut action
                    ["__showMainMenu",      em.pty+qsTranslate("settingsmanager", "Hide/Show main menu")],
                                            //: Name of shortcut action
                    ["__showMetaData",      em.pty+qsTranslate("settingsmanager", "Hide/Show metadata")],
                                            //: Name of shortcut action
                    ["__keepMetaData",      em.pty+qsTranslate("settingsmanager", "Keep metadata opened")],
                                            //: Name of shortcut action
                    ["__showThumbnails",    em.pty+qsTranslate("settingsmanager", "Hide/Show thumbnails")],
                                            //: Name of shortcut action
                    ["__settings",          em.pty+qsTranslate("settingsmanager", "Show Settings")],
                                            //: Name of shortcut action
                    ["__slideshow",         em.pty+qsTranslate("settingsmanager", "Start Slideshow")],
                                            //: Name of shortcut action
                    ["__slideshowQuick",    em.pty+qsTranslate("settingsmanager", "Start Slideshow (Quickstart)")],
                                            //: Name of shortcut action
                    ["__about",             em.pty+qsTranslate("settingsmanager", "About PhotoQt")],
                                            //: Name of shortcut action
                    ["__wallpaper",         em.pty+qsTranslate("settingsmanager", "Set as Wallpaper")],
                                            //: Name of shortcut action
                    ["__histogram",         em.pty+qsTranslate("settingsmanager", "Show Histogram")],
                                            //: Name of shortcut action
                    ["__imgurAnonym",       em.pty+qsTranslate("settingsmanager", "Upload to imgur.com (anonymously)")],
                                            //: Name of shortcut action
                    ["__imgur",             em.pty+qsTranslate("settingsmanager", "Upload to imgur.com user account")]
                ]

            }

            PQExternalContainer {

                id: external

                //: A shortcuts category: external shortcuts
                category: em.pty+qsTranslate("settingsmanager", "External")

                //: Please leave the three placeholders (%f, %u, %d) as is.
                subtitle: em.pty+qsTranslate("settingsmanager", "%f = filename including path, %u = filename without path, %d = directory containing file")

            }

            Item {
                width: 1
                height: 1
            }

        }

    }

}
