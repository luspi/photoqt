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

//        if(verbose) std::clog << "scale: image format supported by exiv2" << NL;

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

	filename = QByteArray::fromPercentEncoding(filename.toUtf8());

#ifdef Q_OS_LINUX

	if(trash) {

//        if(verbose) std::clog << "fhd: Move to trash" << NL;

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
				baseTrash = QString(qgetenv("XDG_DATA_HOME"));
				if(baseTrash.trimmed() == "") baseTrash = QDir::homePath() + "/.local/share";
				baseTrash += "/Trash/";

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

			// If there exists already a file with that name, we simply append the next higher number (sarting at 1)
			QFile ensure(trashFile);
			int j = 1;
			while(ensure.exists()) {
				trashFile = QFileInfo(trashFile).absolutePath() + "/" + QFileInfo(trashFile).baseName() + QString(" %1.").arg(j) + QFileInfo(trashFile).completeSuffix();
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

//        if(verbose) LOG << CURDATE << "GetAndDoStuffManipulation: fhd: Hard delete file" << NL;

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

//    if(verbose) LOG << CURDATE << "GetAndDoStuffManipulation: fhd: Delete file" << NL;

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

bool GetAndDoStuffManipulation::renameImage(QString oldfilename, QString newfilename) {

	// The old file
	QFile file(oldfilename);

	// The new filename including full path
	QString newfile = QFileInfo(oldfilename).absolutePath() + "/" + newfilename;

//	if(verbose) LOG << CURDATE << "GetAndDoStuffManipulation: fhd: Rename: " << currentfile.toStdString() << " -> " << newfile.toStdString() << NL;

	// Do renaming (this first check of existence shouldn't be needed but just to be on the safe side)
	if(!QFile(newfile).exists()) {
		if(file.copy(newfile)) {
			if(!file.remove()) {
				LOG << CURDATE << "GetAndDoStuffManipulation: ERROR! Couldn't remove the old filename" << NL;
				return false;
			}
		} else {
			std::cerr << "ERROR! Couldn't rename file" << NL;
			return false;
		}

	}

	return true;

}

void GetAndDoStuffManipulation::copyImage(QString path) {

	// Get new filepath
	QString newpath = QFileDialog::getSaveFileName(0,"Copy Image to...",path,"Image (*." + QFileInfo(path).completeSuffix() + ")");

	// Don't do anything here
	if(newpath.trimmed() == "") return;
	if(newpath == path) return;

	// And copy file
	QFile file(path);
	if(file.copy(newpath)) {
		if(QFileInfo(newpath).absolutePath() == QFileInfo(path).absolutePath())
			emit reloadDirectory(newpath);
	} else
		LOG << CURDATE << "GetAndDoStuffManipulation: ERROR: Couldn't copy file" << NL;

}

void GetAndDoStuffManipulation::moveImage(QString path) {

	// Get new filepath
	QString newpath = QFileDialog::getSaveFileName(0,"Move Image to...",path,"Image (*." + QFileInfo(path).completeSuffix() + ")");

	// Don't do anything here
	if(newpath.trimmed() == "") return;
	if(newpath == path) return;

	// Make sure, that the right suffix is there...
	if(QFileInfo(newpath).completeSuffix().toLower() != QFileInfo(path).completeSuffix().toLower())
		newpath += QFileInfo(newpath).completeSuffix();

	// And move file
	QFile file(path);
	if(file.copy(newpath)) {
		if(!file.remove()) {
			LOG << CURDATE << "GetAndDoStuffManipulation: ERROR: Couldn't remove old file" << NL;
			if(QFileInfo(newpath).absolutePath() == QFileInfo(path).absolutePath())
				emit reloadDirectory(newpath);
		} else {
			if(QFileInfo(newpath).absolutePath() == QFileInfo(path).absolutePath())
				emit reloadDirectory(newpath);
			else
				// A value of true signals, that the file has been moved to a different directory (i.e. "deleted" from current directory)
				reloadDirectory(path,true);
		}

	} else
		LOG << CURDATE << "GetAndDoStuffManipulation: ERROR: Couldn't move file" << NL;

}
