#include <scripts/pqc_scriptsfilemanagement.h>
#include <pqc_configfiles.h>
#include <pqc_imageformats.h>
#include <pqc_loadimage.h>
#include <QtDebug>
#include <QFileInfo>
#include <QDir>
#include <QUrl>
#include <QStorageInfo>
#include <QDirIterator>
#include <QImageWriter>
#include <QImageReader>
#include <QtConcurrent>
#include <QFileDialog>
#ifdef WIN32
#include <thread>
#else
#include <unistd.h>
#endif
#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
#include <Magick++/CoderInfo.h>
#include <Magick++/Exception.h>
#include <Magick++/Image.h>
#endif
#ifdef EXIV2
#include <exiv2/exiv2.hpp>
#endif

PQCScriptsFileManagement::PQCScriptsFileManagement() {}

PQCScriptsFileManagement::~PQCScriptsFileManagement() {}

bool PQCScriptsFileManagement::copyFileToHere(QString filename, QString targetdir) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: targetdir =" << targetdir;

    QFileInfo info(filename);
    if(!info.exists())
        return false;

    QString targetFilename = QString("%1/%2").arg(targetdir, info.fileName());
    QFileInfo targetinfo(targetFilename);

    // file copied to itself
    if(targetFilename == filename)
        return true;

    if(targetinfo.exists()) {
        QFile tf(targetFilename);
        tf.remove();
    }

    QFile f(filename);
    return f.copy(targetFilename);

}

bool PQCScriptsFileManagement::deletePermanent(QString filename) {

    qDebug() << "args: filename = " << filename;

    QFileInfo info(filename);
    if(info.isDir()) {
        QDir dir(filename);
        if(!dir.removeRecursively()) {
            qWarning() << "PQHandlingFileDir::deleteFile(): Failed to delete folder recursively!";
            return false;
        }
        return true;
    }
    QFile file(filename);
    return file.remove();

}

bool PQCScriptsFileManagement::moveFileToTrash(QString filename) {

    qDebug() << "args: filename = " << filename;

#ifdef Q_OS_WIN
    QFile file(filename);
    // we need to call moveToTrash on a different QFile object, otherwise the exists() check will return false
    // even while the file isn't deleted as it is seen as opened by PhotoQt
    QFile f(filename);
    bool ret = f.moveToTrash();
    int count = 0;
    while(file.exists() && count < 20) {
        QFile f(filename);
        ret = f.moveToTrash();
        std::this_thread::sleep_for(std::chrono::milliseconds(250));
        ++count;
    }
    return ret;
#else
    return QFile::moveToTrash(filename);
#endif

}

void PQCScriptsFileManagement::exportImage(QString sourceFilename, QString targetFilename, int uniqueid) {

    qDebug() << "args: sourceFilename =" << sourceFilename;
    qDebug() << "args: targetFilename =" << targetFilename;
    qDebug() << "args: uniqueid =" << uniqueid;

    QtConcurrent::run([=]() {

        // get info about new file format and source file
        QVariantMap databaseinfo = PQCImageFormats::get().getFormatsInfo(uniqueid);

        // First we load the image...
        QSize tmp;
        QImage img;
        PQCLoadImage::get().load(sourceFilename, QSize(-1,-1), tmp, img);

        // we convert the image to this tmeporary file and then copy it to the right location
        // converting it straight to the right location can lead to corrupted thumbnails if target folder is the same as source folder
        QString tmpImagePath = PQCConfigFiles::CACHE_DIR() + "/temporaryfileforexport" + "." + databaseinfo.value("endings").toString().split(",")[0];
        if(QFile::exists(tmpImagePath))
            QFile::remove(tmpImagePath);

        // qt might support it
        if(databaseinfo.value("qt").toInt() == 1) {

            QImageWriter writer;

            // if the QImageWriter supports the format then we're good to go
            if(writer.supportedImageFormats().contains(databaseinfo.value("qt_formatname").toString())) {

                // ... and then we write it into the new format
                writer.setFileName(tmpImagePath);
                writer.setFormat(databaseinfo.value("qt_formatname").toString().toUtf8());

                // if the actual writing suceeds we're done now
                if(!writer.write(img))
                    qWarning() << "ERROR:" << writer.errorString();
                else {
                    // copy result to target destination
                    QFile::copy(tmpImagePath, targetFilename);
                    QFile::remove(tmpImagePath);
                    Q_EMIT exportCompleted(true);
                    return;
                }

            }

        }

    // imagemagick/graphicsmagick might support it
    #if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
    #ifdef IMAGEMAGICK
        if(databaseinfo.value("imagemagick").toInt() == 1) {
    #else
        if(databaseinfo.value("graphicsmagick").toInt() == 1) {
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

                    // first we write the QImage to a temporary file
                    // then we load it into magick and write it to the target file

                    // find unique temporary path
                    QString tmppath = PQCConfigFiles::CACHE_DIR() + "/converttmp.ppm";
                    if(QFile::exists(tmppath))
                        QFile::remove(tmppath);

                    img.save(tmppath);

                    // load image and write to target file
                    Magick::Image image;
                    image.magick("PPM");
                    image.read(tmppath.toStdString());

                    image.magick(databaseinfo.value("im_gm_magick").toString().toStdString());
                    image.write(tmpImagePath.toStdString());

                    // remove temporary file
                    QFile::remove(tmppath);

                    // copy result to target destination
                    QFile::copy(tmpImagePath, targetFilename);
                    QFile::remove(tmpImagePath);

                    // success!
                    Q_EMIT exportCompleted(true);
                    return;

                } catch(Magick::Exception &) { }

            }

        }

    #endif

        // unsuccessful conversion...
        Q_EMIT exportCompleted(false);

    });

}

