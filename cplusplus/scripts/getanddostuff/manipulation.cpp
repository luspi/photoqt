#include "manipulation.h"

GetAndDoStuffManipulation::GetAndDoStuffManipulation(QObject *parent) : QObject(parent) { }
GetAndDoStuffManipulation::~GetAndDoStuffManipulation() { }

bool GetAndDoStuffManipulation::canBeScaled(QString filename) {

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

bool GetAndDoStuffManipulation::scaleImage(QString filename, int width, int height, int quality, QString newfilename) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffManipulation::scaleImage() - " << filename.toStdString() << " / " << width << " / " << height << " / " << quality << " / " << newfilename.toStdString() << NL;

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

#ifdef EXIV2

    // This will store all the exif data
    Exiv2::ExifData exifData;
    bool gotExifData = false;

    if(formats.contains(QFileInfo(filename).suffix().toLower()) && formats.contains(QFileInfo(newfilename).suffix().toLower())) {

        if(qgetenv("PHOTOQT_DEBUG") == "yes") std::clog << "scale: image format supported by exiv2" << NL;

        try {

            // Open image for exif reading
            Exiv2::Image::AutoPtr image_read = Exiv2::ImageFactory::open(filename.toStdString());

            if(image_read.get() != 0) {

                // YAY, WE FOUND SOME!!!!!
                gotExifData = true;

                // read exif
                image_read->readMetadata();
                exifData = image_read->exifData();

                // Update dimensions
                exifData["Exif.Photo.PixelXDimension"] = int32_t(width);
                exifData["Exif.Photo.PixelYDimension"] = int32_t(height);

            }

        }

        catch (Exiv2::Error& e) {
            std::cerr << "ERROR [scale]: reading exif data (caught exception): " << e.what() << NL;
        }

    } else {
        std::cerr << "ERROR [scale]: image format NOT supported by exiv2" << NL;
        return false;
    }


#endif

    // We need to do the actual scaling in between reading the exif data above and writing it below,
    // since we might be scaling the image in place and thus would overwrite old exif data
    QImageReader reader(filename);
    reader.setScaledSize(QSize(width,height));
    QImage img = reader.read();
    if(!img.save(newfilename,0,quality)) {
        std::cerr << "ERROR [scale]: Unable to save file";
        return false;
    }

#ifdef EXIV2

    // We don't need to check again, if both files are actually supported formats, since if either one isn't supported, this bool cannot be true
    if(gotExifData) {

        try {

            // And write exif data to new image file
            Exiv2::Image::AutoPtr image_write = Exiv2::ImageFactory::open(newfilename.toStdString());
            image_write->setExifData(exifData);
            image_write->writeMetadata();

        }

        catch (Exiv2::Error& e) {
            std::cerr << "ERROR [scale]: writing exif data (caught exception): " << e.what() << NL;
        }

    }

#endif

    return true;

}


void GetAndDoStuffManipulation::deleteImage(QString filename, bool trash) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffManipulation::deleteImage() - " << filename.toStdString() << " / " << trash << NL;

    filename = QByteArray::fromPercentEncoding(filename.toUtf8());

#ifdef Q_OS_LINUX

    if(trash) {

        if(qgetenv("PHOTOQT_DEBUG") == "yes") std::clog << "fhd: Move to trash" << NL;

        // The file to delete
        QFile f(filename);

        // Of course we only proceed if the file actually exists
        if(f.exists()) {

            // Create the meta .trashinfo file
            QString info = "[Trash Info]\n";
            info += "Path=" + QUrl(filename).toEncoded() + "\n";
            info += "DeletionDate=" + QDateTime::currentDateTime().toString("yyyy-MM-ddThh:mm:ss");

            // The base patzh for the Trah (files on external devices  use the external device for Trash)
            QString baseTrash = "";

            // If file lies in the home directory
            if(QFileInfo(filename).absoluteFilePath().startsWith(QDir::homePath())) {

                // Set the base path and make sure all the dirs exist
                baseTrash = ConfigFiles::GENERIC_DATA_DIR() + "/Trash/";

                if(!QDir(baseTrash).exists())
                    QDir().mkpath(baseTrash);
                if(!QDir(baseTrash + "files").exists())
                    QDir().mkdir(baseTrash + "files");
                if(!QDir(baseTrash + "info").exists())
                    QDir().mkdir(baseTrash + "info");
            } else {
                // Set the base path and make sure all the dirs exist
                baseTrash = "/" + filename.split("/").at(1) + "/" + filename.split("/").at(2) + QString("/.Trash-%1/").arg(getuid());
                if(!QDir(baseTrash).exists())
                    QDir().mkdir(baseTrash);
                if(!QDir(baseTrash + "files").exists())
                    QDir().mkdir(baseTrash + "files");
                if(!QDir(baseTrash + "info").exists())
                    QDir().mkdir(baseTrash + "info");

            }

            // that's the new trash file
            QString trashFile = baseTrash + "files/" + QUrl::toPercentEncoding(QFileInfo(f).fileName(),""," ");
            QString backupTrashFile = trashFile;

            // If there exists already a file with that name, we simply append the next higher number (sarting at 1)
            QFile ensure(trashFile);
            int j = 1;
            while(ensure.exists()) {
                trashFile = backupTrashFile + QString(" (%1)").arg(j++);
                ensure.setFileName(trashFile);
            }

            // Copy the file to the Trash
            if(f.copy(trashFile)) {

                // And remove the old file
                if(!f.remove())
                    LOG << CURDATE << "GetAndDoStuffManipulation: ERROR: Old file couldn't be removed!" << NL;

                // Write the .trashinfo file
                QFile i(baseTrash + "info/" + QFileInfo(trashFile).fileName() + ".trashinfo");
                if(i.open(QIODevice::WriteOnly)) {
                    QTextStream out(&i);
                    out << info;
                    i.close();
                } else
                    LOG << CURDATE << "GetAndDoStuffManipulation: ERROR: *.trashinfo file couldn't be created!" << NL;

            } else
                LOG << CURDATE << "GetAndDoStuffManipulation: ERROR: File couldn't be deleted (moving file failed)" << NL;

        } else
            LOG << CURDATE << "GetAndDoStuffManipulation: ERROR: File '" << filename.toStdString() << "' doesn't exist...?" << NL;

    } else {

        if(qgetenv("PHOTOQT_DEBUG") == "yes") LOG << CURDATE << "GetAndDoStuffManipulation: fhd: Hard delete file" << NL;

        // current file
        QFile file(filename);

        // Delete it if it exists (if it got here, the file should exist)
        if(file.exists()) {

            file.remove();

        } else {
            LOG << CURDATE << "GetAndDoStuffManipulation: ERROR! File '" << filename.toStdString() << "' doesn't exist...?" << NL;
        }

    }

