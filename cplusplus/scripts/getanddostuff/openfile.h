#ifndef OPENFILE_H
#define OPENFILE_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QIcon>
#include <QtDebug>
#include <QtXml/QDomDocument>
#include <QUrl>
#include "../../logger.h"
#include "../../settings/fileformats.h"

class GetAndDoStuffOpenFile : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuffOpenFile(QObject *parent = 0);
	~GetAndDoStuffOpenFile();

	int getNumberFilesInFolder(QString path);
	QVariantList getUserPlaces();
	QVariantList getFilesAndFoldersIn(QString path);
	QVariantList getFoldersIn(QString path);
	QVariantList getFilesIn(QString path);
	QVariantList getFilesWithSizeIn(QString path);
	bool isFolder(QString path);
	QString removePrefixFromDirectoryOrFile(QString path);

private:
	FileFormats *formats;

};


#endif // OPENFILE_H