bool PQCScriptsFileManagement::canThisBeScaled(QString filename) {

    qDebug() << "args: filename = " << filename;

    int uniqueid = PQCImageFormats::get().detectFormatId(filename);
    return (PQCImageFormats::get().getWriteStatus(uniqueid) > 0);

}

void PQCScriptsFileManagement::scaleImage(QString sourceFilename, QString targetFilename, int uniqueid, QSize targetSize, int targetQuality) {

    qDebug() << "args: sourceFilename = " << sourceFilename;
    qDebug() << "args: targetFilename = " << targetFilename;
    qDebug() << "args: uniqueid = " << uniqueid;
    qDebug() << "args: targetSize = " << targetSize;
    qDebug() << "args: targetQuality = " << targetQuality;

    QtConcurrent::run([=]() {

        int writeStatus = PQCImageFormats::get().getWriteStatus(uniqueid);

        if(writeStatus == 0) {
            qWarning() << "ERROR: file not supported for scaling:" << sourceFilename;
            Q_EMIT scaleCompleted(false);
            return;
        }

        QVariantMap databaseinfo = PQCImageFormats::get().getFormatsInfo(uniqueid);

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
            qDebug() << "ERROR reading exif data (caught exception):" << e.what();
        }

    #endif

        // We need to do the actual scaling in between reading the exif data above and writing it below,
        // since we might be scaling the image in place and thus would overwrite old exif data
        bool success = false;

        QSize s;
        QImage img;
        PQCLoadImage::get().load(sourceFilename, targetSize, s, img);

        if(writeStatus == 1 || writeStatus == 2) {

            // we don't stop if this fails as we might be able to try again with Magick
            if(img.save(targetFilename, databaseinfo.value("qt_formatname").toString().toStdString().c_str(), targetQuality))
                success = true;
            else
                qWarning() << "Scaling image with Qt failed";

        }

        if(!success && (writeStatus == 1 || writeStatus == 3)) {

    // imagemagick/graphicsmagick might support it
    #if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
    #ifdef IMAGEMAGICK
            if(databaseinfo.value("imagemagick").toInt() == 1) {
    #else
            if(databaseinfo.value("graphicsmagick").toInt() == 1) {
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

                    // we scale the image to this tmeporary file and then copy it to the right location
                    // converting it straight to the right location can lead to corrupted thumbnails if target folder is the same as source folder
                    QString tmpImagePath = PQCConfigFiles::CACHE_DIR() + "/temporaryfileforscale" + "." + databaseinfo.value("endings").toString().split(",")[0];
                    if(QFile::exists(tmpImagePath))
                        QFile::remove(tmpImagePath);

                    try {

                        // first we write the QImage to a temporary file
                        // then we load it into magick and write it to the target file

                        // find unique temporary path
                        QString tmppath = PQCConfigFiles::CACHE_DIR() + "/converttmp.ppm";
                        if(QFile::exists(tmppath))
                            QFile::remove(tmppath);

                        img.save(tmppath);

                        // load image and write to target file
                        Magick::Image image;
                        image.magick("PPM");
                        image.read(tmppath.toStdString());

                        image.resize(Magick::Geometry(targetSize.width(), targetSize.height()));

                        image.magick(databaseinfo.value("im_gm_magick").toString().toStdString());
                        image.write(tmpImagePath.toStdString());

                        // remove temporary file
                        QFile::remove(tmppath);

                        // copy result to target destination
                        QFile::copy(tmpImagePath, targetFilename);
                        QFile::remove(tmpImagePath);

                        // success!
                        success = true;

                    } catch(Magick::Exception &) { }

                }

            }

    #endif

        }

        if(!success) {
            Q_EMIT scaleCompleted(false);
            return;
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
                qWarning() << "ERROR writing exif data (caught exception):" << e.what();
            }

        }

    #endif

        Q_EMIT scaleCompleted(true);

    });

}
