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
#include <qml/pqc_scriptsshortcuts.h>

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton is a wrapper for the C++ class
//            This class here can ONLY be used from QML!
//
/*************************************************************/
/*************************************************************/

class PQCScriptsShortcutsQML : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(PQCScriptsShortcuts)

public:
    PQCScriptsShortcutsQML() {
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutShowGlobalContextMenuAt,
                this, &PQCScriptsShortcutsQML::sendShortcutShowGlobalContextMenuAt);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutShowGlobalContextMenuAt,
                this, &PQCScriptsShortcutsQML::sendShortcutShowGlobalContextMenuAt);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutDismissGlobalContextMenu,
                this, &PQCScriptsShortcutsQML::sendShortcutDismissGlobalContextMenu);

        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::executeInternalCommand,
                this, &PQCScriptsShortcutsQML::executeInternalCommand);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::executeInternalCommandWithMousePos,
                this, &PQCScriptsShortcutsQML::executeInternalCommandWithMousePos);

        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutShowNextImage,
                this, &PQCScriptsShortcutsQML::sendShortcutShowNextImage);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutShowPrevImage,
                this, &PQCScriptsShortcutsQML::sendShortcutShowPrevImage);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutShowNextArcDocImage,
                this, &PQCScriptsShortcutsQML::sendShortcutShowNextArcDocImage);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutShowPrevArcDocImage,
                this, &PQCScriptsShortcutsQML::sendShortcutShowPrevArcDocImage);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutShowFirstImage,
                this, &PQCScriptsShortcutsQML::sendShortcutShowFirstImage);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutShowLastImage,
                this, &PQCScriptsShortcutsQML::sendShortcutShowLastImage);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutShowRandomImage,
                this, &PQCScriptsShortcutsQML::sendShortcutShowRandomImage);

        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutZoomIn,
                this, &PQCScriptsShortcutsQML::sendShortcutZoomIn);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutZoomOut,
                this, &PQCScriptsShortcutsQML::sendShortcutZoomOut);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutZoomReset,
                this, &PQCScriptsShortcutsQML::sendShortcutZoomReset);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutZoomActual,
                this, &PQCScriptsShortcutsQML::sendShortcutZoomActual);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutZoomKenBurns,
                this, &PQCScriptsShortcutsQML::sendShortcutZoomKenBurns);

        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutRotateClock,
                this, &PQCScriptsShortcutsQML::sendShortcutRotateClock);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutRotateAntiClock,
                this, &PQCScriptsShortcutsQML::sendShortcutRotateAntiClock);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutRotateReset,
                this, &PQCScriptsShortcutsQML::sendShortcutRotateReset);

        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutMirrorHorizontal,
                this, &PQCScriptsShortcutsQML::sendShortcutMirrorHorizontal);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutMirrorVertical,
                this, &PQCScriptsShortcutsQML::sendShortcutMirrorVertical);
        connect(&PQCScriptsShortcuts::get(), &PQCScriptsShortcuts::sendShortcutMirrorReset,
                this, &PQCScriptsShortcutsQML::sendShortcutMirrorReset);

    }

    Q_INVOKABLE void executeExternal(QString exe, QString args, QString currentfile) {
        PQCScriptsShortcuts::get().executeExternal(exe, args, currentfile);
    }

    Q_INVOKABLE QStringList analyzeModifier(Qt::KeyboardModifiers mods) {
        return PQCScriptsShortcuts::get().analyzeModifier(mods);
    }
    Q_INVOKABLE QString analyzeMouseWheel(QPoint angleDelta) {
        return PQCScriptsShortcuts::get().analyzeMouseWheel(angleDelta);
    }
    Q_INVOKABLE QString analyzeMouseButton(Qt::MouseButton button) {
        return PQCScriptsShortcuts::get().analyzeMouseButton(button);
    }
    Q_INVOKABLE QString analyzeMouseDirection(QPoint prevPoint, QPoint curPoint) {
        return PQCScriptsShortcuts::get().analyzeMouseDirection(prevPoint, curPoint);
    }
    Q_INVOKABLE QString analyzeKeyPress(Qt::Key key) {
        return PQCScriptsShortcuts::get().analyzeKeyPress(key);
    }

    Q_INVOKABLE void setCurrentTimestamp() {
        PQCScriptsShortcuts::get().setCurrentTimestamp();
    }
    Q_INVOKABLE int getCurrentTimestampDiffLessThan(int threshold) {
        return PQCScriptsShortcuts::get().getCurrentTimestampDiffLessThan(threshold);
    }

    Q_INVOKABLE QString translateShortcut(QString combo) {
        return PQCScriptsShortcuts::get().translateShortcut(combo);
    }
    Q_INVOKABLE QString translateMouseDirection(QStringList combo) {
        return PQCScriptsShortcuts::get().translateMouseDirection(combo);
    }

Q_SIGNALS:

    void sendShortcutShowGlobalContextMenuAt(QPoint pos);
    void sendShortcutDismissGlobalContextMenu();

    void executeInternalCommand(QString cmd);
    void executeInternalCommandWithMousePos(QString cmd, QPoint pos);

    void sendShortcutShowNextImage();
    void sendShortcutShowPrevImage();
    void sendShortcutShowNextArcDocImage();
    void sendShortcutShowPrevArcDocImage();
    void sendShortcutShowFirstImage();
    void sendShortcutShowLastImage();
    void sendShortcutShowRandomImage();

    void sendShortcutZoomIn(QPoint mousePos, QPoint wheelDelta);
    void sendShortcutZoomOut(QPoint mousePos, QPoint wheelDelta);
    void sendShortcutZoomReset();
    void sendShortcutZoomActual();
    void sendShortcutZoomKenBurns();

    void sendShortcutRotateClock();
    void sendShortcutRotateAntiClock();
    void sendShortcutRotateReset();

    void sendShortcutMirrorHorizontal();
    void sendShortcutMirrorVertical();
    void sendShortcutMirrorReset();

};
