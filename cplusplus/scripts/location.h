/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#ifndef PQLOCATION_H
#define PQLOCATION_H

#include <QObject>
#include <QtSql>
#include "../logger.h"

class PQLocation : public QObject {

    Q_OBJECT

public:
    static PQLocation& get() {
        static PQLocation instance;
        return instance;
    }
    ~PQLocation();

    void storeLocation(const QString path, const QPointF gps);

    Q_INVOKABLE QVariantList getImages(const int detailLevel);

    void processSummary();

private:
    PQLocation();

    QSqlDatabase db;
    bool dbIsTransaction;
    QTimer *dbCommitTimer;

};

#endif // PQLOCATION_H
