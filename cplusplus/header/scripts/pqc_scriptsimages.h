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

/*************************************************************/
/*************************************************************/
//
// this class is used in both C++ and QML code
// thus there is a WRAPPER for QML available
//
/*************************************************************/
/*************************************************************/

#include <QMutex>
class QFile;

class PQCScriptsImages : public QObject {

    Q_OBJECT

public:
    static PQCScriptsImages& get();
    virtual ~PQCScriptsImages();

    PQCScriptsImages(PQCScriptsImages const&)     = delete;
    void operator=(PQCScriptsImages const&) = delete;

    // check for what kind of image this is
    bool isMpvVideo(QString path);
    bool isQtVideo(QString path);
    bool isPDFDocument(QString path);
    bool isArchive(QString path);
    int isMotionPhoto(QString path);
    bool isPhotoSphere(QString path);
    bool isComicBook(QString path);
    bool isSVG(QString path);
    bool isNormalImage(QString path);

    // info about image
    QSize getCurrentImageResolution(QString filename);
    bool isItAnimated(QString filename);
    bool supportsTransparency(QString path);
    void setSupportsTransparency(QString path, bool alpha);
    double getPixelDensity();
    QString getNameFromMimetype(QString mimetype, QString filename);
    QString getMimetypeForFile(QString path);

    // do with image
    QString loadImageAndConvertToBase64(QString filename);
    QString extractMotionPhoto(QString path);
    QVariantList getZXingData(QString path);
    bool extractFrameAndSave(QString path, int frameNumber);

    // archive/document methods
    void listArchiveContent(QString path, bool insideFilenameOnly = false);
    QStringList listArchiveContentWithoutThread(QString path, QString cacheKey = "", bool insideFilenameOnly = false);
    int getNumberDocumentPages(QString path);
    int getDocumentPageCount(QString path);
    QString extractArchiveFileToTempLocation(QString path);
    QString extractDocumentPageToTempLocation(QString path);

    // icon and thumbnail methods
    QString getIconPathFromTheme(QString binary);
    void removeThumbnailFor(QString path);

    // video methods
    QString convertSecondsToPosition(int t);

private:
    PQCScriptsImages();

    mutable QMutex archiveMutex;
    QMap<QString,QStringList> archiveContentCache;

    mutable QMutex alphaMutex;
    QMap<QString, bool> alphaChannels;

    double devicePixelRatioCached;
    qint64 devicePixelRatioCachedWhen;


Q_SIGNALS:
    void haveArchiveContentFor(QString filename, QStringList content);

};

#endif
