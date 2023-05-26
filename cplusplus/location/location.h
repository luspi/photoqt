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


    Q_PROPERTY(QVariantMap imageList READ getImageList WRITE setImageList NOTIFY imageListChanged)
    QVariantMap getImageList() { return m_imageList; }
    void setImageList(QVariantMap lst) {
        if(lst != m_imageList) {
            m_imageList = lst;
            Q_EMIT imageListChanged();
        }
    }

    Q_PROPERTY(QVariantMap labelList READ getLabelList WRITE setLabelList NOTIFY labelListChanged)
    QVariantMap getLabelList() { return m_labelList; }
    void setLabelList(QVariantMap lst) {
        if(lst != m_labelList) {
            m_labelList = lst;
            Q_EMIT labelListChanged();
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
    void labelListChanged();
    void includeSubfolderChanged();

private:
    PQLocation();

    QVariantMap m_imageList;
    QVariantMap m_labelList;
    bool m_includeSubfolder;

    QSqlDatabase db;
    bool dbIsTransaction;
    QTimer *dbCommitTimer;

    QList<QList<double> > steps;

};

#endif // PQLOCATION_H
