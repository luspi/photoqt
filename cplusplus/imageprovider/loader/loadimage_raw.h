#ifndef LOADIMAGE_RAW_H
#define LOADIMAGE_RAW_H

#include <QFile>
#include <QImage>
#include <QtDebug>
#include "errorimage.h"

#ifdef RAW
#include <libraw/libraw.h>
#endif

class LoadImageRaw {

public:

	static QImage load(QString filename, QSize maxSize) {

#ifdef RAW

		// Later we decide according to thumbnail/image size whether to load thumbnail or half/full image
		bool thumb = false;
		bool half = false;

		// The LibRaw instance
		LibRaw raw;
		raw.recycle();

		// Some settings to improve speed
		// Since we don't care about manipulating RAW images but only want to display
		// them, we can optimise for speed
		raw.imgdata.params.user_qual = 1;
		raw.imgdata.params.use_rawspeed = 1;
		raw.imgdata.params.use_camera_wb = 1;
		raw.imgdata.params.use_auto_wb = 1;

		// Open the RAW image
		int ret = raw.open_file((const char*)(QFile::encodeName(filename)).constData());
		if(ret != LIBRAW_SUCCESS) {
			raw.recycle();
			return ErrorImage::load(QString("LibRaw: failed to run open_file: %1").arg(libraw_strerror(ret)));
		}

		// Depending on the RAW image anf the requested image size, we can opt for the thumbnail or half size if that's enough
		if(raw.imgdata.thumbnail.twidth >= maxSize.width() && raw.imgdata.thumbnail.theight >= maxSize.height()
				&& raw.imgdata.thumbnail.tformat != LIBRAW_THUMBNAIL_UNKNOWN)
			thumb = true;
		else if(raw.imgdata.sizes.iwidth >= maxSize.width()*2 && raw.imgdata.sizes.iheight >= maxSize.height()) {
			half = true;
			raw.imgdata.params.half_size = 1;
		}

		// Unpack the RAW image/thumbnail
		if(thumb) ret = raw.unpack_thumb();
		else ret = raw.unpack();

		if(ret != LIBRAW_SUCCESS) {
			raw.recycle();
			return ErrorImage::load(QString("LibRaw: failed to run %1: %2").arg(thumb ? "unpack_thumb" : "unpack").arg(libraw_strerror(ret)));
		}

		// Post-process image. Not necessary for embedded preview...
		if(!thumb) ret = raw.dcraw_process();

		if (ret != LIBRAW_SUCCESS) {
			raw.recycle();
			return ErrorImage::load(QString("LibRaw: failed to run dcraw_process: %1").arg(libraw_strerror(ret)));
		}

		// Create processed image
		libraw_processed_image_t* img;
		if(thumb) img = raw.dcraw_make_mem_thumb(&ret);
		else img = raw.dcraw_make_mem_image(&ret);


		// This will hold the loaded image data
		QByteArray imgData;


		QImage image;

		// This means, that the structure contains an in-memory image of JPEG file.
		// Only type, data_size and data fields are valid (and nonzero).
		if(img->type == LIBRAW_IMAGE_JPEG) {

			// The return image is loaded from the QByteArray above
			if(!image.loadFromData(img->data, img->data_size, "JPEG")) {
				raw.recycle();
				return ErrorImage::load("Failed to load JPEG data from LibRaw!");
			}

		} else {

			// Create a header and load the image data into QByteArray
			QString header = QString::fromUtf8("P%1\n%2 %3\n%4\n")
					.arg(img->colors == 3 ? QLatin1String("6") : QLatin1String("5"))
					.arg(img->width)
					.arg(img->height)
					.arg((1 << img->bits)-1);
			imgData.append(header.toLatin1());

			if(img->colors == 3)
				imgData.append(QByteArray((const char*)img->data, (int)img->data_size));
			else {
				QByteArray imgData_tmp;
			   // img->colors == 1 (Grayscale) : convert to RGB
				for(int i = 0 ; i < (int)img->data_size ; ++i) {
					for(int j = 0 ; j < 3 ; ++j)
						imgData_tmp.append(img->data[i]);
				}
				imgData.append(imgData_tmp);
			}

			if(imgData.isEmpty()) {
				raw.recycle();
				return ErrorImage::load("Failed to load " + QString(half ? "half preview" : (thumb ? "thumbnail" : "image")) + " from LibRaw!");
			}

			// The return image is loaded from the QByteArray above
			if(!image.loadFromData(imgData)) {
				raw.recycle();
				return ErrorImage::load("Failed to load PPM data from LibRaw!");
			}

		}

		// Store origSize in file for later detection
		QFile sizes(QString(CACHE_DIR) + "/imagesizes");
		if(sizes.open(QIODevice::ReadOnly) || !sizes.exists()) {
			QString cont = "";
			if(sizes.exists()) {
				QTextStream in(&sizes);
				cont = in.readAll();
				sizes.close();
			}
			if(!cont.contains(filename + "=")) {
				QFile outsizes(QString(CACHE_DIR) + "/imagesizes");
				if(outsizes.open(QIODevice::WriteOnly | QIODevice::Append)) {
					QTextStream out(&outsizes);
					out << QString("%1=%2x%3\n").arg(QString(filename)).arg(image.width()).arg(image.height());
					outsizes.close();
				}
			}
		}

		// Clean up memory
		raw.dcraw_clear_mem(img);
		raw.recycle();

		if(maxSize.width() > 5 && maxSize.height() > 5
				&& (image.width() > maxSize.width() || image.height() > maxSize.height()))
			image = image.scaled(maxSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

		return image;

#endif

		return ErrorImage::load("ERROR! PhotoQt was compiled without LibRaw support!");

	}

};


#endif // LOADIMAGE_RAW_H
