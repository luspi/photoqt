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
#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QFileInfo>
#include <pqc_filefoldermodelCPP.h>
#include <pqc_metadata_cpp.h>

class PQCExtensionProperties : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCExtensionProperties(QObject *parent = 0);

    // properties regarding the currently loaded file
    Q_PROPERTY(QString currentFile MEMBER m_currentFile NOTIFY currentFileChanged)
    Q_PROPERTY(QString currentFolder MEMBER m_currentFolder NOTIFY currentFolderChanged)
    Q_PROPERTY(QVariantMap currentMetadata MEMBER m_currentMetadata NOTIFY currentMetadataChanged)

    // properties regarding the currently loaded folder
    Q_PROPERTY(QStringList currentFileList MEMBER m_currentFileList NOTIFY currentFileListChanged)

private:
    QString m_currentFile;
    QString m_currentFolder;
    QStringList m_currentFileList;
    QVariantMap m_currentMetadata;

Q_SIGNALS:
    void currentFileChanged();
    void currentFolderChanged();
    void currentFileListChanged();
    void currentMetadataChanged();

};
