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

#include <pqc_extensionmethods.h>
#include <pqc_notify_cpp.h>
#include <scripts/pqc_scriptsshortcuts.h>
#include <scripts/pqc_scriptsconfig.h>
#include <pqc_extensionshandler.h>
#include <pqc_imagehandler.h>
#include <QImage>
#include <QFileDialog>

#ifdef PQMEXIV2
#include <exiv2/exiv2.hpp>
#endif

PQCExtensionMethods::PQCExtensionMethods(QObject *parent) : QObject(parent) {

    connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::replyForAction, this, &PQCExtensionMethods::replyForAction);
    connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::replyForActionWithImage, this, &PQCExtensionMethods::replyForActionWithImage);
    connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::receivedMessage, this, &PQCExtensionMethods::receivedMessage);

    connect(this, &PQCExtensionMethods::resetGeometry, &PQCExtensionsHandler::get(), &PQCExtensionsHandler::resetGeometry);

#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::keyPress, this, [=, this](int key, int modifiers) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::keyPress, this, [=](int key, int modifiers) {
#endif
        QString combo = PQCScriptsShortcuts::get().analyzeModifier(static_cast<Qt::KeyboardModifiers>(modifiers)).join("+");
        if(!combo.isEmpty()) combo.append("+");
        combo += PQCScriptsShortcuts::get().analyzeKeyPress(static_cast<Qt::Key>(key));
        Q_EMIT receivedShortcut(combo);
    });

}

QVariant PQCExtensionMethods::callAction(const QString &id, QVariant additional) {
    return PQCExtensionsHandler::get().callAction(id, additional);
}

QVariant PQCExtensionMethods::callActionWithImage(const QString &id, QVariant additional) {
    return PQCExtensionsHandler::get().callActionWithImage(id, additional);
}

void PQCExtensionMethods::callActionNonBlocking(const QString &id, QVariant additional) {
    PQCExtensionsHandler::get().callActionNonBlocking(id, additional);
}

void PQCExtensionMethods::callActionWithImageNonBlocking(const QString &id, QVariant additional) {
    PQCExtensionsHandler::get().callActionWithImageNonBlocking(id, additional);
}

/**********************************/

// execute an internal command
void PQCExtensionMethods::executeInternalCommand(QString cmd) {
    Q_EMIT PQCScriptsShortcuts::get().executeInternalCommand(cmd);
}

// show a notification
void PQCExtensionMethods::showNotification(QString title, QString txt) {
    Q_EMIT PQCNotifyCPP::get().showNotificationMessage(title, txt);
}

// run another extension
void PQCExtensionMethods::runExtension(const QString &id) {
    Q_EMIT PQCNotifyCPP::get().showExtension(id);
}

void PQCExtensionMethods::showSettingsFor(const QString &id) {
    Q_EMIT PQCNotifyCPP::get().showSettingsForExtension(id);
}

const QSet<QString> PQCExtensionMethods::getEnabledFormats() {
    return PQCImageHandler::get().getEnabledFormats();
}

const QSet<QString> PQCExtensionMethods::getEnabledSuffixes() {
    return PQCImageHandler::get().getEnabledSuffixes();
}

const QSet<QString> PQCExtensionMethods::getEnabledMimetypes() {
    return PQCImageHandler::get().getEnabledMimetypes();
}

const QSet<QString> PQCExtensionMethods::getWritableFormats() {
    return PQCImageHandler::get().getWritableFormats();
}

const QSet<QString> PQCExtensionMethods::getWritableSuffixes() {
    return PQCImageHandler::get().getWritableSuffixes();
}

const QSet<QString> PQCExtensionMethods::getSuffixesForFormat(const QString format) {
    return PQCImageHandler::get().getAllSuffixesForFormat(format);
}

const QString PQCExtensionMethods::getFormatOfFile(const QString file) {
    QFileInfo info(file);
    const QString f1 = PQCImageHandler::get().getFormatName(info.suffix().toLower());
    if(f1 != "")
        return f1;
    return PQCImageHandler::get().getFormatName(info.completeSuffix().toLower());
}

QString PQCExtensionMethods::path2ImageProvider(QString path, bool thumb) {
    if(path.isEmpty()) return "";
    if(thumb) return "image://thumb/" % path;
    return "image://full/" % path;
}

