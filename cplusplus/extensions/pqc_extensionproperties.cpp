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

#include <pqc_extensionproperties.h>

PQCExtensionProperties::PQCExtensionProperties(QObject *parent) : QObject(parent) {

    m_currentFile = PQCFileFolderModelCPP::get().getCurrentFile();
    m_currentFolder = QFileInfo(m_currentFile).absolutePath();
    m_currentFileList = PQCFileFolderModelCPP::get().getEntriesMainView();

    connect(&PQCFileFolderModelCPP::get(), &PQCFileFolderModelCPP::currentFileChanged, this, [=]() {
        m_currentFile = PQCFileFolderModelCPP::get().getCurrentFile();
        Q_EMIT currentFileChanged();
        QString folder = QFileInfo(m_currentFile).absolutePath();
        if(folder != m_currentFolder) {
            m_currentFolder = folder;
            Q_EMIT currentFolderChanged();
        }
    });
    connect(&PQCFileFolderModelCPP::get(), &PQCFileFolderModelCPP::entriesMainViewChanged, this, [=]() {
        m_currentFileList = PQCFileFolderModelCPP::get().getEntriesMainView();
        Q_EMIT currentFileListChanged();
    });
    connect(&PQCMetadataCPP::get(), &PQCMetadataCPP::metadataUpdatedMap, this, [=](const QVariantMap dat) {
        m_currentMetadata = dat;
        Q_EMIT currentMetadataChanged();
    });

}
