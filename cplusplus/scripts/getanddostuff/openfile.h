#ifndef OPENFILE_H
#define OPENFILE_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QStorageInfo>
#include <QIcon>
#include <QtDebug>
#include <QtXml/QDomDocument>
#include <QUrl>
#include <thread>
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
	void addToUserPlaces(QString path);

signals:
	void userPlacesUpdated();

private:
	FileFormats *formats;
	QFileSystemWatcher *watcher;

private slots:
	void updateUserPlaces() {
		emit userPlacesUpdated();
		QFileInfo checkFile(QDir::homePath() + "/.local/share/user-places.xbel");
		while(!checkFile.exists())
			std::this_thread::sleep_for(std::chrono::milliseconds(10));
		watcher->addPath(QDir::homePath() + "/.local/share/user-places.xbel");
	}

};


#endif // OPENFILE_H
