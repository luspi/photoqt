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

#ifndef PQCLOCATION_H
#define PQCLOCATION_H

#include <QObject>
#include <QSqlDatabase>
#include <QPointF>
#include <QVariantMap>
#include <QQmlEngine>

class QTimer;

class PQCLocation : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCLocation(QObject *parent = nullptr);

    Q_INVOKABLE void storeLocation(const QString path, const QPointF gps);
    Q_INVOKABLE void scanForLocations(QStringList files);
    Q_INVOKABLE void processSummary(QString folder);

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

    Q_PROPERTY(QVariantList allImages READ getAllImages WRITE setAllImages NOTIFY allImagesChanged)
    QVariantList getAllImages() { return m_allImages; }
    void setAllImages(QVariantList lst) {
        if(lst != m_allImages) {
            m_allImages = lst;
            Q_EMIT allImagesChanged();
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

    Q_PROPERTY(QPointF minimumLocation READ getMinimumLocation NOTIFY minimumLocationChanged)
    QPointF getMinimumLocation() { return m_minimumLocation; }
    Q_PROPERTY(QPointF maximumLocation READ getMaximumLocation NOTIFY maximumLocationChanged)
    QPointF getMaximumLocation() { return m_maximumLocation; }

    Q_INVOKABLE void closeDatabase();

private:
    QSqlDatabase db;
    bool dbOpened;
    bool dbIsTransaction;
    QTimer *dbCommitTimer;

    QVariantList m_allImages;
    QVariantMap m_imageList;
    QVariantMap m_labelList;
    bool m_includeSubfolder;
    QPointF m_minimumLocation;
    QPointF m_maximumLocation;

    QList<QList<double> > steps;

Q_SIGNALS:
    void imageListChanged();
    void labelListChanged();
    void allImagesChanged();
    void includeSubfolderChanged();
    void minimumLocationChanged();
    void maximumLocationChanged();

};

#endif // PQCLOCATION_H
