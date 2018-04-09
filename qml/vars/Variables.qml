/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

import QtQuick 2.5

Item {

    // GLOBAL/MISC

    // Element radius is the radius of "windows" (e.g., About or Quicksettings)
    readonly property int global_element_radius: 10
    // Item radius is the radius of smaller items (e.g., spinbox)
    readonly property int global_item_radius: 5
    // The speed of the animations (how fast elements fade in/out)
    property int animationSpeed: settings.animations ? 250 : 0

    // This is set to true whenever an element is open in front focus (e.g., settings manager, ...)
    property bool guiBlocked: false

    // This is set to true when a file was deleted and nothing is left in the directory
    property bool deleteNothingLeft: false

    // This is set to true when a filter string was entered that resulted in no match
    property bool filterNoMatch: false

    // stores the update status to pass on to startup element
    property int startupUpdateStatus: 0

    // This is the file that is to be loaded after the startup element is closed
    property string startupFilenameAfter: ""

    // The height of the thumbnails, set by ThumbnailBar used by MainImage to make sure there's enough space
    property int thumbnailsheight: 0

    // The x/y of the root window (set by c++ code)
    property point windowXY: Qt.point(-1,-1)

    property bool isWindowFullscreen: false


    // INFO ABOUT CUR DIR/FILE

    // The current file (without path)
    property string currentFile: ""
    // The current directory (without filename)
    property string currentDir: ""

    // This is the position of the current file in the folder
    property int currentFilePos: (currentFile.indexOf("::ARCHIVE1::")!=-1&&currentFile.indexOf("::ARCHIVE2::")!=-1) ?
                                     (allFilesCurrentDir.indexOf("::ARCHIVE1::"+currentFile.split("::ARCHIVE1::")[1])>= 0 ?
                                          allFilesCurrentDir.indexOf("::ARCHIVE1::"+currentFile.split("::ARCHIVE1::")[1]) :
                                          -1) :
                                     (allFilesCurrentDir.indexOf(getanddostuff.removePathFromFilename(currentFile))>=0 ?
                                        allFilesCurrentDir.indexOf(getanddostuff.removePathFromFilename(currentFile)) :
                                        -1)

    // Sometimes the page number is stored in the filename (e.g., for Poppler (PDF) documents). This string is the filename WITHOUT that information
    readonly property string currentFileWithoutExtras: (currentFile.indexOf("::ARCHIVE1::")!=-1&&currentFile.indexOf("::ARCHIVE2::")!=-1) ?
                                                           getanddostuff.removePathFromFilename((currentFile.split("::ARCHIVE1::")[1].split("::ARCHIVE2::")[0])) :
                                                           (currentFile.indexOf("::PQT1::")!=-1&&currentFile.indexOf("::PQT2::")!=-1) ?
                                                               (currentFile.split("::PQT1::")[0] + currentFile.split("::PQT2::")[1]) :
                                                               currentFile

    property string currentFileInsideArchive: ""

    // The total number of images in current folder
    property int totalNumberImagesCurrentFolder: 0

    // The list of all files loaded in the current directory
    property var allFilesCurrentDir: []

    // The string for filtering the current directory
    property string filter: ""

    // These two are convenience functions, storing the current page and total page number
    property int multiPageCurrentPage: -1
    property int multiPageTotalNumber: -1


    // SLIDESHOW

    // This is set by the slideshowbar while the slideshow is running (to prevent the image from being moved)
    property bool imageItemBlocked: false

    // This is true whenever the slideshow is running
    property bool slideshowRunning: false


    // SHORTCUTS

    // The mouse gesture string, used by mouseshortcuts.js
    property var shortcutsMouseGesture: []

    // The intermediate points of the mouse gesture, used by mouseshortcuts.js
    property point shorcutsMouseGesturePointIntermediate: Qt.point(-1,-1)

    // how much wheel movement in a direction (used for mouse shortcuts)
    property int wheelUpDown: 0
    property int wheelLeftRight: 0



    property int currentZoomLevel: 75

    property bool mousePressed: false
    property point mouseCurrentPos: Qt.point(-1,-1)
    property var peopleFaceTags: []
    property bool taggingFaces: false
    property bool mouseHoveringFaceTag: false
    onPeopleFaceTagsChanged: mouseHoveringFaceTag = false


    // temporary solution to avoid having to retranslate the names for the possible shortcuts (will be replaced with better solution for following release)
    property var shortcutTitles: ({})

}
