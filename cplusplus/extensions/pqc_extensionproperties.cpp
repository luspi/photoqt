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

#include <pqc_extensionproperties.h>
#include <pqc_filefoldermodelCPP.h>
#include <pqc_metadata_cpp.h>
#include <pqc_notify_cpp.h>
#include <QFileInfo>

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

    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentlyVisibleAreaChanged, this, [=](QRectF rect) {
        m_currentVisibleArea = rect;
        Q_EMIT currentVisibleAreaChanged();
    });
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentWindowSizeChanged, this, [=](QSize sze) {
        m_currentWindowSize = sze;
        Q_EMIT currentWindowSizeChanged();
    });


    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageResolutionChanged, this, [=](QSize sze) {
        m_currentImageResolution = sze;
        Q_EMIT currentImageResolutionChanged();
    });
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageRotationChanged, this, [=](int rot) {
        m_currentImageRotation = rot;
        Q_EMIT currentImageRotationChanged();
    });
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageScaleChanged, this, [=](double scale) {
        m_currentImageScale = scale;
        Q_EMIT currentImageScaleChanged();
    });


    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsAnimatedChanged, this, [=](bool val) {
        m_currentImageIsAnimated = val;
        Q_EMIT currentImageIsAnimatedChanged();
    });
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsArchiveChanged, this, [=](bool val) {
        m_currentImageIsArchive = val;
        Q_EMIT currentImageIsArchiveChanged();
    });
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsDocumentChanged, this, [=](bool val) {
        m_currentImageIsDocument = val;
        Q_EMIT currentImageIsDocumentChanged();
    });
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsMotionPhotoChanged, this, [=](bool val) {
        m_currentImageIsMotionPhoto = val;
        Q_EMIT currentImageIsMotionPhotoChanged();
    });
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsPhotoSphereChanged, this, [=](bool val) {
        m_currentImageIsPhotoSphere = val;
        Q_EMIT currentImageIsPhotoSphereChanged();
    });
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsVideoChanged, this, [=](bool val) {
        m_currentImageIsVideo = val;
        Q_EMIT currentImageIsVideoChanged();
    });


    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::insidePhotoSphereChanged, this, [=](bool val) {
        m_insidePhotoSphere = val;
        Q_EMIT insidePhotoSphereChanged();
    });
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::motionPhotoIsPlayingChanged, this, [=](bool val) {
        m_motionPhotoIsPlaying = val;
        Q_EMIT motionPhotoIsPlayingChanged();
    });
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::animatedImageIsPlayingChanged, this, [=](bool val) {
        m_animatedImageIsPlaying = val;
        Q_EMIT animatedImageIsPlayingChanged();
    });
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::barcodesAreDisplayedChanged, this, [=](bool val) {
        m_barcodesAreDisplayed = val;
        Q_EMIT barcodesAreDisplayedChanged();
    });
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::slideshowActiveChanged, this, [=](bool val) {
        m_slideshowActive = val;
        Q_EMIT slideshowActiveChanged();
    });

}
