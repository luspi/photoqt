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
