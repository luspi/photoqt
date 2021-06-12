/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

 /* auto-generated using generatesettings.py */

#ifndef PQSHORTCUTS_H
#define PQSHORTCUTS_H

#include <QObject>
#include <QTimer>

#include "../logger.h"

class PQShortcuts : public QObject {

    Q_OBJECT

public:
    PQShortcuts(QObject *parent = 0);

    Q_INVOKABLE void setDefault();

    Q_INVOKABLE QStringList getCommandForShortcut(QString sh);
    Q_INVOKABLE QStringList getShortcutsForCommand(QString cmd);
    Q_INVOKABLE QVariantList getAllExternalShortcuts();
    Q_INVOKABLE void deleteAllExternalShortcuts();
    Q_INVOKABLE void setShortcut(QString cmd, QStringList shortcuts);

private slots:
    void readShortcuts();
    void saveShortcuts();

private:
    QTimer *saveShortcutsTimer;

    QMap<QString,QStringList> shortcuts;
    QMap<QString,QStringList> externalShortcuts;

signals:
    void aboutChanged();

};

#endif // PQSHORTCUTS_H
