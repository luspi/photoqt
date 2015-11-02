#ifndef IMAGEPROVIDERICON_H
#define IMAGEPROVIDERICON_H

#include <QQuickImageProvider>
#include <QIcon>
#include "../logger.h"


class ImageProviderIcon : public QQuickImageProvider {

public:
	explicit ImageProviderIcon() : QQuickImageProvider(QQuickImageProvider::Pixmap) { }
	~ImageProviderIcon() { }

	QPixmap requestPixmap(const QString &icon, QSize *, const QSize &requestedSize){

		QSize use = requestedSize;

		if(use == QSize(-1,-1)) {
			use.setWidth(300);
			use.setHeight(300);
		}

		return QPixmap(QIcon::fromTheme(icon).pixmap(use));

	}

};

#endif // IMAGEPROVIDERICON_H
