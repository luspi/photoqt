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
#include <QQmlEngine>
#include <QPoint>
#include <qml/pqc_scriptsother.h>

class PQCScriptsOtherQML : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(PQCScriptsOther)

public:
    PQCScriptsOtherQML() {}

    // screenshot handling
    Q_INVOKABLE void deleteScreenshots() {
        PQCScriptsOther::get().deleteScreenshots();
    }

    // get methods
    Q_INVOKABLE qint64 getTimestamp() {
        return PQCScriptsOther::get().getTimestamp();
    }
    Q_INVOKABLE QString getUniqueId() {
        return PQCScriptsOther::get().getUniqueId();
    }
    Q_INVOKABLE int getCurrentScreen(QPoint pos) {
        return PQCScriptsOther::get().getCurrentScreen(pos);
    }

    // print a file
    Q_INVOKABLE void printFile(QString filename) {
        PQCScriptsOther::get().printFile(filename);
    }

    // color handling
    Q_INVOKABLE QString addAlphaToColor(QString rgb, int alpha) {
        return PQCScriptsOther::get().addAlphaToColor(rgb, alpha);
    }
    Q_INVOKABLE QVariantList convertHexToRgba(QString hex) {
        return PQCScriptsOther::get().convertHexToRgba(hex);
    }
    Q_INVOKABLE QString convertRgbaToHex(QVariantList rgba) {
        return PQCScriptsOther::get().convertRgbaToHex(rgba);
    }
    Q_INVOKABLE QString convertRgbToHex(QVariantList rgb) {
        return PQCScriptsOther::get().convertRgbToHex(rgb);
    }
    Q_INVOKABLE QVariantList selectColor(QVariantList def) {
        return PQCScriptsOther::get().selectColor(def);
    }

    // global methods
    Q_INVOKABLE void setPointingHandCursor() {
        PQCScriptsOther::get().setPointingHandCursor();
    }
    Q_INVOKABLE void restoreOverrideCursor() {
        PQCScriptsOther::get().restoreOverrideCursor();
    }
    Q_INVOKABLE bool showDesktopNotification(QString summary, QString txt) {
        return PQCScriptsOther::get().showDesktopNotification(summary, txt);
    }

    // QML convenience methods
    Q_INVOKABLE QStringList convertJSArrayToStringList(QVariant val) {
        return PQCScriptsOther::get().convertJSArrayToStringList(val);
    }

};
