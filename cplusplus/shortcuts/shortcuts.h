/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

#ifndef SHORTCUTS_H
#define SHORTCUTS_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QKeySequence>

#include "../configfiles.h"
#include "../logger.h"

class Shortcuts : public QObject {

    Q_OBJECT

public:
    Shortcuts(QObject *parent = 0);
    Q_INVOKABLE QVariantList load();
    Q_INVOKABLE QVariantList loadDefaults();
    Q_INVOKABLE void saveShortcuts(QVariantList data);
    Q_INVOKABLE QString convertKeycodeToString(int code);

};

#endif
