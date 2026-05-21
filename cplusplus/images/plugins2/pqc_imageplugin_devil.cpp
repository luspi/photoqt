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

#include <pqc_imageplugin_devil.h>
#include <pqc_settingscpp.h>
#include <pqc_imagecache.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <scripts/pqc_scriptsimages.h>

#include <QFile>
#include <QtDebug>

#ifdef PQMDEVIL
#include <IL/il.h>
#endif

PQCImagePluginDevIL::PQCImagePluginDevIL(QString settingsDir) : m_settingsDir(settingsDir) {

    m_composedWritableSuffixes = false;

    loadFormats();

}

const QString PQCImagePluginDevIL::getDescription(QString suffix) {
    return suffix2description.value(suffix, "");
}

const QSet<QString> PQCImagePluginDevIL::getWritableSuffixes() {

    return {};

}

const bool PQCImagePluginDevIL::writeImage(QImage img, QString targetPath) {
    return false;
}

const QSize PQCImagePluginDevIL::loadSize(QString path) {

#ifdef PQMDEVIL

    QString errormsg = "";

    // DevIL is NOT threadsafe -> need to ensure only one image is loaded at a time...
    QMutexLocker locker(&devilMutex);

    // Create an image id and make current
    ILuint imageID;
    ilGenImages(1, &imageID);
    ilBindImage(imageID);

    errormsg = checkForError();
    if(!errormsg.isEmpty()) {
        qWarning() << errormsg;
        return QSize();
    }

// load the passed on image file
#ifdef WIN32
    ilLoadImage(path.toStdWString().c_str());
#else
    ilLoadImage(path.toStdString().c_str());
#endif

    errormsg = checkForError();
    if(!errormsg.isEmpty()) {
        qWarning() << errormsg;
        return QSize();
    }

    // get the width/height
    const int width  = ilGetInteger(IL_IMAGE_WIDTH);
    const int height = ilGetInteger(IL_IMAGE_HEIGHT);
    return QSize(width, height);

#endif

    return QSize();

}

