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

#ifndef PQCSCRIPTSWALLPAPER_H
#define PQCSCRIPTSWALLPAPER_H

#include <QObject>
#include <QQmlEngine>

// TODO
//
// THIS CLASS WILL BE MOVED TO THE SPECIFIC EXTENSION!

class PQCScriptsWallpaper : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit PQCScriptsWallpaper();
    ~PQCScriptsWallpaper();

    Q_INVOKABLE int getScreenCount();

    Q_INVOKABLE bool checkGSettings();

    Q_INVOKABLE bool checkFeh();
    Q_INVOKABLE bool checkNitrogen();

    Q_INVOKABLE bool checkXfce();

    Q_INVOKABLE bool checkEnlightenmentMsgbus();
    Q_INVOKABLE bool checkEnlightenmentRemote();
    Q_INVOKABLE QList<int> getEnlightenmentWorkspaceCount();

    Q_INVOKABLE void setWallpaper(QString category, QString filename, QVariantMap options);

private:
    bool checkIfCommandExists(QString cmd, QStringList args, QString &out);

};

#endif
