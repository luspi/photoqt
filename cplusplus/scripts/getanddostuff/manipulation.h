#ifndef GETANDDOSTUFFMANIPLULATION_H
#define GETANDDOSTUFFMANIPLULATION_H

#include <unistd.h>
#include <iostream>
#include <QObject>
#include <QStringList>
#include <QFileInfo>
#include <QImageReader>
#include <QUrl>
#include <QDateTime>
#include <QDir>
#include <QTextStream>
#include <QFileDialog>
#include "../../logger.h"

#ifdef EXIV2
#include <exiv2/image.hpp>
#include <exiv2/exif.hpp>
#endif

class GetAndDoStuffManipulation : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuffManipulation(QObject *parent = 0);
	~GetAndDoStuffManipulation();

	bool canBeScaled(QString filename);
	bool scaleImage(QString filename, int width, int height, int quality, QString newfilename);
	void deleteImage(QString filename, bool trash);
	bool renameImage(QString oldfilename, QString newfilename);
	void copyImage(QString path);
	void moveImage(QString path);

signals:
	void reloadDirectory(QString path, bool deleted = false);

};

#endif // GETANDDOSTUFFMANIPLULATION_H
