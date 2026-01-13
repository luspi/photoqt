/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
#include <QJSValue>
#include <QQmlEngine>

class PQCScriptsOther : public QObject {

    Q_OBJECT

public:
    static PQCScriptsOther& get() {
        static PQCScriptsOther instance;
        return instance;
    }

    PQCScriptsOther(PQCScriptsOther const&)     = delete;
    void operator=(PQCScriptsOther const&) = delete;

    // screenshot handling
    void deleteScreenshots();

    // get methods
    qint64 getTimestamp();
    QString getUniqueId();
    int getCurrentScreen(QPoint pos);

    // print a file
    void printFile(QString filename);

    // color handling
    QString addAlphaToColor(QString rgb, int alpha);
    QVariantList convertHexToRgba(QString hex);
    QString convertRgbaToHex(QVariantList rgba);
    QString convertRgbToHex(QVariantList rgb);
    QVariantList selectColor(QVariantList def);

    // global methods
    void setPointingHandCursor();
    void restoreOverrideCursor();
    bool showDesktopNotification(QString summary, QString txt);

    // QML convenience methods
    QStringList convertJSArrayToStringList(QVariant val);

private:
    PQCScriptsOther();
    ~PQCScriptsOther();

};