#else

    if(qgetenv("PHOTOQT_DEBUG") == "yes") LOG << CURDATE << "GetAndDoStuffManipulation: fhd: Delete file" << NL;

    // current file
    QFile file(filename);

    // Delete it if it exists (if it got here, the file should exist)
    if(file.exists()) {

        file.remove();

    } else {
        LOG << CURDATE << "GetAndDoStuffManipulation: ERROR! File doesn't exist...?" << NL;
    }


#endif

}

void GetAndDoStuffManipulation::copyImage(QString imagePath, QString destinationPath) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffManipulation::copyImage() - " << imagePath.toStdString() << " / " << destinationPath.toStdString() << NL;

    if(destinationPath.startsWith("file:/"))
        destinationPath = destinationPath.remove(0,6);
#ifdef Q_OS_WIN
    while(destinationPath.startsWith("/"))
        destinationPath = destinationPath.remove(0,1);
#endif

    // Don't do anything here
    if(destinationPath.trimmed() == "") return;
    if(destinationPath == imagePath) return;

    // And copy file
    QFile file(imagePath);
    if(file.copy(destinationPath)) {
        if(QFileInfo(destinationPath).absolutePath() == QFileInfo(imagePath).absolutePath())
            emit reloadDirectory(destinationPath);
    } else
        LOG << CURDATE << "GetAndDoStuffManipulation: ERROR: Couldn't copy file" << NL;

}

void GetAndDoStuffManipulation::moveImage(QString imagePath, QString destinationPath) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffManipulation::moveImage() - " << imagePath.toStdString() << " / " << destinationPath.toStdString() << NL;

    if(destinationPath.startsWith("file:/"))
        destinationPath = destinationPath.remove(0,6);
#ifdef Q_OS_WIN
    while(destinationPath.startsWith("/"))
        destinationPath = destinationPath.remove(0,1);
#endif

    // Don't do anything here
    if(destinationPath.trimmed() == "") return;
    if(destinationPath == imagePath) return;

    // Make sure, that the right suffix is there...
    if(QFileInfo(destinationPath).completeSuffix().toLower() != QFileInfo(imagePath).completeSuffix().toLower())
        destinationPath += QFileInfo(imagePath).completeSuffix();

    // And move file
    QFile file(imagePath);
    if(file.copy(destinationPath)) {
        if(!file.remove()) {
            LOG << CURDATE << "GetAndDoStuffManipulation: ERROR: Couldn't remove old file" << NL;
            if(QFileInfo(destinationPath).absolutePath() == QFileInfo(imagePath).absolutePath())
                emit reloadDirectory(destinationPath);
        } else {
            if(QFileInfo(destinationPath).absolutePath() == QFileInfo(imagePath).absolutePath())
                emit reloadDirectory(destinationPath);
            else
                // A value of true signals, that the file has been moved to a different directory (i.e. "deleted" from current directory)
                reloadDirectory(imagePath,true);
        }

    } else
        LOG << CURDATE << "GetAndDoStuffManipulation: ERROR: Couldn't move file" << NL;

}

QString GetAndDoStuffManipulation::getImageBaseName(QString imagePath) {

    return QFileInfo(imagePath).baseName();

}
