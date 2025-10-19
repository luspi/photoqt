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

#include <qml/pqc_scriptsfilemanagement.h>
#include <qml/pqc_scriptsfilespaths.h>
#include <qml/pqc_filefoldermodel_cpp.h>
#include <qml/pqc_localserver.h>
#include <shared/pqc_configfiles.h>
#include <shared/pqc_sharedconstants.h>

#include <QtDebug>
#include <QFileInfo>
#include <QDir>
#include <QUrl>
#include <QStorageInfo>
#include <QDirIterator>
#include <QImageWriter>
#include <QImageReader>
#include <QtConcurrent/QtConcurrentRun>
#include <QFileDialog>
#include <QMessageBox>
#include <QPushButton>
#include <thread>
#ifdef WIN32
#include <thread>
#else
#include <unistd.h>
#endif
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
#include <Magick++/CoderInfo.h>
#include <Magick++/Exception.h>
#include <Magick++/Image.h>
#endif
#ifdef PQMEXIV2
#include <exiv2/exiv2.hpp>
#endif

#ifdef PQMFLATPAKBUILD
#include <gio/gio.h>
#endif

PQCScriptsFileManagement::PQCScriptsFileManagement() {

    undoCurFolder = "";
    undoTrash.clear();

    connect(&PQCFileFolderModelCPP::get(), &PQCFileFolderModelCPP::currentFileChanged, this, [=]() {
        QString newFolder = PQCScriptsFilesPaths::get().getDir(PQCFileFolderModelCPP::get().getCurrentFile());
        if(undoCurFolder != newFolder) {
            undoCurFolder = newFolder;
            undoTrash.clear();
        }
    });

}

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
            qWarning() << "Failed to delete folder recursively!";
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
    QString deletedFilename = "";
    QFile file(filename);
    // we need to call moveToTrash on a different QFile object, otherwise the exists() check will return false
    // even while the file isn't deleted as it is seen as opened by PhotoQt
    QFile f(filename);
    bool ret = f.moveToTrash();
    int count = 0;
    while(file.exists() && count < 20) {
        QFile f(filename);
        ret = f.moveToTrash();
        if(ret && deletedFilename == "")
            deletedFilename = f.fileName();
        std::this_thread::sleep_for(std::chrono::milliseconds(250));
        ++count;
    }
    recordAction("trash", {filename, deletedFilename});
    return ret;
#else

#ifndef PQMFLATPAKBUILD

    // this does not work with Flatpak, checked 2024-04-03
    QString trashFile = "";
    bool rettrash = QFile::moveToTrash(filename, &trashFile);
    if(rettrash)
        recordAction("trash", {filename, trashFile});
    return rettrash;

#else

    // for flatpaks we use GIO trash function as this has support for the trash portal

    GFile *file = g_file_new_for_path(filename.toStdString().c_str());
    GError *error = nullptr;
    bool success = g_file_trash(file, nullptr, &error);

    if(!success) {
        qWarning() << "Failed to move file to trash:" << error->message;
        g_error_free(error);
    }

    g_object_unref(file);

    return success;

#endif

#endif

}

bool PQCScriptsFileManagement::canThisBeCropped(QString filename) {
    return canThisBeScaled(filename);
}

bool PQCScriptsFileManagement::canThisBeScaled(QString filename) {

    qDebug() << "args: filename = " << filename;

    const QString suffix = QFileInfo(filename).suffix().toLower();
    return (PQCSharedMemory::get().getImageFormatsEnding2QtName().contains(suffix) || PQCSharedMemory::get().getImageFormatsEnding2MagickName().contains(suffix));

}

