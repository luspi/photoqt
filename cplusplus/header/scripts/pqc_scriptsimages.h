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

#ifndef PQCSCRIPTSIMAGES_H
#define PQCSCRIPTSIMAGES_H

#include <QObject>
#include <QMap>
#include <QQmlEngine>

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

    // check for what kind of image this is
    Q_INVOKABLE bool isMpvVideo(QString path);
    Q_INVOKABLE bool isQtVideo(QString path);
    Q_INVOKABLE bool isPDFDocument(QString path);
    Q_INVOKABLE bool isArchive(QString path);
    Q_INVOKABLE int isMotionPhoto(QString path);
    Q_INVOKABLE bool isPhotoSphere(QString path);
    Q_INVOKABLE bool isComicBook(QString path);
    Q_INVOKABLE bool isSVG(QString path);
    Q_INVOKABLE bool isNormalImage(QString path);

    // info about image
    Q_INVOKABLE QSize getCurrentImageResolution(QString filename);
    Q_INVOKABLE bool isItAnimated(QString filename);
    Q_INVOKABLE void loadHistogramData(QString filepath, int index);
    void _loadHistogramData(QString filepath, int index);
    Q_INVOKABLE bool supportsTransparency(QString path);
    void setSupportsTransparency(QString path, bool alpha);
    Q_INVOKABLE double getPixelDensity();

    // do with image
    Q_INVOKABLE QString loadImageAndConvertToBase64(QString filename);
    Q_INVOKABLE QString extractMotionPhoto(QString path);
    Q_INVOKABLE QVariantList getZXingData(QString path);
    Q_INVOKABLE bool extractFrameAndSave(QString path, int frameNumber);

    // archive/document methods
    Q_INVOKABLE QStringList listArchiveContent(QString path, bool insideFilenameOnly = false);
    Q_INVOKABLE int getNumberDocumentPages(QString path);
    Q_INVOKABLE int getDocumentPageCount(QString path);
    Q_INVOKABLE QString extractArchiveFileToTempLocation(QString path);
    Q_INVOKABLE QString extractDocumentPageToTempLocation(QString path);

    // icon and thumbnail methods
    Q_INVOKABLE QString getIconPathFromTheme(QString binary);
    Q_INVOKABLE void removeThumbnailFor(QString path);

    // video methods
    Q_INVOKABLE QString convertSecondsToPosition(int t);

private:
    PQCScriptsImages();

    QMap<QString,QVariantList> histogramCache;
    QMap<QString,QStringList> archiveContentCache;

    QMap<QString, bool> alphaChannels;

    double devicePixelRatioCached;
    qint64 devicePixelRatioCachedWhen;

Q_SIGNALS:
    void histogramDataLoaded(QVariantList data, int index);
    void histogramDataLoadedFailed(int index);

};

#endif
