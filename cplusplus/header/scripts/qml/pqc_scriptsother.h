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

#ifndef PQCSCRIPTSOTHER_H
#define PQCSCRIPTSOTHER_H

#include <QObject>
#include <QJSValue>
#include <QQmlEngine>

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton CANNOT be used from C++.
//            It can ONLY be used from QML.
//
/*************************************************************/
/*************************************************************/

class PQCScriptsOther : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCScriptsOther();
    ~PQCScriptsOther();

    // screenshot handling
    Q_INVOKABLE void deleteScreenshots();

    // get methods
    Q_INVOKABLE qint64 getTimestamp();
    Q_INVOKABLE QString getUniqueId();
    Q_INVOKABLE int getCurrentScreen(QPoint pos);

    // print a file
    Q_INVOKABLE void printFile(QString filename);

    // color handling
    Q_INVOKABLE QString addAlphaToColor(QString rgb, int alpha);
    Q_INVOKABLE QVariantList convertHexToRgba(QString hex);
    Q_INVOKABLE QString convertRgbaToHex(QVariantList rgba);
    Q_INVOKABLE QString convertRgbToHex(QVariantList rgb);
    Q_INVOKABLE QVariantList selectColor(QVariantList def);

    // global methods
    Q_INVOKABLE void setPointingHandCursor();
    Q_INVOKABLE void restoreOverrideCursor();
    Q_INVOKABLE bool showDesktopNotification(QString summary, QString txt);

    // QML convenience methods
    Q_INVOKABLE QStringList convertJSArrayToStringList(QVariant val);

};

#endif
