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
#pragma once

#include <QString>
#include <QStringList>
#include <QSize>
#include <QtDebug>

class PQCExtensionInfo {
public:

    PQCExtensionInfo() {

        // about
        version = 0;
        name = "";
        longName= "";
        description = "";
        author = "";
        contact = "";
        website = "";
        targetAPI = 0;

        // setup/integrated
        integratedAllow = true;
        integratedMinimumRequiredWindowSize = QSize(0,0);
        integratedDefaultPosition = 0;
        integratedDefaultDistanceFromEdge = 50;
        integratedDefaultSize = QSize(-1,-1);
        integratedFixSizeToContent = false;

        // setup/popout
        popoutAllow = true;
        popoutDefaultSize = QSize(-1,-1);
        popoutFixSizeToContent = false;

        // setup
        modal = false;
        mainmenu = false;
        defaultShortcut = "";
        rememberGeometry = true;
        haveCPPActions = false;
        contextMenuSection = "";
        settings = {};

        /***********************/
        // auto generated
        location = "";

    }

    // about
    int version;
    QString name;
    QString longName;
    QString description;
    QString author;
    QString contact;
    QString website;
    int targetAPI;

    // setup/integrated
    bool  integratedAllow;
    QSize integratedMinimumRequiredWindowSize;
    int   integratedDefaultPosition;
    int   integratedDefaultDistanceFromEdge;
    QSize integratedDefaultSize;
    bool  integratedFixSizeToContent;

    // setup/popout
    bool  popoutAllow;
    QSize popoutDefaultSize;
    bool  popoutFixSizeToContent;

    // setup
    bool modal;
    bool mainmenu;
    QString defaultShortcut;
    bool    rememberGeometry;
    bool    haveCPPActions;
    QString contextMenuSection;
    QList<QStringList> settings;

    /***************/

    // extension location in file system
    QString location;

    // convert string to int
    int getIntegerForPosition(std::string val) {
        if(val == "TopLeft" || val == "")
            return 0;
        else if(val == "Top")
            return 1;
        else if(val == "TopRight")
            return 2;
        else if(val == "Left")
            return 3;
        else if(val == "Center")
            return 4;
        else if(val == "Right")
            return 5;
        else if(val == "BottomLeft")
            return 6;
        else if(val == "Bottom")
            return 7;
        else if(val == "BottomRight")
            return 8;
        else {
            qWarning() << "Invalid enum value found:" << val;
            return 0;
        }
    }

};
