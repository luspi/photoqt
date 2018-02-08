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

#ifndef THUMBNAILSMANAGEMENT_H
#define THUMBNAILSMANAGEMENT_H

#include "../logger.h"
#include <QObject>
#include <QFileInfo>
#include <QDir>
#include <QtSql>
#include <iostream>

class ThumbnailManagement : public QObject {

    Q_OBJECT

public:
    ThumbnailManagement(QObject *parent = 0);

    Q_INVOKABLE qint64 getDatabaseFilesize();

    Q_INVOKABLE int getNumberDatabaseEntries();

    Q_INVOKABLE void cleanDatabase();
    Q_INVOKABLE void eraseDatabase();

private:
    QSqlDatabase db;

};


#endif // THUMBNAILSMANAGEMENT_H
