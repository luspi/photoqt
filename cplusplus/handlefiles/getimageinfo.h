#ifndef GETIMAGEINFO_H
#define GETIMAGEINFO_H

#include <QImageReader>
#include <QFileInfo>
#include <GraphicsMagick/Magick++.h>
#include <QSettings>

class GetImageInfo : public QObject {

	Q_OBJECT

public:
	explicit GetImageInfo(QObject *parent = 0);

	Q_INVOKABLE bool isAnimated(QString path);
	Q_INVOKABLE QSize getImageSize(QString path);

private:
	QImageReader reader;
	QSettings *settings;

};


#endif // GETIMAGEINFO_H