void PQCScriptsFileManagement::scaleImage(QString sourceFilename, QString targetFilename, int uniqueid, QSize targetSize, int targetQuality) {

    qDebug() << "args: sourceFilename = " << sourceFilename;
    qDebug() << "args: targetFilename = " << targetFilename;
    qDebug() << "args: uniqueid = " << uniqueid;
    qDebug() << "args: targetSize = " << targetSize;
    qDebug() << "args: targetQuality = " << targetQuality;

    QFuture<void> f = QtConcurrent::run([=]() {

        const QString suffix = QFileInfo(sourceFilename).suffix().toLower();
        bool canWriteQt = PQCSharedMemory::get().getImageFormatsEnding2QtName().contains(suffix);
        bool canWriteMagick = PQCSharedMemory::get().getImageFormatsEnding2MagickName().contains(suffix);

        if(!canWriteQt && !canWriteMagick) {
            qWarning() << "ERROR: file not supported for scaling:" << sourceFilename;
            Q_EMIT scaleCompleted(false);
            return;
        }

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
    #if EXIV2_TEST_VERSION(0, 28, 0)
            image_read = Exiv2::ImageFactory::open(sourceFilename.toStdString());
    #else
            image_read = Exiv2::ImageFactory::open(sourceFilename.toStdString());
    #endif

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

        // We need to do the actual scaling in between reading the exif data above and writing it below,
        // since we might be scaling the image in place and thus would overwrite old exif data
        bool success = false;

        QImage img;
        PQCSharedMemory::get().setImage(QImage());
        PQCQLocalServer::get().sendMessage("requestImage", QString("%1\n%2\n%3").arg(sourceFilename).arg(targetSize.width()).arg(targetSize.height()));
        int counter = 0;
        while(img.isNull() && counter < 100) {
            img = PQCSharedMemory::get().getImage();
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
            counter += 1;
        }

        if(canWriteQt) {

            // we don't stop if this fails as we might be able to try again with Magick
            if(img.save(targetFilename, PQCSharedMemory::get().getImageFormatsEnding2QtName().value(suffix).toStdString().c_str(), targetQuality))
                success = true;
            else
                qWarning() << "Scaling image with Qt failed";

        }

        if(!success && canWriteMagick) {

    // imagemagick/graphicsmagick might support it
    #if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)

            // first check whether ImageMagick/GraphicsMagick supports writing this filetype
            bool canproceed = false;
            try {
                QString magick = PQCSharedMemory::get().getImageFormatsEnding2MagickName().value(suffix).at(0);
                Magick::CoderInfo magickCoderInfo(magick.toStdString());
                if(magickCoderInfo.isWritable())
                    canproceed = true;
            } catch(...) {
                // do nothing here
            }

            // yes, it's supported
            if(canproceed) {

                // we scale the image to this tmeporary file and then copy it to the right location
                // converting it straight to the right location can lead to corrupted thumbnails if target folder is the same as source folder
                QString tmpImagePath = PQCConfigFiles::get().CACHE_DIR() + "/temporaryfileforscale" + "." + suffix;
                if(QFile::exists(tmpImagePath))
                    QFile::remove(tmpImagePath);

                try {

                    // first we write the QImage to a temporary file
                    // then we load it into magick and write it to the target file

                    // find unique temporary path
                    QString tmppath = PQCConfigFiles::get().CACHE_DIR() + "/converttmp.ppm";
                    if(QFile::exists(tmppath))
                        QFile::remove(tmppath);

                    img.save(tmppath);

                    // load image and write to target file
                    Magick::Image image;
                    image.magick("PPM");
                    image.read(tmppath.toStdString());

                    image.resize(Magick::Geometry(targetSize.width(), targetSize.height()));

                    image.magick(PQCSharedMemory::get().getImageFormatsEnding2MagickName().value(suffix).at(0).toStdString());
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

    #endif

        }

        if(!success) {
            Q_EMIT scaleCompleted(false);
            return;
        }

    #ifdef PQMEXIV2

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

bool PQCScriptsFileManagement::renameFile(QString dir, QString oldName, QString newName) {

    qDebug() << "args: dir =" << dir;
    qDebug() << "args: oldName =" << oldName;
    qDebug() << "args: newName =" << newName;

    QFile file(dir + "/" + oldName);
    return file.rename(dir + "/" + newName);

}

bool PQCScriptsFileManagement::copyFile(QString filename, QString targetFilename) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: targetFilename =" << targetFilename;

    // if the target is the same as source, then we're done
    if(filename == targetFilename)
        return true;

    // if a file by the target filename already exists, then we need to remove it first
    if(QFileInfo::exists(targetFilename)) {
        if(!QFile::remove(targetFilename)) {
            qWarning() << "ERROR: File existing with this name could not be removed first.";
            return false;
        }
    }

    // copy source file to target filename
    QFile file(filename);
    if(!file.copy(targetFilename)) {
        qWarning() << "ERROR: The file could not be copied to its new location.";
        return false;
    }

    return true;

}

bool PQCScriptsFileManagement::moveFile(QString filename, QString targetFilename) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: targetFilename =" << targetFilename;

    // if the target is the same as source, then we're done
    if(filename == targetFilename)
        return true;

    // if a file by the target filename already exists, then we need to remove it first
    if(QFileInfo::exists(targetFilename)) {
        if(!QFile::remove(targetFilename)) {
            qWarning() << "ERROR: File existing with this name could not be removed first.";
            return false;
        }
    }

    // copy source file to target filename
    QFile file(filename);
    if(!file.copy(targetFilename)) {
        qWarning() << "ERROR: The file could not be copied to its new location.";
        return false;
    }

    if(!file.remove()) {
        qWarning() << "ERROR: The file was successfully copied to new location but the old file could not be removed.";
        return false;
    }

    return true;

}

void PQCScriptsFileManagement::cropImage(QString sourceFilename, QString targetFilename, int uniqueid, QPointF topLeft, QPointF botRight) {

    qDebug() << "args: sourceFilename =" << sourceFilename;
    qDebug() << "args: targetFilename =" << targetFilename;
    qDebug() << "args: uniqueid =" << uniqueid;
    qDebug() << "args: topLeft =" << topLeft;
    qDebug() << "args: botRight =" << botRight;

    QFuture<void> f = QtConcurrent::run([=]() {

        const QString suffix = QFileInfo(sourceFilename).suffix().toLower();
        bool canWriteQt = PQCSharedMemory::get().getImageFormatsEnding2QtName().contains(suffix);
        bool canWriteMagick = PQCSharedMemory::get().getImageFormatsEnding2MagickName().contains(suffix);

        if(!canWriteQt && !canWriteMagick) {
            qWarning() << "ERROR: file not supported for cropping:" << sourceFilename;
            Q_EMIT cropCompleted(false);
            return;
        }

        bool success = false;

        // create cropped QImage
        QImage img;
        PQCSharedMemory::get().setImage(QImage());
        PQCQLocalServer::get().sendMessage("requestImage", QString("%1\n-1\n-1").arg(sourceFilename));
        int counter = 0;
        while(img.isNull() && counter < 100) {
            img = PQCSharedMemory::get().getImage();
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
            counter += 1;
        }

        QRect rect(img.width()*topLeft.x(), img.height()*topLeft.y(),
                   img.width()*(botRight.x()-topLeft.x()), img.height()*(botRight.y()-topLeft.y()));
        QImage croppedImg = img.copy(rect);

        if(canWriteQt) {

            // we don't stop if this fails as we might be able to try again with Magick
            if(croppedImg.save(targetFilename, PQCSharedMemory::get().getImageFormatsEnding2QtName().value(suffix).toStdString().c_str(), -1))
                success = true;
            else
                qWarning() << "Cropping image with Qt failed";

        }

        if(!success && canWriteMagick) {

            // imagemagick/graphicsmagick might support it
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)

            // first check whether ImageMagick/GraphicsMagick supports writing this filetype
            bool canproceed = false;
            try {
                QString magick = PQCSharedMemory::get().getImageFormatsEnding2MagickName().value(suffix).at(0);
                Magick::CoderInfo magickCoderInfo(magick.toStdString());
                if(magickCoderInfo.isWritable())
                    canproceed = true;
            } catch(...) {
                // do nothing here
            }

            // yes, it's supported
            if(canproceed) {

                // we scale the image to this tmeporary file and then copy it to the right location
                // converting it straight to the right location can lead to corrupted thumbnails if target folder is the same as source folder
                QString tmpImagePath = PQCConfigFiles::get().CACHE_DIR() + "/temporaryfileforcrop" + "." + suffix;
                if(QFile::exists(tmpImagePath))
                    QFile::remove(tmpImagePath);

                try {

                    // first we write the QImage to a temporary file
                    // then we load it into magick and write it to the target file

                    // find unique temporary path
                    QString tmppath = PQCConfigFiles::get().CACHE_DIR() + "/converttmp.ppm";
                    if(QFile::exists(tmppath))
                        QFile::remove(tmppath);

                    croppedImg.save(tmppath);

                    // load image and write to target file
                    Magick::Image image;
                    image.magick("PPM");
                    image.read(tmppath.toStdString());

                    image.magick(PQCSharedMemory::get().getImageFormatsEnding2MagickName().value(suffix).at(0).toStdString());
                    image.write(tmpImagePath.toStdString());

                    // remove temporary file
                    QFile::remove(tmppath);

                    // copy result to target destination
                    QFile::copy(tmpImagePath, targetFilename);
                    QFile::remove(tmpImagePath);

                    // success!
                    success = true;

                } catch(Magick::Exception &) { }

            } else
                qDebug() << "Writing format not supported by Magick";

#endif

        }

        Q_EMIT cropCompleted(success);

    });

}

void PQCScriptsFileManagement::recordAction(QString action, QVariantList args) {

    if(action == "trash")
        undoTrash.push_back(args);
    else
        qWarning() << "Unknown action:" << action;

}

QString PQCScriptsFileManagement::undoLastAction(QString action) {

    qDebug() << "args: action =" << action;

    if(action == "trash") {

        if(undoTrash.isEmpty())
            return "";

        QVariantList act = undoTrash.takeLast();

        QFile origFile(act.at(0).toString());
        QFile delFile(act.at(1).toString());

        QFileInfo info(act.at(1).toString());
        QFile infoFile(QDir::cleanPath(info.absolutePath() + "/../info/" + info.fileName() + ".trashinfo"));

        if(origFile.exists()) {

            // re-add action to list
            undoTrash.push_back(act);

            return QString("-%1").arg(tr("File with original filename exists already", "filemanagement"));

        }

        if(delFile.rename(origFile.fileName())) {

            qDebug() << QString("Successfully restored file '%1' to '%2'").arg(act.at(1).toString(),act.at(0).toString());

            PQCFileFolderModelCPP::get().setFileInFolderMainView(act.at(0).toString());

            if(!infoFile.remove()) {
                qWarning() << "Failed to remove .trashinfo file";
            }

            return tr("File restored from Trash", "filemanagement");

        }

        // re-add action to list
        undoTrash.push_back(act);

        return QString("-%1: %2").arg(tr("Failed to recover file"), act.at(0).toString());

    }

    return QString("-%1: %2").arg(tr("Unknown action"), action);

}

// 0 := cancel
// 1 := trash
// 2 := delete permanently
int PQCScriptsFileManagement::askForDeletion() {

    QMessageBox box;
    box.setModal(true);
    box.setWindowModality(Qt::ApplicationModal);
    box.setWindowTitle(tr("Delete?"));
    box.setText(tr("Are you sure you want to delete this file?"));
    box.setInformativeText(tr("You can either move the file to trash (default) or delete it permanently."));

    QAbstractButton* butTrash = box.addButton(tr("Move to trash"), QMessageBox::AcceptRole);
    QAbstractButton* butPerma = box.addButton(tr("Delete permanently"), QMessageBox::AcceptRole);
    box.addButton(tr("Cancel"), QMessageBox::RejectRole);

    QFont ft = butTrash->font();
    ft.setBold(true);
    butTrash->setFont(ft);

    box.exec();

    if(box.clickedButton() == butTrash)
        return 1;
    else if(box.clickedButton() == butPerma)
        return 2;

    return 0;

}
