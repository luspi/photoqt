#include "openfile.h"

GetAndDoStuffOpenFile::GetAndDoStuffOpenFile(QObject *parent) : QObject(parent) {
	formats = new FileFormats;
}
GetAndDoStuffOpenFile::~GetAndDoStuffOpenFile() { }

int GetAndDoStuffOpenFile::getNumberFilesInFolder(QString path) {

	return QDir(path).entryList(QStringList() << "*",QDir::NoDotDot|QDir::Files).length();

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

			QVariantList ele = QVariantList() << "place" << title << location << icon;

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
			}

			QVariantList ele = QVariantList() << "device" << title << location << icon;

			sub_devices.append(ele);

		}

		file.close();

	}


	return sub_places+sub_devices;

}

QVariantList GetAndDoStuffOpenFile::getFilesAndFoldersIn(QString path) {

	QDir dir(path);
	dir.setNameFilters(formats->formatsQtEnabled + formats->formatsQtEnabledExtras + formats->formatsGmEnabled + formats->formatsExtrasEnabled);
	dir.setFilter(QDir::AllDirs|QDir::Files|QDir::NoDotAndDotDot);
	dir.setSorting(QDir::DirsFirst);

	QStringList list = dir.entryList();
	QVariantList ret;
	foreach(QString l, list)
		ret.append(l);

	return ret;

}

bool GetAndDoStuffOpenFile::isFolder(QString path) {
	return !QFileInfo(path).isFile();
}

