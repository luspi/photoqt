#include "openfile.h"

GetAndDoStuffOpenFile::GetAndDoStuffOpenFile(QObject *parent) : QObject(parent) {
	formats = new FileFormats;

	watcher = new QFileSystemWatcher;
	watcher->addPath(QDir::homePath() + "/.local/share/user-places.xbel");
	connect(watcher, SIGNAL(fileChanged(QString)), this, SLOT(updateUserPlaces()));
}
GetAndDoStuffOpenFile::~GetAndDoStuffOpenFile() { }

int GetAndDoStuffOpenFile::getNumberFilesInFolder(QString path) {

	QDir dir(path);
	dir.setNameFilters(formats->formatsQtEnabled + formats->formatsGmEnabled + formats->formatsGmGhostscriptEnabled + formats->formatsExtrasEnabled + formats->formatsUntestedEnabled);
	dir.setFilter(QDir::Files);

	return dir.entryList().length();

}

QVariantList GetAndDoStuffOpenFile::getUserPlaces() {

	QVariantList sub_places;
	QVariantList sub_devices;

	QFile file(QDir::homePath() + "/.local/share/user-places.xbel");
	if(!file.open(QIODevice::ReadOnly)) {
		LOG << DATE << "Can't open ~/.local/share/user-places.xbel file" << std::endl;
		return QVariantList();
	} else {

		QDomDocument doc;
		doc.setContent(&file);

		QDomNodeList bookmarks = doc.elementsByTagName("bookmark");
		for(int i = 0; i < bookmarks.size(); i++) {
			QDomNode n = bookmarks.item(i);

			QString icon = "";
			QString location = n.attributes().namedItem("href").nodeValue();
			QString title = n.firstChildElement("title").text();

			QDomNodeList info = n.firstChildElement("info").childNodes();
			for(int j = 0; j < info.size(); ++j) {
				QDomNode ele_icon = info.item(j).firstChildElement("bookmark:icon");
				if(ele_icon.isNull())
					continue;
				icon = ele_icon.attributes().namedItem("name").nodeValue();
			}

			if(location.startsWith("file://"))
				location = location.remove(0,7);

			QVariantList ele = QVariantList() << "place" << title << location << icon;

			if(QDir(location).exists())
				sub_places.append(ele);

		}

		QDomNodeList separator = doc.elementsByTagName("separator");
		for(int i = 0; i < separator.size(); i++) {
			QDomNode n = separator.item(i);

			QString icon = "";
			QString location = n.attributes().namedItem("href").nodeValue();
			QString title = n.firstChildElement("title").text();

			QDomNodeList info = n.firstChildElement("info").childNodes();
			for(int j = 0; j < info.size(); ++j) {
				QDomNode ele_icon = info.item(j).firstChildElement("bookmark:icon");
				if(ele_icon.isNull())
					continue;
				icon = ele_icon.attributes().namedItem("name").nodeValue();

			if(location.startsWith("file://"))
				location = location.remove(0,7);
			}

			QVariantList ele = QVariantList() << "device" << title << location << icon;

			if(QDir(location).exists())
				sub_devices.append(ele);

		}

		file.close();

	}


	return sub_places+sub_devices;

}

QVariantList GetAndDoStuffOpenFile::getFilesAndFoldersIn(QString path) {

	if(path.startsWith("file:/"))
		path = path.remove(0,6);

	QDir dir(path);
	dir.setNameFilters(formats->formatsQtEnabled + formats->formatsGmEnabled + formats->formatsGmGhostscriptEnabled + formats->formatsExtrasEnabled + formats->formatsUntestedEnabled);
	dir.setFilter(QDir::AllDirs|QDir::Files|QDir::NoDotAndDotDot);
	dir.setSorting(QDir::DirsFirst|QDir::IgnoreCase);

	QStringList list = dir.entryList();
	QVariantList ret;
	foreach(QString l, list)
		ret.append(l);

	return ret;

}

QVariantList GetAndDoStuffOpenFile::getFoldersIn(QString path) {

	if(path.startsWith("file:/"))
		path = path.remove(0,6);

	QDir dir(path);
	dir.setFilter(QDir::AllDirs|QDir::NoDot);
	dir.setSorting(QDir::IgnoreCase);

	QStringList list = dir.entryList();
	QVariantList ret;
	foreach(QString l, list)
		ret.append(l);

	return ret;

}

QVariantList GetAndDoStuffOpenFile::getFilesIn(QString path) {

	if(path.startsWith("file:/"))
		path = path.remove(0,6);

	QDir dir(path);
	dir.setNameFilters(formats->formatsQtEnabled + formats->formatsGmEnabled + formats->formatsGmGhostscriptEnabled + formats->formatsExtrasEnabled + formats->formatsUntestedEnabled + formats->formatsRawEnabled);
	dir.setFilter(QDir::Files);
	dir.setSorting(QDir::IgnoreCase);

	QStringList list = dir.entryList();
	QVariantList ret;
	foreach(QString l, list)
		ret.append(l);

	return ret;

}

QVariantList GetAndDoStuffOpenFile::getFilesWithSizeIn(QString path) {

	if(path.startsWith("file:/"))
		path = path.remove(0,6);

	QDir dir(path);
	dir.setNameFilters(formats->formatsQtEnabled + formats->formatsGmEnabled + formats->formatsGmGhostscriptEnabled + formats->formatsExtrasEnabled + formats->formatsUntestedEnabled + formats->formatsRawEnabled);
	dir.setFilter(QDir::Files);
	dir.setSorting(QDir::IgnoreCase);

	QFileInfoList list = dir.entryInfoList();
	QVariantList ret;
	foreach(QFileInfo l, list) {
		int s = l.size();
		QString size = "";
		if(s <= 1024)
			size = QString::number(s) + " B";
		else if(s <= 1024*1024)
			size = QString::number(qRound(double(s)/1024.0)) + " KB";
		else
			size = QString::number(qRound(100*double(s)/(1024*1024))/100.0) + " MB";
		ret.append(QVariantList() << l.fileName() << size);
	}

	return ret;

}

bool GetAndDoStuffOpenFile::isFolder(QString path) {
	if(path.startsWith("file:/"))
		path = path.remove(0,6);
	QFileInfo info(path);
	return !info.isFile();
}

QString GetAndDoStuffOpenFile::removePrefixFromDirectoryOrFile(QString path) {

	if(path.startsWith("file:/"))
		return path.remove(0,6);

	return path;

}