const QImage PQCImagePluginDevIL::loadImage(QString path, QSize requestedSize, QSize &origSize, QString &error) {

    qDebug() << "args: path = " << path;
    qDebug() << "args: requestedSize = " << requestedSize;

    QString errormsg = "";

#ifdef PQMDEVIL

    // DevIL is NOT threadsafe -> need to ensure only one image is loaded at a time...
    QMutexLocker locker(&devilMutex);

    // Create an image id and make current
    ILuint imageID;
    ilGenImages(1, &imageID);
    ilBindImage(imageID);

    errormsg = checkForError();
    if(!errormsg.isEmpty()) {
        error += errormsg % "\n";
        qWarning() << errormsg;
        return QImage();
    }

// load the passed on image file
#ifdef WIN32
    if(!ilLoadImage(path.toStdWString().c_str())) {
#else
    if(!ilLoadImage(path.toStdString().c_str())) {
#endif
        ilDeleteImages(1, &imageID);
        const QString err = "Failed to load image with DevIL";
        error += err % "\n";
        qWarning() << err;
        return QImage();
    }

    // convert to a predictable format Qt understands
    if(!ilConvertImage(IL_RGBA, IL_UNSIGNED_BYTE)) {
        ilDeleteImages(1, &imageID);
        const QString err = "Failed to convert image with DevIL";
        qWarning() << err;
        error += err % "\n";
        return QImage();
    }

    errormsg = checkForError();
    if(!errormsg.isEmpty()) {
        error += errormsg % "\n";
        qWarning() << errormsg;
        return QImage();
    }

    // get the width/height
    const int width  = ilGetInteger(IL_IMAGE_WIDTH);
    const int height = ilGetInteger(IL_IMAGE_HEIGHT);
    origSize = QSize(width, height);

    errormsg = checkForError();
    if(!errormsg.isEmpty()) {
        error += errormsg % "\n";
        qWarning() << errormsg;
        return QImage();
    }

    uchar* data = ilGetData();

    // DevIL owns the memory, so copy before deleting image
    QImage img = QImage(data, width, height, QImage::Format_RGBA8888).copy();

    if(img.isNull()) {
        const QString msg = "Failed to create QImage with DevIL (unknown error)!";
        error += msg % "\n";
        qWarning() << msg;
        return QImage();
    }

    bool imageIsScaled = false;

    if(!requestedSize.isEmpty()) {
        imageIsScaled = true;
        img = img.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }

    if(!img.isNull() && PQCSettingsCPP::get().getMetadataAutoRotation()) {
        // apply transformations if any
        PQCScriptsImages::get().applyExifOrientation(path, img);
    }

    if(!imageIsScaled) {
        PQCScriptsColorProfiles::get().applyColorProfile(path, img);
        PQCImageCache::get().saveImageToCache(path, PQCScriptsColorProfiles::get().getColorProfileFor(path), &img);
    }

    return img;

#endif

    return QImage();

}

void PQCImagePluginDevIL::setEnabled(QString suffix, QString mimetype, bool enabled) {

}

/***********************************************/

void PQCImagePluginDevIL::loadFormats() {

    m_suffixes.clear();
    m_toggledSuffixes.clear();
    m_allSuffixes.clear();

    // first we read the toggled suffixes from the settings file
    const QString suffixFilename = m_settingsDir % "/devil_suffixes";
    QFile suffixFile(suffixFilename);
    if(!suffixFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
        qDebug() << "Failed to open settings file at:" << suffixFilename;
    } else {
        QTextStream suffixIn(&suffixFile);
        const QStringList tmp = suffixIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledSuffixes = QSet<QString>(tmp.begin(), tmp.end());
        suffixFile.close();
    }

    // then we store ALL supported suffixes
    m_allSuffixes = {"bmp", "dib", "cur", "gif", "jpeg2000", "j2k", "jp2", "jpc", "jpx",
                     "jpeg", "jpg", "jpe", "jif", "pbm", "pgm", "png", "ppm", "pnm", "psd",
                     "psb", "psdt", "rgba", "rgb", "sgi", "bw", "tga", "icb", "vda", "vst",
                     "tiff", "tif", "cut", "pal", "dic", "dcm", "fits", "fit", "fts",
                     "pcd", "pcds", "pix", "als", "alias", "rgbe", "hdr", "rad", "dds",
                     "ftx", "iff", "lbm", "vtf", "ico"};

    // these are the currently enabled ones
    m_suffixes = m_allSuffixes - m_toggledSuffixes;

    suffix2description = {
        {"bmp", "BMP: Microsoft Windows bitmap"},
        {"dib", "BMP: Microsoft Windows bitmap"},
        {"cur", "CUR: Microsoft Windows cursor format"},
        {"gif", "GIF: Graphics Interchange Format"},
        {"jpeg2000", "JPEG-2000"},
        {"j2k",      "JPEG-2000"},
        {"jp2",      "JPEG-2000"},
        {"jpc",      "JPEG-2000"},
        {"jpx",      "JPEG-2000"},
        {"jpeg", "JPEG: Joint Photographic Experts Group JFIF format"},
        {"jpg",  "JPEG: Joint Photographic Experts Group JFIF format"},
        {"jpe",  "JPEG: Joint Photographic Experts Group JFIF format"},
        {"jif",  "JPEG: Joint Photographic Experts Group JFIF format"},
        {"pbm", "PBM: Portable bitmap format (black and white)"},
        {"pgm", "PGM: Portable graymap format (gray scale)"},
        {"png", "PNG: Portable Network Graphics"},
        {"ppm", "PPM: Portable pixmap format (color)"},
        {"pnm", "PPM: Portable pixmap format (color)"},
        {"psd",  "Adobe PhotoShop"},
        {"psb",  "Adobe PhotoShop"},
        {"psdt", "Adobe PhotoShop"},
        {"rgba", "SGI images"},
        {"rgb",  "SGI images"},
        {"sgi",  "SGI images"},
        {"bw",   "SGI images"},
        {"tga", "TGA: Truevision Targa image"},
        {"icb", "TGA: Truevision Targa image"},
        {"vda", "TGA: Truevision Targa image"},
        {"vst", "TGA: Truevision Targa image"},
        {"tiff", "TIFF: Tagged Image File Format"},
        {"tif",  "TIFF: Tagged Image File Format"},
        {"cut", "Dr. Halo"},
        {"pal", "Dr. Halo"},
        {"dic", "Digital Imaging and Communications in Medicine (DICOM) image"},
        {"dcm", "Digital Imaging and Communications in Medicine (DICOM) image"},
        {"fits", "FITS: Flexible Image Transport System"},
        {"fit",  "FITS: Flexible Image Transport System"},
        {"fts",  "FITS: Flexible Image Transport System"},
        {"pcd",  "Photo CD"},
        {"pcds", "Photo CD"},
        {"pix",   "Alias/Wavefront RLE image format"},
        {"als",   "Alias/Wavefront RLE image format"},
        {"alias", "Alias/Wavefront RLE image format"},
        {"rgbe", "HDR: Radiance RGBE image format"},
        {"hdr",  "HDR: Radiance RGBE image format"},
        {"rad",  "HDR: Radiance RGBE image format"},
        {"dds", "DirectDraw Surface"},
        {"ftx", "Heavy Metal: FAKK 2"},
        {"iff", "Interchange File Format"},
        {"lbm", "Interlaced Bitmap"},
        {"vtf", "Valve Texture Format"},
        {"ico", "Microsoft Windows icon format"}
    };

    /********************************/

    m_mimetypes.clear();
    m_toggledMimetypes.clear();
    m_allMimetypes.clear();

    const QString mimeFilename = m_settingsDir % "/devil_mimetypes";
    QFile mimeFile(mimeFilename);
    if(!mimeFile.open(QIODevice::ReadOnly|QIODevice::Text)) {
        qDebug() << "Failed to open settings file at:" << mimeFilename;
    } else {
        QTextStream mimeIn(&mimeFile);
        const QStringList tmp = mimeIn.readAll().split("\n", Qt::SkipEmptyParts);
        m_toggledMimetypes = QSet<QString>(tmp.begin(), tmp.end());
        mimeFile.close();
    }

    // then we store ALL supported mimetypes
    m_allMimetypes = {"image/bmp", "image/x-ms-bmp", "image/x-win-bitmap", "image/gif", "image/jp2",
                      "image/jpx", "image/jpm", "image/jpeg", "image/x-portable-anymap",
                      "image/x-portable-greymap", "image/x-portable-anymap", "image/png",
                      "image/x-portable-pixmap", "image/x-portable-anymap", "image/vnd.adobe.photoshop",
                      "image/sgi", "image/x-targa", "image/x-tga", "image/tiff", "image/tiff-fx",
                      "application/dicom", "image/dicom-rle", "image/fits", "image/vnd.microsoft.icon",
                      "image/x-icon"};

    // these are the currently enabled ones
    m_mimetypes = m_allMimetypes - m_toggledMimetypes;

    Q_EMIT formatsUpdated();

}

void PQCImagePluginDevIL::saveFormats() {

    // TODO

}

#ifdef PQMDEVIL
QString PQCImagePluginDevIL::checkForError() {
    ILenum err_enum = ilGetError();
    QString errormsg = "";
    while(err_enum != IL_NO_ERROR) {
        if(errormsg.isEmpty()) errormsg = "Error: ";
        else errormsg += ", ";
        errormsg += QString::number(err_enum);
        err_enum = ilGetError();
    }
    return errormsg;
}
#endif
