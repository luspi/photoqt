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
#include <QSize>
#include <scripts/pqc_scriptsimages.h>

class QFile;

class PQCScriptsImagesQML : public QObject {

    Q_OBJECT
    QML_NAMED_ELEMENT(PQCScriptsImages)
    QML_SINGLETON

public:
    PQCScriptsImagesQML() {
        connect(&PQCScriptsImages::get(), &PQCScriptsImages::haveArchiveContentFor, this, &PQCScriptsImagesQML::haveArchiveContentFor);
    }
    ~PQCScriptsImagesQML() {}

    // check for what kind of image this is
    Q_INVOKABLE bool isMpvVideo(QString path)    { return PQCScriptsImages::get().isMpvVideo(path); }
    Q_INVOKABLE bool isQtVideo(QString path)     { return PQCScriptsImages::get().isQtVideo(path); }
    Q_INVOKABLE bool isPDFDocument(QString path) { return PQCScriptsImages::get().isPDFDocument(path); }
    Q_INVOKABLE bool isArchive(QString path)     { return PQCScriptsImages::get().isArchive(path); }
    Q_INVOKABLE int  isMotionPhoto(QString path) { return PQCScriptsImages::get().isMotionPhoto(path); }
    Q_INVOKABLE bool isPhotoSphere(QString path) { return PQCScriptsImages::get().isPhotoSphere(path); }
    Q_INVOKABLE bool isComicBook(QString path)   { return PQCScriptsImages::get().isComicBook(path); }
    Q_INVOKABLE bool isSVG(QString path)         { return PQCScriptsImages::get().isSVG(path); }
    Q_INVOKABLE bool isNormalImage(QString path) { return PQCScriptsImages::get().isNormalImage(path); }

    // info about image
    Q_INVOKABLE QSize   getCurrentImageResolution(QString filename)    { return PQCScriptsImages::get().getCurrentImageResolution(filename); }
    Q_INVOKABLE bool    isItAnimated(QString filename)                 { return PQCScriptsImages::get().isItAnimated(filename); }
    Q_INVOKABLE bool    supportsTransparency(QString path)             { return PQCScriptsImages::get().supportsTransparency(path); }
    Q_INVOKABLE double  getPixelDensity(QString modelName)             { return PQCScriptsImages::get().getPixelDensity(modelName); }
    Q_INVOKABLE QString getNameFromMimetype(QString mimetype, QString filename) { return PQCScriptsImages::get().getNameFromMimetype(mimetype, filename); }
    Q_INVOKABLE QString getMimetypeForFile(QString path)               { return PQCScriptsImages::get().getMimetypeForFile(path); }

    // do with image
    Q_INVOKABLE QString      loadImageAndConvertToBase64(QString filename)      { return PQCScriptsImages::get().loadImageAndConvertToBase64(filename); }
    Q_INVOKABLE QString      extractMotionPhoto(QString path)                   { return PQCScriptsImages::get().extractMotionPhoto(path); }
    Q_INVOKABLE QVariantList getZXingData(QString path)                         { return PQCScriptsImages::get().getZXingData(path); }
    Q_INVOKABLE bool         extractFrameAndSave(QString path, int frameNumber) { return PQCScriptsImages::get().extractFrameAndSave(path, frameNumber); }

    // archive/document methods
    Q_INVOKABLE void        listArchiveContent(QString path)                { PQCScriptsImages::get().listArchiveContent(path); }
    Q_INVOKABLE QStringList listArchiveContentWithoutThread(QString path)   { return PQCScriptsImages::get().listArchiveContentWithoutThread(path, ""); }
    Q_INVOKABLE int         getNumberDocumentPages(QString path)            { return PQCScriptsImages::get().getNumberDocumentPages(path); }
    Q_INVOKABLE int         getDocumentPageCount(QString path)              { return PQCScriptsImages::get().getDocumentPageCount(path); }
    Q_INVOKABLE QString     extractArchiveFileToTempLocation(QString path)  { return PQCScriptsImages::get().extractArchiveFileToTempLocation(path); }
    Q_INVOKABLE QString     extractDocumentPageToTempLocation(QString path) { return PQCScriptsImages::get().extractDocumentPageToTempLocation(path); }

    // icon and thumbnail methods
    Q_INVOKABLE QString getIconPathFromTheme(QString binary) { return PQCScriptsImages::get().getIconPathFromTheme(binary); }
    Q_INVOKABLE void    removeThumbnailFor(QString path)     { return PQCScriptsImages::get().removeThumbnailFor(path); }

    // video methods
    Q_INVOKABLE QString convertSecondsToPosition(int t) { return PQCScriptsImages::get().convertSecondsToPosition(t); }

Q_SIGNALS:
    void haveArchiveContentFor(QString filename, QStringList content);

};
