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

#ifndef IMAGEPROVIDEREMPTY_H
#define IMAGEPROVIDEREMPTY_H

#include <QQuickImageProvider>

class ImageProviderEmpty : public QQuickImageProvider {

public:
	explicit ImageProviderEmpty() : QQuickImageProvider(QQuickImageProvider::Image) { }
	~ImageProviderEmpty() { }

	QImage requestImage(const QString &filename_encoded, QSize *size, const QSize &requestedSize) {

		int w = filename_encoded.split("x").at(0).toInt();
		int h = filename_encoded.split("x").at(1).toInt();

		if(w < 5) w  = 100;
		if(h < 5) h  = 100;

		QImage ret(w, h, QImage::Format_ARGB32);
		ret.fill(Qt::transparent);

		return ret;

	}


};


#endif // IMAGEPROVIDEREMPTY_H
