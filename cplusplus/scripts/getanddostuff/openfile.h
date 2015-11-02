#ifndef OPENFILE_H
#define OPENFILE_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QIcon>
#include <QtDebug>
#include <QtXml/QDomDocument>
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
	bool isFolder(QString path);

private:
	FileFormats *formats;

};


#endif // OPENFILE_H
