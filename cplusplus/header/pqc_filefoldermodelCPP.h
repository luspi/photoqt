/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
#pragma once

#include <QObject>

class PQCFileFolderModelCPP : public QObject {

    Q_OBJECT

public:
    static PQCFileFolderModelCPP& get() {
        static PQCFileFolderModelCPP instance;
        return instance;
    }

    PQCFileFolderModelCPP(PQCFileFolderModelCPP const&)     = delete;
    void operator=(PQCFileFolderModelCPP const&) = delete;

    // currentIndex -> set from PQCFileFolderModel
    void setCurrentIndex(int index) {
        if(index != m_currentIndex) {
            m_currentIndex = index;
            Q_EMIT currentIndexChanged();
        }
    }
    int getCurrentIndex() { return m_currentIndex; }

    // currentFile -> set from PQCFileFolderModel
    void setCurrentFile(QString path) {
        if(path != m_currentFile) {
            m_currentFile = path;
            Q_EMIT currentFileChanged();
        }
    }
    QString getCurrentFile() { return m_currentFile; }

    // countMainView -> set from PQCFileFolderModel
    void setCountMainView(int count) {
        if(count != m_countMainView) {
            m_countMainView = count;
            Q_EMIT countMainViewChanged();
        }
    }
    int getCountMainView() { return m_countMainView; }

    // entriesMainView -> set from PQCFileFolderModel
    void setEntriesMainView(QStringList lst) {
        if(lst != m_entriesMainView) {
            m_entriesMainView = lst;
            Q_EMIT entriesMainViewChanged();
        }
    }
    QStringList getEntriesMainView() { return m_entriesMainView; }

private:
    PQCFileFolderModelCPP(QObject *parent = 0) : QObject(parent) {
        m_currentIndex = -1;
        m_currentFile = "";
        m_countMainView = 0;
        m_entriesMainView.clear();
    }

    int         m_currentIndex;
    QString     m_currentFile;
    int         m_countMainView;
    QStringList m_entriesMainView;

Q_SIGNALS:
    void currentIndexChanged();
    void currentFileChanged();
    void countMainViewChanged();
    void entriesMainViewChanged();

    // these are picked up in PQCFileFolderModel
    void setFileInFolderMainView(QString val);

};
