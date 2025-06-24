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

#ifndef PQCSCRIPTSSHORTCUTS_H
#define PQCSCRIPTSSHORTCUTS_H

#include <QObject>
#include <QMap>
#include <QtQmlIntegration>

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton CANNOT be used from C++.
//            It can ONLY be used from QML.
//
/*************************************************************/
/*************************************************************/

class PQCScriptsShortcuts : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCScriptsShortcuts();
    ~PQCScriptsShortcuts();

    Q_INVOKABLE void executeExternal(QString exe, QString args, QString currentfile);

    Q_INVOKABLE QStringList analyzeModifier(Qt::KeyboardModifiers mods);
    Q_INVOKABLE QString analyzeMouseWheel(QPoint angleDelta);
    Q_INVOKABLE QString analyzeMouseButton(Qt::MouseButton button);
    Q_INVOKABLE QString analyzeMouseDirection(QPoint prevPoint, QPoint curPoint);
    Q_INVOKABLE QString analyzeKeyPress(Qt::Key key);

    Q_INVOKABLE void setCurrentTimestamp();
    Q_INVOKABLE int getCurrentTimestampDiffLessThan(int threshold);

    Q_INVOKABLE QString translateShortcut(QString combo);
    Q_INVOKABLE QString translateMouseDirection(QStringList combo);

private:
    qint64 m_lastInternalShortcutExecuted;

    QHash<QString,QString> m_keyStrings;
    QHash<QString,QString> m_mouseStrings;

Q_SIGNALS:

    void sendShortcutShowGlobalContextMenuAt(QPoint pos);
    void sendShortcutDismissGlobalContextMenu();

    void sendShortcutShowNextImage();
    void sendShortcutShowPrevImage();
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

#endif
