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
#include <QQmlEngine>
#include <QRectF>

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

    // image properties
    Q_PROPERTY(QSize currentImageResolution MEMBER m_currentImageResolution NOTIFY currentImageResolutionChanged)
    Q_PROPERTY(int currentImageRotation MEMBER m_currentImageRotation NOTIFY currentImageRotationChanged)
    Q_PROPERTY(double currentImageScale MEMBER m_currentImageScale NOTIFY currentImageScaleChanged)

    // viewing properties
    Q_PROPERTY(bool currentImageIsVideo MEMBER m_currentImageIsVideo NOTIFY currentImageIsVideoChanged)
    Q_PROPERTY(bool currentImageIsPhotoSphere MEMBER m_currentImageIsPhotoSphere NOTIFY currentImageIsPhotoSphereChanged)
    Q_PROPERTY(bool currentImageIsMotionPhoto MEMBER m_currentImageIsMotionPhoto NOTIFY currentImageIsMotionPhotoChanged)
    Q_PROPERTY(bool currentImageIsAnimated MEMBER m_currentImageIsAnimated NOTIFY currentImageIsAnimatedChanged)
    Q_PROPERTY(bool currentImageIsDocument MEMBER m_currentImageIsDocument NOTIFY currentImageIsDocumentChanged)
    Q_PROPERTY(bool currentImageIsArchive MEMBER m_currentImageIsArchive NOTIFY currentImageIsArchiveChanged)

    Q_PROPERTY(bool insidePhotoSphere MEMBER m_insidePhotoSphere NOTIFY insidePhotoSphereChanged)
    Q_PROPERTY(bool motionPhotoIsPlaying MEMBER m_motionPhotoIsPlaying NOTIFY motionPhotoIsPlayingChanged)
    Q_PROPERTY(bool animatedImageIsPlaying MEMBER m_animatedImageIsPlaying NOTIFY animatedImageIsPlayingChanged)
    Q_PROPERTY(bool barcodesAreDisplayed MEMBER m_barcodesAreDisplayed NOTIFY barcodesAreDisplayedChanged)
    Q_PROPERTY(bool slideshowActive MEMBER m_slideshowActive NOTIFY slideshowActiveChanged)

    // visible properties
    Q_PROPERTY(QRectF currentVisibleArea MEMBER m_currentVisibleArea NOTIFY currentVisibleAreaChanged)
    Q_PROPERTY(QSize currentWindowSize MEMBER m_currentWindowSize NOTIFY currentWindowSizeChanged)

    // properties regarding the currently loaded folder
    Q_PROPERTY(QStringList currentFileList MEMBER m_currentFileList NOTIFY currentFileListChanged)

    /*******************************************/
    // no-op to ensure this class is setup
    Q_INVOKABLE void setup() {}

private:
    QString m_currentFile;
    QString m_currentFolder;
    QVariantMap m_currentMetadata;

    QSize m_currentImageResolution;
    int m_currentImageRotation;
    double m_currentImageScale;

    bool m_currentImageIsVideo;
    bool m_currentImageIsPhotoSphere;
    bool m_currentImageIsMotionPhoto;
    bool m_currentImageIsAnimated;
    bool m_currentImageIsDocument;
    bool m_currentImageIsArchive;

    bool m_insidePhotoSphere;
    bool m_motionPhotoIsPlaying;
    bool m_animatedImageIsPlaying;
    bool m_barcodesAreDisplayed;
    bool m_slideshowActive;

    QRectF m_currentVisibleArea;
    QSize m_currentWindowSize;

    QStringList m_currentFileList;

Q_SIGNALS:
    void currentFileChanged();
    void currentFolderChanged();
    void currentMetadataChanged();
    void currentImageResolutionChanged();
    void currentImageRotationChanged();
    void currentImageScaleChanged();
    void currentImageIsVideoChanged();
    void currentImageIsPhotoSphereChanged();
    void currentImageIsMotionPhotoChanged();
    void currentImageIsAnimatedChanged();
    void currentImageIsDocumentChanged();
    void currentImageIsArchiveChanged();
    void insidePhotoSphereChanged();
    void motionPhotoIsPlayingChanged();
    void animatedImageIsPlayingChanged();
    void barcodesAreDisplayedChanged();
    void slideshowActiveChanged();
    void currentVisibleAreaChanged();
    void currentWindowSizeChanged();
    void currentFileListChanged();

};
