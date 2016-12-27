/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef LOADIMAGE_MAGICK_H
#define LOADIMAGE_MAGICK_H

#include <QFile>
#include <QFileInfo>
#include "../../logger.h"
#include "errorimage.h"

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#include "../../scripts/gmimagemagick.h"
#endif

class LoadImageGM {

public:

	LoadImageGM() { }

	QImage load(QString filename, QSize maxSize) {

		#ifdef GM

			GmImageMagick imagemagick;
			QSize origSize;

			// We first read the image into memory
			QFile file(filename);
			if(!file.open(QIODevice::ReadOnly)) {
				LOG << CURDATE << "LoadImageGM: reader gm - ERROR opening file, returning empty image" << NL;
				return QImage();
			}
			char *data = new char[file.size()];
			qint64 s = file.read(data, file.size());

			// A return value of -1 means error
			if (s == -1) {
				delete[] data;
				LOG << CURDATE << "LoadImageGM: reader gm - ERROR reading image file data" << NL;
				return QImage();
			}
			// Read image into blob
			Magick::Blob blob(data, file.size());
			try {

				// Prepare Magick
				QString suf = QFileInfo(filename).suffix().toLower();
				Magick::Image image;
				image = imagemagick.setImageMagick(image,suf);

				// Read image into Magick
				image.read(blob);

				// Scale image if necessary
				if(maxSize.width() != -1) {

					int dispWidth = image.columns();
					int dispHeight = image.rows();

					double q;

					if(dispWidth > maxSize.width()) {
							q = maxSize.width()/(dispWidth*1.0);
							dispWidth *= q;
							dispHeight *= q;
					}
					if(dispHeight > maxSize.height()) {
						q = maxSize.height()/(dispHeight*1.0);
						dispWidth *= q;
						dispHeight *= q;
					}

					// For small images we can use the faster algorithm, as the quality is good enough for that
					if(dispWidth < 300 && dispHeight < 300)
						image.thumbnail(Magick::Geometry(dispWidth,dispHeight));
					else
						image.scale(Magick::Geometry(dispWidth,dispHeight));

				}

				// Write Magick as PNG to memory
				Magick::Blob ob;
				image.type(Magick::TrueColorMatteType);
				image.magick("PNG");
				image.write(&ob);

				// And load PNG from memory into QImage
				const QByteArray imgData((char*)(ob.data()),ob.length());
				QImage img((maxSize.width() > -1 ? maxSize : QSize(4000,3000)), QImage::Format_ARGB32);	// zoomed or not?
				img.loadFromData(imgData);

				// And we're done!
				delete[] data;
				return img;

			} catch(Magick::Exception &error_) {
				delete[] data;
				LOG << CURDATE << "LoadImageGM: reader gm Error: " << error_.what() << NL;
				return ErrorImage::load(QString(error_.what()));
			}

		#endif

			return QImage();

	}

};

#endif // LOADIMAGE_MAGICK_H
