#ifndef OPENFILE_H
#define OPENFILE_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QIcon>
#include <QtDebug>
#include <QtXml/QDomDocument>
#include <QUrl>
#include <thread>
#include "../../logger.h"
#include "../../settings/fileformats.h"

#if (QT_VERSION >= QT_VERSION_CHECK(5, 4, 0))
#include <QStorageInfo>
#endif

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
	void addToUserPlaces(QString path);

signals:
	void userPlacesUpdated();

private:
	FileFormats *formats;
	QFileSystemWatcher *watcher;

private slots:
	void updateUserPlaces() {
		emit userPlacesUpdated();
		recheckFile();
	}
	void recheckFile() {
		if(QFile(QString(DATA_DIR) + "/user-places.xbel").exists())
			watcher->addPath(QString(DATA_DIR) + "/user-places.xbel");
		else
			QTimer::singleShot(1000,this,SLOT(recheckFile()));
	}

};


#endif // OPENFILE_H
