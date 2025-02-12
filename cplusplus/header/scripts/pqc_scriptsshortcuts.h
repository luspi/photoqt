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

class PQCScriptsShortcuts : public QObject {

    Q_OBJECT
    QML_SINGLETON

public:
    static PQCScriptsShortcuts& get() {
        static PQCScriptsShortcuts instance;
        return instance;
    }
    ~PQCScriptsShortcuts();

    PQCScriptsShortcuts(PQCScriptsShortcuts const&)     = delete;
    void operator=(PQCScriptsShortcuts const&) = delete;

    Q_INVOKABLE void executeExternal(QString exe, QString args, QString currentfile);

    Q_INVOKABLE QStringList analyzeModifier(Qt::KeyboardModifiers mods);
    Q_INVOKABLE QString analyzeMouseWheel(QPoint angleDelta);
    Q_INVOKABLE QString analyzeMouseButton(Qt::MouseButton button);
    Q_INVOKABLE QString analyzeMouseDirection(QPoint prevPoint, QPoint curPoint);
    Q_INVOKABLE QString analyzeKeyPress(Qt::Key key);

private:
    PQCScriptsShortcuts();

};

#endif
