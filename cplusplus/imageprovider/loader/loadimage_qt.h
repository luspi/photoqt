#ifndef LOADIMAGE_QT_H
#define LOADIMAGE_QT_H

#include <QFile>
#include <QImage>
#include <QImageReader>
#include <QtSvg>

#include "../../logger.h"
#include "errorimage.h"

#ifdef EXIV2
#include <exiv2/image.hpp>
#include <exiv2/exif.hpp>
#endif

class LoadImageQt {

public:

	static QImage load(QString filename, QSize maxSize, QString exifrotation) {

		// For reading SVG files
		QSvgRenderer svg;
		QPixmap svg_pixmap;

		// For all other supported file types
		QImageReader reader;

		// Return image
		QImage img;

		QSize origSize;

		// Suffix, for easier access later-on
		QString suffix = QFileInfo(filename).suffix().toLower();

		if(suffix == "svg") {

			// Loading SVG file
			svg.load(filename);

			// Invalid vector graphic
			if(!svg.isValid()) {
				LOG << DATE << "reader svg - Error: invalid svg file" << std::endl;
				return ErrorImage::load("The file doesn't contain a valid vector graphic");
			}

			// Render SVG into pixmap
			svg_pixmap = QPixmap(svg.defaultSize());
			svg_pixmap.fill(Qt::transparent);
			QPainter painter(&svg_pixmap);
			svg.render(&painter);

			// Store the width/height for later use
			origSize = svg.defaultSize();

		} else {

			// Setting QImageReader
			reader.setFileName(filename);

			// Store the width/height for later use
			origSize = reader.size();

			// Sometimes the size returned by reader.size() is <= 0 (observed for, e.g., .jp2 files)
			// -> then we need to load the actual image to get dimensions
			if(origSize.width() <= 0 || origSize.height() <= 0) {
				LOG << DATE << "imagereader qt - Error: failed to read origsize" << std::endl;
				QImageReader r;
				r.setFileName(filename);
				origSize = r.read().size();
			}

		}

		// Store origSize in file for later detection
		QFile sizes(QString(CACHE_DIR) + "/imagesizes");
		if(sizes.open(QIODevice::ReadWrite)) {
			QTextStream in(&sizes);
			QString cont = in.readAll();
			sizes.close();
			if(!cont.contains(filename + "=")) {
				if(sizes.open(QIODevice::WriteOnly | QIODevice::Append)) {
					QTextStream out(&sizes);
					out << QString("%1=%2x%3\n").arg(QString(filename)).arg(origSize.width()).arg(origSize.height());
					sizes.close();
				}
			}
		}


		int dispWidth = origSize.width();
		int dispHeight = origSize.height();

		double q;

		if(dispWidth > maxSize.width()) {
				q = maxSize.width()/(dispWidth*1.0);
				dispWidth *= q;
				dispHeight *= q;
		}

		// If thumbnails are kept visible, then we need to subtract their height from the absolute height otherwise they overlap with the main image
		if(dispHeight > maxSize.height()) {
			q = maxSize.height()/(dispHeight*1.0);
			dispWidth *= q;
			dispHeight *= q;
		}

		// Finalise SVG files
		if(suffix == "svg") {

			// Convert pixmap to image
			img = svg_pixmap.toImage();

		} else {

			// Scale imagereader (if not zoomed)
			if(maxSize.width() != -1)
				reader.setScaledSize(QSize(dispWidth,dispHeight));

	#if QT_VERSION >= 0x050500

			if(exifrotation == "Always")
				reader.setAutoTransform(true);

	#endif

			// Eventually load the image
			img = reader.read();


	#if defined(EXIV2) && QT_VERSION < 0x050500

			// If this setting is enabled, then we check at image load for the Exif rotation tag
			// and change the image accordingly
			if(exifrotation == "Always") {

				// Known formats by Exiv2
				QStringList formats;
				formats << "jpeg" << "jpg" << "tif" << "tiff"
					<< "png" << "psd" << "jpeg2000" << "jp2"
					<< "j2k" << "jpc" << "jpf" << "jpx"
					<< "jpm" << "mj2" << "bmp" << "bitmap"
					<< "gif" << "tga";

				if(formats.contains(QFileInfo(filename).suffix().toLower().trimmed())) {

					// Obtain metadata
					Exiv2::Image::AutoPtr meta;
					try {
						meta  = Exiv2::ImageFactory::open(filename.toStdString());
						meta->readMetadata();
						Exiv2::ExifData &exifData = meta->exifData();

						// We only need this one key
						Exiv2::ExifKey k("Exif.Image.Orientation");
						Exiv2::ExifData::const_iterator it = exifData.findKey(k);

						// If it exists
						if(it != exifData.end()) {

							// Get its value and analyse it
							QString val = QString::fromStdString(Exiv2::toString(it->value()));

							bool flipHor = false;
							int rotationDeg = 0;
							// 1 = No rotation/flipping
							if(val == "1")
								rotationDeg = 0;
							// 2 = Horizontally Flipped
							if(val == "2") {
								rotationDeg = 0;
								flipHor = true;
							// 3 = Rotated by 180 degrees
							} else if(val == "3")
								rotationDeg = 180;
							// 4 = Rotated by 180 degrees and flipped horizontally
							else if(val == "4") {
								rotationDeg = 180;
								flipHor = true;
							// 5 = Rotated by 270 degrees and flipped horizontally
							} else if(val == "5") {
								rotationDeg = 270;
								flipHor = true;
							// 6 = Rotated by 270 degrees
							} else if(val == "6")
								rotationDeg = 270;
							// 7 = Flipped Horizontally and Rotated by 90 degrees
							else if(val == "7") {
								rotationDeg = 90;
								flipHor = true;
							// 8 = Rotated by 90 degrees
							} else if(val == "8")
								rotationDeg = 90;

							// Perform some rotation
							if(rotationDeg != 0) {
								QTransform transform;
								transform.rotate(-rotationDeg);
								img = img.transformed(transform);
							}
							// And flip image
							if(flipHor)
								img = img.mirrored(true,false);

							// Depending on our rotation, we might need to adjust the image dimensions here accordingly
							if(img.width() != reader.scaledSize().width() && maxSize.width() != -1) {
								img = img.scaledToHeight(dispHeight);
							}

						}
					} catch (Exiv2::Error& e) {
						LOG << DATE << "reader qt - ERROR reading exiv data (caught exception): " << e.what() << std::endl;
					}

				}

			}

	#endif

			// If an error occured
			if(img.isNull()) {
				QString err = reader.errorString();
				LOG << DATE << "reader qt - Error: file failed to load: " << err.toStdString() << std::endl;
				LOG << DATE << "Filename: " << filename.toStdString() << std::endl;
				return ErrorImage::load(err);
			}

		}

		return img;

	}

};

#endif // LOADIMAGE_QT_H
