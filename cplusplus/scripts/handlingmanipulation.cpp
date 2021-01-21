/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

#include "handlingmanipulation.h"

bool PQHandlingManipulation::canThisBeScaled(QString filename) {

    DBG << CURDATE << "PQHandlingManipulation::canThisBeScaled()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    // These image formats known by exiv2 are also supported by PhotoQt
    QStringList formats;
    formats << "jpeg"
            << "jpg"
            << "tif"
            << "tiff"
            << "png"
            << "psd"
            << "jpeg2000"
            << "jp2"
            << "jpc"
            << "j2k"
            << "jpf"
            << "jpx"
            << "jpm"
            << "mj2"
            << "bmp"
            << "bitmap"
            << "gif"
            << "tga";

    return formats.contains(QFileInfo(filename).suffix().toLower());

}

int PQHandlingManipulation::chooseLocationAndConvertImage(QString sourceFilename, QString targetFilename, QString targetEndings) {

    DBG << CURDATE << "PQHandlingManipulation::chooseLocationAndConvertImage()" << NL
        << CURDATE << "** sourceFilename = " << sourceFilename.toStdString() << NL
        << CURDATE << "** targetFilename = " << targetFilename.toStdString() << NL
        << CURDATE << "** targetEndings = " << targetEndings.toStdString() << NL;

    // get info about new file format and source file
    QVariantMap databaseinfo = PQImageFormats::get().getFormatsInfo(targetEndings);
    QFileInfo fileinfo(sourceFilename);

    // request user to select target directory
    QString targetdir = QFileDialog::getExistingDirectory(nullptr, "Choose new location", fileinfo.absolutePath());
    if(targetdir == "")
        return -1;  // -1 means cancelled

    // if we succeeded converting the image
    bool success = false;

    // qt might support it
    if(databaseinfo.value("qt").toInt() == 1) {

        QImageWriter writer;

        // if the QImageWriter supports the format then we're good to go
        if(writer.supportedImageFormats().contains(databaseinfo.value("qt_formatname").toString().toUtf8())) {


            // First we load the image...
            PQLoadImageQt loader;
            QSize tmp;
            QImage img = loader.load(sourceFilename, QSize(-1,-1), &tmp);

            // ... and then we write it into the new format
            writer.setFileName(QString("%1/%2").arg(targetdir, targetFilename));
            writer.setFormat(databaseinfo.value("qt_formatname").toString().toUtf8());

            // if the actual writing suceeds we're done now
            if(!writer.write(img))
                LOG << "ERR: " << writer.errorString().toStdString() << NL;
            else
                success = true;

        }

    }

    // imagemagick/graphicsmagick might support it
#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
#ifdef IMAGEMAGICK
    if(!success && databaseinfo.value("imagemagick").toInt() == 1) {
#else
    if(!success && databaseinfo.value("graphicsmagick").toInt() == 1) {
#endif

        // first check whether ImageMagick/GraphicsMagick supports writing this filetype
        bool canproceed = false;
        try {
            QString magick = databaseinfo.value("im_gm_magick").toString();
            Magick::CoderInfo magickCoderInfo(magick.toStdString());
            if(magickCoderInfo.isWritable())
                canproceed = true;
        } catch(Magick::Exception &) { }

        // yes, it's supported
        if(canproceed) {

            try {
                // first load the image but skip the conversion into QImage type
                PQLoadImageMagick loader;
                QSize tmp;
                loader.load(sourceFilename, QSize(-1,-1), &tmp, true);

                // get raw Magick image from loader
                Magick::Image img = loader.image;

                // and write new output file
                img.magick(databaseinfo.value("im_gm_magick").toString().toStdString());
                img.write(QString("%1/%2").arg(targetdir, targetFilename).toStdString());

                // success!
                success = true;

            } catch(Magick::Exception &) { }

        }

    }

#endif

    // 0 = error, 1 = success
    return (success ? 1 : 0);

}

QSize PQHandlingManipulation::getCurrentImageResolution(QString filename) {

    DBG << CURDATE << "PQHandlingManipulation::getCurrentImageResolution()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    QImageReader reader(filename);
    return reader.size();

}

bool PQHandlingManipulation::scaleImage(QString sourceFilename, bool scaleInPlace, QSize targetSize, int targetQuality) {

    DBG << CURDATE << "PQHandlingManipulation::scaleImage()" << NL
        << CURDATE << "** sourceFilename = " << sourceFilename.toStdString() << NL
        << CURDATE << "** scaleInPlace = " << scaleInPlace << NL
        << CURDATE << "** targetSize = " << targetSize.width() << "x" << targetSize.height() << NL
        << CURDATE << "** targetQuality = " << targetQuality << NL;

    if(!canThisBeScaled(sourceFilename)) {
        LOG << CURDATE << "PQHandlingManipulation::scaleImage: ERROR file '" << sourceFilename.toStdString() << "' not supported for scaling" << NL;
        return false;
    }

#ifdef EXIV2

    // This will store all the exif data
    Exiv2::ExifData exifData;
    Exiv2::IptcData iptcData;
    Exiv2::XmpData xmpData;
    bool gotExifData = false;

    try {

        // Open image for exif reading
#if EXIV2_TEST_VERSION(0, 28, 0)
        Exiv2::Image::UniquePtr image_read = Exiv2::ImageFactory::open(sourceFilename.toStdString());
#else
        Exiv2::Image::AutoPtr image_read = Exiv2::ImageFactory::open(sourceFilename.toStdString());
#endif

        if(image_read.get() != 0) {

            // YAY, WE FOUND SOME!!!!!
            gotExifData = true;

            // read exif
            image_read->readMetadata();
            exifData = image_read->exifData();
            iptcData = image_read->iptcData();
            xmpData = image_read->xmpData();

            // Update dimensions
            exifData["Exif.Photo.PixelXDimension"] = int32_t(targetSize.width());
            exifData["Exif.Photo.PixelYDimension"] = int32_t(targetSize.height());

        }

    }

    catch (Exiv2::Error& e) {
        LOG << CURDATE << "PQHandlingManipulation::scaleImage: ERROR reading exif data (caught exception): " << e.what() << NL;
    }

#endif

    // We need to do the actual scaling in between reading the exif data above and writing it below,
    // since we might be scaling the image in place and thus would overwrite old exif data
    QImageReader reader(sourceFilename);
    reader.setScaledSize(QSize(targetSize.width(),targetSize.height()));
    QImage img = reader.read();

    QString targetFilename = sourceFilename;
    if(!scaleInPlace) {

        QFileInfo info(sourceFilename);

        QString suggestedfilename = QString("%2_%3x%4.%5").arg(info.baseName())
                                                          .arg(targetSize.width())
                                                          .arg(targetSize.height())
                                                          .arg(info.suffix());

        QFileDialog dialog;
        dialog.setWindowTitle(QApplication::translate("scale", "Select new file"));
        dialog.setDirectory(info.absolutePath());
        dialog.selectFile(suggestedfilename);
        if(!dialog.exec())
            return false;
        targetFilename = dialog.selectedFiles().at(0);

    }

    if(!img.save(targetFilename, 0, targetQuality)) {
        LOG << CURDATE << "PQHandlingManipulation::scaleImage: ERROR: Unable to save scaled image file" << NL;
        return false;
    }

#ifdef EXIV2

    if(gotExifData) {

        try {

            // And write exif data to new image file
#if EXIV2_TEST_VERSION(0, 28, 0)
            Exiv2::Image::UniquePtr image_write = Exiv2::ImageFactory::open(targetFilename.toStdString());
#else
            Exiv2::Image::AutoPtr image_write = Exiv2::ImageFactory::open(targetFilename.toStdString());
#endif
            image_write->setExifData(exifData);
            image_write->setIptcData(iptcData);
            image_write->setXmpData(xmpData);
            image_write->writeMetadata();

        }

        catch (Exiv2::Error& e) {
            LOG << CURDATE << "PQHandlingManipulation::scaleImage: ERROR writing exif data (caught exception): " << e.what() << NL;
        }

    }

#endif

    return true;

}
