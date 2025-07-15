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

#include <QObject>

class PQExtensionsAPI {

public:
    enum DefaultPosition {
        TopLeft,
        Top,
        TopRight,
        Left,
        Center,
        Right,
        BottomLeft,
        Bottom,
        BottomRight
    };

    virtual ~PQExtensionsAPI() = default;

    // general metadata
    virtual int version() = 0;
    virtual QString name() = 0;
    virtual QString description() = 0;
    virtual QString author() = 0;
    virtual QString contact() = 0;
    virtual int targetAPIVersion() = 0;

    // some specific properties of this extension
    virtual QSize minimumRequiredWindowSize() = 0;
    virtual bool isModal() = 0;
    virtual PQExtensionsAPI::DefaultPosition positionAt() = 0;
    virtual bool rememberPosition() = 0;
    virtual bool passThroughMouseClicks() = 0;
    virtual bool passThroughMouseWheel() = 0;

    // settings and shortcuts
    virtual QList<QStringList> shortcuts() = 0;
    virtual QList<QStringList> settings() = 0;

    // if there have been any changes between any versions
    virtual QMap<QString, QList<QStringList> > migrateSettings() = 0;
    virtual QMap<QString, QList<QStringList> > migrateShortcuts() = 0;

    /////////////////////////////////////////

    // do something, but the actual image is not needed
    virtual QVariant action1(QString filepath) = 0;
    virtual QVariant action2(QString filepath) = 0;

    // do something and also provide me with the image
    virtual QVariant actionWithImage1(QString filepath, QImage &img) = 0;
    virtual QVariant actionWithImage2(QString filepath, QImage &img) = 0;


};

#define PhotoQt_IID "org.photoqt.PhotoQt"
Q_DECLARE_INTERFACE(PQExtensionsAPI, PhotoQt_IID)
