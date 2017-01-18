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

#ifndef IMAGEPROVIDERHISTOGRAM_H
#define IMAGEPROVIDERHISTOGRAM_H

#include <QQuickImageProvider>
#include <QIcon>
#include <QFile>
#include <QPainter>
#include "imageproviderfull.h"
#include "../logger.h"


class ImageProviderHistogram : public QQuickImageProvider {

public:
	explicit ImageProviderHistogram() : QQuickImageProvider(QQuickImageProvider::Pixmap) { }
	~ImageProviderHistogram() { }

	QPixmap requestPixmap(const QString &fpath, QSize *, const QSize &requestedSize) {

		// Obtain type of histogram
		bool color = false;
		QString tmp = fpath;
		if(tmp.startsWith("color")) {
			color = true;
			tmp = tmp.remove(0,5);
		} else if(tmp.startsWith("grey")) {
			color = false;
			tmp = tmp.remove(0,4);
		}

		// If no path specified, return empty transparent image
		if(tmp.trimmed() == "") {
			QPixmap pix = QPixmap(1,1);
			pix.fill(Qt::transparent);
			return pix;
		}

		bool recalcvalues_filepath = false;
		bool recalcvalues_color = false;
		if(tmp != filepath)
			recalcvalues_filepath = true;
		if(color != colorversion)
			recalcvalues_color = true;
		filepath = tmp;
		colorversion = color;

		// Get width and height
		int w = requestedSize.width();
		int h = requestedSize.height();
		if(w%256 != 0)
			w = (w/256 +1)*256;

		// Get the spacing of the data points
		int interval = w/256;

		if(recalcvalues_filepath || recalcvalues_color) {

			// Retrieve the current image
			if(recalcvalues_filepath) {
				ImageProviderFull *prov = new ImageProviderFull;
				QSize *tmp = new QSize();
				histimg = prov->requestImage(filepath, tmp, QSize());
				delete tmp;
			}

			// Read and store image dimensions
			int wid = histimg.width();
			int hei = histimg.height();

			// Prepare the lists for the levels
			levels_grey.clear();
			levels_red.clear();
			levels_green.clear();
			levels_blue.clear();
			for(int i = 0; i < 256; ++i)
				levels_grey.push_back(0);
			for(int i = 0; i < 256; ++i)
				levels_red.push_back(0);
			for(int i = 0; i < 256; ++i)
				levels_green.push_back(0);
			for(int i = 0; i < 256; ++i)
				levels_blue.push_back(0);

			// Loop over all rows of the image
			for(int i = 0; i < hei; ++i) {

				// Get the pixel data of row i of the image
				QRgb *rowData = (QRgb*)histimg.scanLine(i);

				// Loop over all columns
				for(int j = 0; j < wid; ++j) {

					// Get pixel data of pixel at column j in row i
					QRgb pixelData = rowData[j];

					// Get RGB values
					int red = qRed(pixelData);
					int green = qGreen(pixelData);
					int blue = qBlue(pixelData);

					// Add a pixel at current gray level
					if(!colorversion) {
						// Compute the gray level
						int gray_level = qGray(red,green,blue);
						++levels_grey[gray_level];
					} else {
						++levels_red[red];
						++levels_green[green];
						++levels_blue[blue];
					}

				}

			}

			// Figure out the greatest value for normalisation
			greatestvalue = 0;
			if(!colorversion) {
				for(int i = 0; i < 256; ++i)
					if(levels_grey[i] > greatestvalue)
						greatestvalue = levels_grey[i];
			} else {
				for(int i = 0; i < 256; ++i)
					if(levels_red[i] > greatestvalue)
						greatestvalue = levels_red[i];
				for(int i = 0; i < 256; ++i)
					if(levels_green[i] > greatestvalue)
						greatestvalue = levels_green[i];
				for(int i = 0; i < 256; ++i)
					if(levels_blue[i] > greatestvalue)
						greatestvalue = levels_blue[i];
			}

		}

		// Set up the needed polygons for filling them with color
		// This has to ALWAYS been done even if only the size changed, as then the interval changes, too
		polyGREY.clear();
		polyRED.clear();
		polyGREEN.clear();
		polyBLUE.clear();
		if(!colorversion) {
			polyGREY << QPoint(0,h);
			for(int i = 0; i < 256; ++i)
				polyGREY << QPoint(i*interval,h*(1-((double)levels_grey[i]/(double)greatestvalue)));
			polyGREY << QPoint(w,h);
		} else {
			polyRED << QPoint(0,h);
			for(int i = 0; i < 256; ++i)
				polyRED << QPoint(i*interval,h*(1-((double)levels_red[i]/(double)greatestvalue)));
			polyRED << QPoint(w,h);
			polyGREEN << QPoint(0,h);
			for(int i = 0; i < 256; ++i)
				polyGREEN << QPoint(i*interval,h*(1-((double)levels_green[i]/(double)greatestvalue)));
			polyGREEN << QPoint(w,h);
			polyBLUE << QPoint(0,h);
			for(int i = 0; i < 256; ++i)
				polyBLUE << QPoint(i*interval,h*(1-((double)levels_blue[i]/(double)greatestvalue)));
			polyBLUE << QPoint(w,h);
		}

		// Create pixmap...
		QPixmap pix(w,h);
		// ... and fill it with transparent color
		pix.fill(QColor(0,0,0,0));

		// Start painter on return pixmap
		QPainter paint(&pix);

		// set lightly grey colored pen
		paint.setPen(QColor(255,255,255,50));

		// draw outside rectangle
		paint.drawRect(1,1,w-2,h-2);

		// draw mesh lines
		int verticallines = 10;
		int horizontallines = 5;
		for(int i = 0; i < verticallines; ++i)
			paint.drawLine(QPointF((i+1)*(w/(verticallines+1)), 0), QPointF((i+1)*(w/(verticallines+1)), h));
		for(int i = 0; i < horizontallines; ++i)
			paint.drawLine(QPointF(0, (i+1)*(h/(horizontallines+1))), QPointF(w, (i+1)*(h/(horizontallines+1))));

		if(!colorversion) {

			// set pen color
			paint.setPen(QPen(QColor(50,50,50,255),2));
			// draw values
			paint.drawPolygon(polyGREY);
			QPainterPath pathGREY;
			pathGREY.addPolygon(polyGREY);
			paint.fillPath(pathGREY,QColor(150,150,150,180));

		} else {

			// draw red part
			paint.setPen(QPen(QColor(50,50,50,255),2));
			paint.drawPolygon(polyRED);
			QPainterPath pathRED;
			pathRED.addPolygon(polyRED);
			paint.fillPath(pathRED,QColor(255,0,0,120));

			// draw green part
			paint.setPen(QPen(QColor(50,50,50,255),2));
			paint.drawPolygon(polyGREEN);
			QPainterPath pathGREEN;
			pathGREEN.addPolygon(polyGREEN);
			paint.fillPath(pathGREEN,QColor(0,255,0,120));

			// draw blue part
			paint.setPen(QPen(QColor(50,50,50,255),2));
			paint.drawPolygon(polyBLUE);
			QPainterPath pathBLUE;
			pathBLUE.addPolygon(polyBLUE);
			paint.fillPath(pathBLUE,QColor(0,0,255,120));

		}

		paint.end();

		return pix;

	}

private:
	QList<int> levels_grey;
	QList<int> levels_red;
	QList<int> levels_green;
	QList<int> levels_blue;
	QPolygon polyGREY;
	QPolygon polyRED;
	QPolygon polyGREEN;
	QPolygon polyBLUE;
	QString filepath;
	bool colorversion;
	QImage histimg;
	int greatestvalue;

};


#endif
