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
#include <QHash>

class PQCScriptsShortcuts : public QObject {

    Q_OBJECT

public:
    static PQCScriptsShortcuts& get() {
        static PQCScriptsShortcuts instance;
        return instance;
    }

    PQCScriptsShortcuts(PQCScriptsShortcuts const&)     = delete;
    void operator=(PQCScriptsShortcuts const&) = delete;

    void executeExternal(QString exe, QString args, QString currentfile);

    QStringList analyzeModifier(Qt::KeyboardModifiers mods);
    QString analyzeMouseWheel(QPoint angleDelta);
    QString analyzeMouseButton(Qt::MouseButton button);
    QString analyzeMouseDirection(QPoint prevPoint, QPoint curPoint);
    QString analyzeKeyPress(Qt::Key key);

    void setCurrentTimestamp();
    int getCurrentTimestampDiffLessThan(int threshold);

    QString translateShortcut(QString combo);
    QString translateMouseDirection(QStringList combo);

private:
    PQCScriptsShortcuts();
    ~PQCScriptsShortcuts();

    qint64 m_lastInternalShortcutExecuted;

    QHash<QString,QString> m_keyStrings;
    QHash<QString,QString> m_mouseStrings;

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
    void sendShortcutShowFile(QString path);

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
