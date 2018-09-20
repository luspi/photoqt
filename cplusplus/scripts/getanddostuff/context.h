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

#ifndef GETANDDOSTUFFCONTEXT_H
#define GETANDDOSTUFFCONTEXT_H

#include "../../logger.h"
#include <QObject>
#include <QStringList>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QVariant>
#include <QDir>
#include <QProcess>
#include <QDateTime>

class GetAndDoStuffContext : public QObject {

    Q_OBJECT

public:
    explicit GetAndDoStuffContext(QObject *parent = nullptr);
    ~GetAndDoStuffContext();

    QStringList getDefaultContextMenuEntries();
    QStringList getContextMenu();
    void saveContextMenu(QVariantList m);
    bool checkIfBinaryExists(QString exec);

};


#endif // GETANDDOSTUFFCONTEXT_H
