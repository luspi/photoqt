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

#if __cplusplus >= 202002L
    connect(&PQCFileFolderModelCPP::get(), &PQCFileFolderModelCPP::currentFileChanged, this, [=, this]() {
#else
    connect(&PQCFileFolderModelCPP::get(), &PQCFileFolderModelCPP::currentFileChanged, this, [=]() {
#endif
        m_currentFile = PQCFileFolderModelCPP::get().getCurrentFile();
        Q_EMIT currentFileChanged();
        QString folder = QFileInfo(m_currentFile).absolutePath();
        if(folder != m_currentFolder) {
            m_currentFolder = folder;
            Q_EMIT currentFolderChanged();
        }
    });
#if __cplusplus >= 202002L
    connect(&PQCFileFolderModelCPP::get(), &PQCFileFolderModelCPP::entriesMainViewChanged, this, [=, this]() {
#else
    connect(&PQCFileFolderModelCPP::get(), &PQCFileFolderModelCPP::entriesMainViewChanged, this, [=]() {
#endif
        m_currentFileList = PQCFileFolderModelCPP::get().getEntriesMainView();
        Q_EMIT currentFileListChanged();
    });
#if __cplusplus >= 202002L
    connect(&PQCMetadataCPP::get(), &PQCMetadataCPP::metadataUpdatedMap, this, [=, this](const QVariantMap dat) {
#else
    connect(&PQCMetadataCPP::get(), &PQCMetadataCPP::metadataUpdatedMap, this, [=](const QVariantMap dat) {
#endif
        m_currentMetadata = dat;
        Q_EMIT currentMetadataChanged();
    });

#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentlyVisibleAreaChanged, this, [=, this](QRectF rect) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentlyVisibleAreaChanged, this, [=](QRectF rect) {
#endif
        m_currentVisibleArea = rect;
        Q_EMIT currentVisibleAreaChanged();
    });
#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentWindowSizeChanged, this, [=, this](QSize sze) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentWindowSizeChanged, this, [=](QSize sze) {
#endif
        m_currentWindowSize = sze;
        Q_EMIT currentWindowSizeChanged();
    });


#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageResolutionChanged, this, [=, this](QSize sze) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageResolutionChanged, this, [=](QSize sze) {
#endif
        m_currentImageResolution = sze;
        Q_EMIT currentImageResolutionChanged();
    });
#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageRotationChanged, this, [=, this](int rot) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageRotationChanged, this, [=](int rot) {
#endif
        m_currentImageRotation = rot;
        Q_EMIT currentImageRotationChanged();
    });
#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageScaleChanged, this, [=, this](double scale) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageScaleChanged, this, [=](double scale) {
#endif
        m_currentImageScale = scale;
        Q_EMIT currentImageScaleChanged();
    });

#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsAnimatedChanged, this, [=, this](bool val) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsAnimatedChanged, this, [=](bool val) {
#endif
        m_currentImageIsAnimated = val;
        Q_EMIT currentImageIsAnimatedChanged();
    });
#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsArchiveChanged, this, [=, this](bool val) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsArchiveChanged, this, [=](bool val) {
#endif
        m_currentImageIsArchive = val;
        Q_EMIT currentImageIsArchiveChanged();
    });
#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsDocumentChanged, this, [=, this](bool val) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsDocumentChanged, this, [=](bool val) {
#endif
        m_currentImageIsDocument = val;
        Q_EMIT currentImageIsDocumentChanged();
    });
#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsMotionPhotoChanged, this, [=, this](bool val) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsMotionPhotoChanged, this, [=](bool val) {
#endif
        m_currentImageIsMotionPhoto = val;
        Q_EMIT currentImageIsMotionPhotoChanged();
    });
#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsPhotoSphereChanged, this, [=, this](bool val) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsPhotoSphereChanged, this, [=](bool val) {
#endif
        m_currentImageIsPhotoSphere = val;
        Q_EMIT currentImageIsPhotoSphereChanged();
    });
#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsVideoChanged, this, [=, this](bool val) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::currentImageIsVideoChanged, this, [=](bool val) {
#endif
        m_currentImageIsVideo = val;
        Q_EMIT currentImageIsVideoChanged();
    });

#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::insidePhotoSphereChanged, this, [=, this](bool val) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::insidePhotoSphereChanged, this, [=](bool val) {
#endif
        m_insidePhotoSphere = val;
        Q_EMIT insidePhotoSphereChanged();
    });
#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::motionPhotoIsPlayingChanged, this, [=, this](bool val) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::motionPhotoIsPlayingChanged, this, [=](bool val) {
#endif
        m_motionPhotoIsPlaying = val;
        Q_EMIT motionPhotoIsPlayingChanged();
    });
#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::animatedImageIsPlayingChanged, this, [=, this](bool val) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::animatedImageIsPlayingChanged, this, [=](bool val) {
#endif
        m_animatedImageIsPlaying = val;
        Q_EMIT animatedImageIsPlayingChanged();
    });
#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::barcodesAreDisplayedChanged, this, [=, this](bool val) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::barcodesAreDisplayedChanged, this, [=](bool val) {
#endif
        m_barcodesAreDisplayed = val;
        Q_EMIT barcodesAreDisplayedChanged();
    });
#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::slideshowActiveChanged, this, [=, this](bool val) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::slideshowActiveChanged, this, [=](bool val) {
#endif
        m_slideshowActive = val;
        Q_EMIT slideshowActiveChanged();
    });

}
