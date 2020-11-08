/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

#ifndef PQHANDLINGWALLPAPER_H
#define PQHANDLINGWALLPAPER_H

#include <QObject>
#include <QProcess>
#include <QtDBus>
#include <QGuiApplication>
#include "../logger.h"

class PQHandlingWallpaper : public QObject {

    Q_OBJECT

public:
    PQHandlingWallpaper(QObject *parent = nullptr);

    Q_INVOKABLE void setWallpaper(QString category, QString filename, QVariantMap options);
    Q_INVOKABLE int getScreenCount();
    Q_INVOKABLE QList<int> getEnlightenmentWorkspaceCount();
    Q_INVOKABLE bool checkXfce();
    Q_INVOKABLE bool checkFeh();
    Q_INVOKABLE bool checkNitrogen();
    Q_INVOKABLE bool checkGSettings();
    Q_INVOKABLE bool checkEnlightenmentRemote();
    Q_INVOKABLE bool checkEnlightenmentMsgbus();

    Q_INVOKABLE QString detectWM();

private:
    bool checkIfCommandExists(QString cmd, QStringList args, QString &out);

};


#endif // PQHANDLINGWALLPAPER_H