QSize PQCExtensionMethods::getSizeOfImage(const QString file) {
    return PQCImageHandler::get().getSize(file);
}

bool PQCExtensionMethods::writeImage(const QString sourceFile, const QString targetFile, const QRect sourceRect, const QSize targetSize) {

#ifdef PQMEXIV2

    // This will store all the exif data
    Exiv2::ExifData exifData;
    Exiv2::IptcData iptcData;
    Exiv2::XmpData xmpData;
    bool gotExifData = false;

#if EXIV2_TEST_VERSION(0, 28, 0)
    Exiv2::Image::UniquePtr image_read;
#else
    Exiv2::Image::AutoPtr image_read;
#endif

    try {

        // Open image for exif reading
        image_read = Exiv2::ImageFactory::open(sourceFile.toStdString());

        if(image_read.get() != 0) {
            // YAY, WE FOUND SOME!!!!!
            gotExifData = true;
            image_read->readMetadata();
        }

    }

    catch (Exiv2::Error& e) {
        qDebug() << "ERROR reading exif data (caught exception):" << e.what();
    }

    if(gotExifData) {

        // read exif
        exifData = image_read->exifData();
        iptcData = image_read->iptcData();
        xmpData = image_read->xmpData();

        // Update dimensions
        exifData["Exif.Photo.PixelXDimension"] = int32_t(targetSize.width());
        exifData["Exif.Photo.PixelYDimension"] = int32_t(targetSize.height());

    }

#endif

    QSize origSize;
    QString err;
    QImage img;

    // if both source rect and target size are empty then it is a simple conversion
    if(sourceRect.isEmpty() && targetSize.isEmpty()) {

        img = PQCImageHandler::get().getImage(sourceFile, QSize(), origSize, err);

    // if only a source rect is specified, then we extract and save the extracted image as is
    } else if(targetSize.isEmpty()) {

        img = PQCImageHandler::get().getImage(sourceFile, QSize(), origSize, err)
                  .copy(sourceRect);

    // if only a target size is specified, simply resize the image and save it
    } else if(sourceRect.isEmpty()) {

        img = PQCImageHandler::get().getImage(sourceFile, QSize(), origSize, err)
                  .scaled(targetSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

    // if both are specified, then extract a rectangle and store it at the specified size
    } else {
        img = PQCImageHandler::get().getImage(sourceFile, QSize(), origSize, err)
                  .copy(sourceRect)
                  .scaled(targetSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
    }

    // failed :/
    if(img.isNull())
        return false;

    // write image if possible
    bool ret = PQCImageHandler::get().writeImage(img, targetFile);
    if(!ret)
        return false;

#ifdef PQMEXIV2

    if(gotExifData) {

        try {

            // And write exif data to new image file
#if EXIV2_TEST_VERSION(0, 28, 0)
            Exiv2::Image::UniquePtr image_write = Exiv2::ImageFactory::open(targetFile.toStdString());
#else
            Exiv2::Image::AutoPtr image_write = Exiv2::ImageFactory::open(targetFile.toStdString());
#endif
            image_write->setExifData(exifData);
            image_write->setIptcData(iptcData);
            image_write->setXmpData(xmpData);
            image_write->writeMetadata();

        }

        catch (Exiv2::Error& e) {
            qWarning() << "ERROR writing exif data (caught exception):" << e.what();
        }

    }

#endif

    return true;

}

QString PQCExtensionMethods::getExistingDirectory(const QString caption, const QString dir) {
    return QFileDialog::getExistingDirectory(nullptr, caption, dir);
}

QString PQCExtensionMethods::getOpenFileName(const QString caption, const QString dir, const QString filter) {
    return QFileDialog::getOpenFileName(nullptr, caption, dir, filter);
}

QStringList PQCExtensionMethods::getOpenFileNames(const QString caption, const QString dir, const QString filter) {
    return QFileDialog::getOpenFileNames(nullptr, caption, dir, filter);
}

QString PQCExtensionMethods::getSaveFileName(const QString caption, const QString dir, const QString filter) {
    return QFileDialog::getSaveFileName(nullptr, caption, dir, filter);
}
