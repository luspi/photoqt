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

#ifndef PQCSCRIPTSUNDO_H
#define PQCSCRIPTSUNDO_H

#include <QObject>
#include <QtQmlIntegration>

class PQCScriptsUndo : public QObject {

    Q_OBJECT
    QML_SINGLETON

public:
    static PQCScriptsUndo& get() {
        static PQCScriptsUndo instance;
        return instance;
    }
    ~PQCScriptsUndo();

    PQCScriptsUndo(PQCScriptsUndo const&)     = delete;
    void operator=(PQCScriptsUndo const&) = delete;

    Q_INVOKABLE void recordAction(QString actions, QVariantList args);
    Q_INVOKABLE QString undoLastAction(QString action);

private Q_SLOTS:
    void clearActions();

private:
    PQCScriptsUndo();

    QString curFolder;
    QList<QVariantList> trash;

};

#endif
