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

    Q_INVOKABLE void storeMapState(const double zoomlevel, const double latitude, const double longitude);
    Q_INVOKABLE QVariantList getMapState();


    Q_PROPERTY(QVariantList imageList READ getImageList WRITE setImageList NOTIFY imageListChanged)
    QVariantList getImageList() { return m_imageList[m_detailLevel]; }
    void setImageList(QVariantList lst) {
        if(lst != m_imageList[m_detailLevel]) {
            m_imageList[m_detailLevel] = lst;
            Q_EMIT imageListChanged();
        }
    }

    Q_PROPERTY(int detailLevel READ getDetailLevel WRITE setDetailLevel NOTIFY detailLevelChanged)
    int getDetailLevel() { return m_detailLevel; }
    void setDetailLevel(int det) {
        if(det != m_detailLevel) {
            m_detailLevel = det;
            Q_EMIT detailLevelChanged();
        }
    }

    Q_PROPERTY(bool includeSubfolder READ getIncludeSubfolder WRITE setIncludeSubfolder NOTIFY includeSubfolderChanged)
    bool getIncludeSubfolder() { return m_includeSubfolder; }
    void setIncludeSubfolder(bool sub) {
        if(sub != m_includeSubfolder) {
            m_includeSubfolder = sub;;
            Q_EMIT includeSubfolderChanged();
        }
    }

    Q_INVOKABLE void scanForLocations(QStringList files);
    Q_INVOKABLE void processSummary(QString folder);


Q_SIGNALS:
    void imageListChanged();
    void detailLevelChanged();
    void includeSubfolderChanged();

private:
    PQLocation();

    QList<QVariantList> m_imageList;
    int m_detailLevel;
    bool m_includeSubfolder;

    QSqlDatabase db;
    bool dbIsTransaction;
    QTimer *dbCommitTimer;

};

#endif // PQLOCATION_H
