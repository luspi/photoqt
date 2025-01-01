/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

#ifndef PQCSCRIPTSIMAGES_H
#define PQCSCRIPTSIMAGES_H

#include <QObject>
#include <QMap>
#include <QImage>
#include <QColorSpace>
#include <QtQmlIntegration>
#ifdef PQMLCMS2
#include <lcms2.h>
#endif

class QFile;

class PQCScriptsImages : public QObject {

    Q_OBJECT
    QML_SINGLETON

public:
    static PQCScriptsImages& get() {
        static PQCScriptsImages instance;
        return instance;
    }
    ~PQCScriptsImages();

    PQCScriptsImages(PQCScriptsImages const&)     = delete;
    void operator=(PQCScriptsImages const&) = delete;

    Q_INVOKABLE QSize getCurrentImageResolution(QString filename);
    Q_INVOKABLE bool isItAnimated(QString filename);
    Q_INVOKABLE QString getIconPathFromTheme(QString binary);
    Q_INVOKABLE QString loadImageAndConvertToBase64(QString filename);
    Q_INVOKABLE QStringList listArchiveContent(QString path, bool insideFilenameOnly = false);
    Q_INVOKABLE QString convertSecondsToPosition(int t);
    Q_INVOKABLE void loadHistogramData(QString filepath, int index);
    void _loadHistogramData(QString filepath, int index);

    Q_INVOKABLE bool isMpvVideo(QString path);
    Q_INVOKABLE bool isQtVideo(QString path);
    Q_INVOKABLE bool isPDFDocument(QString path);
    Q_INVOKABLE bool isArchive(QString path);
    Q_INVOKABLE int getNumberDocumentPages(QString path);
    Q_INVOKABLE int isMotionPhoto(QString path);
    Q_INVOKABLE bool isPhotoSphere(QString path);
    Q_INVOKABLE bool isComicBook(QString path);
    Q_INVOKABLE bool isSVG(QString path);
    Q_INVOKABLE bool isNormalImage(QString path);

    Q_INVOKABLE int getDocumentPageCount(QString path);

    Q_INVOKABLE QString extractMotionPhoto(QString path);
    Q_INVOKABLE QVariantList getZXingData(QString path);

    Q_INVOKABLE QString extractArchiveFileToTempLocation(QString path);
    Q_INVOKABLE QString extractDocumentPageToTempLocation(QString path);
    Q_INVOKABLE bool extractFrameAndSave(QString path, int frameNumber);

    Q_INVOKABLE bool supportsTransparency(QString path);
    void setSupportsTransparency(QString path, bool alpha);

    QList<QColorSpace::NamedColorSpace> getIntegratedColorProfiles();
    QStringList getExternalColorProfiles();
    QStringList getExternalColorProfileDescriptions();
    Q_INVOKABLE QStringList getImportedColorProfiles();
    QStringList getImportedColorProfileDescriptions();
    Q_INVOKABLE QStringList getColorProfiles();
    Q_INVOKABLE QStringList getColorProfileDescriptions();
    Q_INVOKABLE QString getColorProfileID(int index);
    Q_INVOKABLE void setColorProfile(QString path, int index);
    Q_INVOKABLE QString getColorProfileFor(QString path);
    Q_INVOKABLE QString getDescriptionForColorSpace(QString path);
    Q_INVOKABLE int getIndexForColorProfile(QString desc);
    Q_INVOKABLE bool importColorProfile();
    Q_INVOKABLE bool removeImportedColorProfile(int index);
    Q_INVOKABLE QString detectVideoColorProfile(QString path);
    void loadColorProfileInfo();
    bool applyColorProfile(QString filename, QImage &img);

    Q_INVOKABLE void removeThumbnailFor(QString path);

    Q_INVOKABLE double getPixelDensity();

#ifdef PQMLCMS2
    int toLcmsFormat(QImage::Format fmt);
#endif

private:
    PQCScriptsImages();

    int lcms2CountFailedApplications;

    QMap<QString,QVariantList> histogramCache;
    QMap<QString,QStringList> archiveContentCache;

    QMap<QString, bool> alphaChannels;

    QList<QColorSpace::NamedColorSpace> integratedColorProfiles;
    QStringList integratedColorProfileDescriptions;
    QStringList externalColorProfiles;
    QStringList externalColorProfileDescriptions;
    QStringList importedColorProfiles;
    QStringList importedColorProfileDescriptions;
    QMap<QString, QString> iccColorProfiles;

    qint64 importedICCLastMod;

    QFile *colorlastlocation;

    bool applyColorSpaceQt(QImage &img, QString filename, QColorSpace sp);
#ifdef PQMLCMS2
    bool applyColorSpaceLCMS2(QImage &img, QString filename, cmsHPROFILE targetProfile);
#endif

    double devicePixelRatioCached;
    qint64 devicePixelRatioCachedWhen;

Q_SIGNALS:
    void histogramDataLoaded(QVariantList data, int index);
    void histogramDataLoadedFailed(int index);

};

#endif
