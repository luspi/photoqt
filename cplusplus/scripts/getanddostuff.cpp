#include "getanddostuff.h"
#include <QtDebug>
#include <QUrl>

GetAndDoStuff::GetAndDoStuff(QObject *parent) : QObject(parent) {
	settings = new QSettings("photoqt_session");
}

bool GetAndDoStuff::isImageAnimated(QString path) {

	if(!reader.supportedImageFormats().contains(QFileInfo(path).suffix().toLower().toLatin1()))
		return false;

	reader.setFileName(path);
	return reader.supportsAnimation();

}

QSize GetAndDoStuff::getImageSize(QString path) {

	path = path.remove("image://full/");
	path = QUrl::fromPercentEncoding(path.toLatin1());

	if(reader.supportedImageFormats().contains(QFileInfo(path).suffix().toLower().toLatin1())) {
		reader.setFileName(path);
		return reader.size();
	} else {

#ifdef GM
		Magick::Image image;
		image.read(path.toStdString());
		Magick::Geometry geo = image.size();
		QSize s = QSize(geo.width(),geo.height());
		if(s.width() < 2 && s.height() < 2)
			return settings->value("curSize").toSize();
		return s;
#else
		return QSize();
#endif

	}

}

QPoint GetAndDoStuff::getCursorPos() {

	return QCursor::pos();

}

QString GetAndDoStuff::removePathFromFilename(QString path) {

	return QFileInfo(path).fileName();

}

QColor GetAndDoStuff::addAlphaToColor(QString col, int alpha) {

	col = col.remove(0,1);

	bool ok;
	int red = (QString(col.at(0)) + QString(col.at(1))).toUInt(&ok,16);
	int green = (QString(col.at(2)) + QString(col.at(3))).toUInt(&ok,16);
	int blue = (QString(col.at(4)) + QString(col.at(5))).toUInt(&ok,16);

	qDebug() << col << " - " << red << " - " << green << " - " << blue << " - " << alpha;

	return QColor(red, green, blue, alpha);

}

QString GetAndDoStuff::getFilenameQtImage() {

	return QFileDialog::getOpenFileName(0,"Please select image file",QDir::homePath());

}

QStringList GetAndDoStuff::getContextMenu() {

	QFile file(QDir::homePath() + "/.photoqt/contextmenu");

	if(!file.open(QIODevice::ReadOnly)) {
		std::cerr << "ERROR: Can't open contextmenu file" << std::endl;
		return QStringList();
	}

	QTextStream in(&file);

	QStringList all = in.readAll().split("\n");
	int numRow = 0;
	QStringList ret;
	foreach(QString line, all) {
		QString tmp = line;
		if(numRow == 0) {
			ret.append(tmp.remove(0,1));
			ret.append(line.remove(1,line.length()));
			++numRow;
		} else if(numRow == 1) {
			ret.append(line);
			++numRow;
		} else
			numRow = 0;
	}

	return ret;

}

void GetAndDoStuff::saveContextMenu(QJSValue m) {

	QMap<int,QVariantList> adj;

	// We re-order the data (use actual position in list as keys)
	QVariantList l = m.toVariant().toList();
	foreach(QVariant map, l) {
		QVariantMap data = map.toMap();
		adj.insert(data.value("posInView").toInt(),QList<QVariant>() << data.value("binary") << data.value("description") << data.value("quit"));
	}

	// Open file
	QFile file(QDir::homePath() + "/.photoqt/contextmenu");
	if(!file.open(QIODevice::WriteOnly)) {
		std::cerr << "ERROR: Failed to write to contextmenu file" << std::endl;
		return;
	}

	QTextStream out(&file);

	// And save data
	for(int i = 0; i < adj.count(); ++i) {
		QString bin = adj[i][0].toString();
		QString desc = adj[i][1].toString();
		// We need to check for that, as deleting an item otherwise could lead to an empty entry
		if(bin != "" && desc != "") {
			if(i != 0) out << "\n\n";
			out << adj[i][2].toInt() << bin << "\n";
			out << desc;
		}
	}

	file.close();

}

QVariantMap GetAndDoStuff::getShortcuts() {

	QVariantMap ret;

	QFile file(QDir::homePath() + "/.photoqt/shortcuts");
	if(!file.open(QIODevice::ReadOnly)) {
		std::cerr << "ERROR: failed to read shortcuts file" << std::endl;
		return QVariantMap();
	}

	QTextStream in(&file);
	QStringList all = in.readAll().split("\n");
	foreach(QString line, all) {
		if(line.startsWith("Version") || line.trimmed() == "") continue;
		QStringList parts = line.split("::");
		if(parts.length() != 3) {
			std::cerr << "ERROR: invalid shortcuts data: " << line.toStdString() << std::endl;
			continue;
		}
		ret.insert(parts[1],QStringList() << parts[0] << parts[2]);
	}

	return ret;

}

QString GetAndDoStuff::getShortcutFile() {

	QFile file(QDir::homePath() + "/.photoqt/shortcuts");
	if(!file.open(QIODevice::ReadOnly)) {
		std::cerr << "ERROR: Unable to read shortcuts file" << std::endl;
		return "";
	}
	QTextStream in(&file);
	QString all = in.readAll();
	file.close();
	return all;

}

QString GetAndDoStuff::filterOutShortcutCommand(QString combo, QString file) {

	if(!file.contains("::" + combo + "::"))
		return "";

	return file.split("::" + combo + "::").at(1).split("\n").at(0).trimmed();

}

QString GetAndDoStuff::getFilename(QString caption, QString dir, QString filter) {

	dir = dir.replace("\\ ","\\---");
	dir = dir.split(" ").at(0);
	dir = dir.replace("\\---","\\ ");

	return QFileDialog::getOpenFileName(0, caption, dir, filter);

}
