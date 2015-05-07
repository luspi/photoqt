#include "getanddostuff.h"
#include <QtDebug>
#include <QUrl>

GetAndDoStuff::GetAndDoStuff(QObject *parent) : QObject(parent) {
	settings = new QSettings("photoqt_session");
}
GetAndDoStuff::~GetAndDoStuff() {
	delete settings;
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

    if(!file.exists()) return setDefaultContextMenuEntries();

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

qint64 GetAndDoStuff::getContextMenuFileModifiedTime() {
	QFileInfo info(QDir::homePath() + "/.photoqt/contextmenu");
	return info.lastModified().toMSecsSinceEpoch();
}

QStringList GetAndDoStuff::setDefaultContextMenuEntries() {

	// These are the possible entries
	QStringList m;
	m << "Edit with Gimp" << "gimp %f"
		<< "Edit with Krita" << "krita %f"
		<< "Edit with KolourPaint" << "kolourpaint %f"
		<< "Open in GwenView" << "gwenview %f"
		<< "Open in showFoto" << "showfoto %f"
		<< "Open in Shotwell" << "shotwell %f"
		<< "Open in GThumb" << "gthumb %f"
		<< "Open in Eye of Gnome" << "eog %f";

	QStringList ret;
	QVariantList forsaving;
	int counter = 0;
	// Check for all entries
	for(int i = 0; i < m.size()/2; ++i) {
		if(checkIfBinaryExists(m[2*i+1])) {
			ret << m[2*i+1] << "0" << m[2*i];
			QVariantMap map;
			map.insert("posInView",counter);
			map.insert("binary",m[2*i+1]);
			map.insert("description",m[2*i]);
			map.insert("quit","0");
			forsaving.append(map);
			++counter;
		}
	}

	saveContextMenu(forsaving);

	return ret;

}

void GetAndDoStuff::saveContextMenu(QJSValue m) {
	saveContextMenu(m.toVariant().toList());
}

void GetAndDoStuff::saveContextMenu(QVariantList l) {

	QMap<int,QVariantList> adj;

	// We re-order the data (use actual position in list as keys), if not deleted
	foreach(QVariant map, l) {
		QVariantMap data = map.toMap();
		// Invalid data can be caused by deletion
		if(data.value("description").isValid())
			adj.insert(data.value("posInView").toInt(),QList<QVariant>() << data.value("binary") << data.value("description") << data.value("quit"));
	}

	// Open file
	QFile file(QDir::homePath() + "/.photoqt/contextmenu");

    if(file.exists() && !file.remove()) {
		std::cerr << "ERROR: Failed to remove old contextmenu file" << std::endl;
		return;
	}

	if(!file.open(QIODevice::WriteOnly)) {
		std::cerr << "ERROR: Failed to write to contextmenu file" << std::endl;
		return;
	}

	QTextStream out(&file);

	QList<int> keys = adj.keys();
	qSort(keys.begin(),keys.end());

	// And save data
	for(int i = 0; i < keys.length(); ++i) {
		int key = keys[i];	// We need to check for the actual keys, as some integers might be skipped (due to deletion)
		QString bin = adj[key][0].toString();
		QString desc = adj[key][1].toString();
		// We need to check for that, as deleting an item otherwise could lead to an empty entry
		if(bin != "" && desc != "") {
			if(i != 0) out << "\n\n";
			out << adj[key][2].toInt() << bin << "\n";
			out << desc;
		}
	}

	file.close();

}

QVariantMap GetAndDoStuff::getShortcuts() {

	QVariantMap ret;

	QFile file(QDir::homePath() + "/.photoqt/shortcuts");

	if(!file.exists()) {
		// Set-up Map of default shortcuts;
		std::cout << "INFO: Using default shortcuts set" << std::endl;
		return getDefaultShortcuts();
	}

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
		ret.insert(parts[1],QStringList() << parts[0] << QByteArray::fromPercentEncoding(parts[2].toUtf8()));
	}

	return ret;

}

QVariantMap GetAndDoStuff::getDefaultShortcuts() {

	QVariantMap ret;
	ret.insert("O",QStringList() << "0" << "__open");
	ret.insert("Ctrl+O",QStringList() << "0" << "__open");
	ret.insert("Right",QStringList() << "0" << "__next");
	ret.insert("Space",QStringList() << "0" << "__next");
	ret.insert("Left",QStringList() << "0" << "__prev");
	ret.insert("Backspace",QStringList() << "0" << "__prev");

	ret.insert("+",QStringList() << "0" << "__zoomIn");
	ret.insert("Ctrl++",QStringList() << "0" << "__zoomIn");
	ret.insert("-",QStringList() << "0" << "__zoomOut");
	ret.insert("Ctrl+-",QStringList() << "0" << "__zoomOut");
	ret.insert("0",QStringList() << "0" << "__zoomReset");
	ret.insert("1",QStringList() << "0" << "__zoomActual");
	ret.insert("Ctrl+1",QStringList() << "0" << "__zoomActual");

	ret.insert("R",QStringList() << "0" << "__rotateR");
	ret.insert("L",QStringList() << "0" << "__rotateL");
	ret.insert("Ctrl+0",QStringList() << "0" << "__rotate0");
	ret.insert("Ctrl+H",QStringList() << "0" << "__flipH");
	ret.insert("Ctrl+V",QStringList() << "0" << "__flipV");

	ret.insert("Ctrl+X",QStringList() << "0" << "__scale");
	ret.insert("Ctrl+E",QStringList() << "0" << "__hideMeta");
	ret.insert("E",QStringList() << "0" << "__settings");
	ret.insert("I",QStringList() << "0" << "__about");
	ret.insert("M",QStringList() << "0" << "__slideshow");
	ret.insert("Shift+M",QStringList() << "0" << "__slideshowQuick");
	ret.insert("W",QStringList() << "0" << "__wallpaper");

	ret.insert("F2",QStringList() << "0" << "__rename");
	ret.insert("Ctrl+C",QStringList() << "0" << "__copy");
	ret.insert("Ctrl+M",QStringList() << "0" << "__move");
	ret.insert("Delete",QStringList() << "0" << "__delete");

	ret.insert("S",QStringList() << "0" << "__stopThb");
	ret.insert("Ctrl+R",QStringList() << "0" << "__reloadThb");
	ret.insert("Escape",QStringList() << "0" << "__hide");
	ret.insert("Q",QStringList() << "0" << "__close");
	ret.insert("Ctrl+Q",QStringList() << "0" << "__close");

	ret.insert("Home",QStringList() << "0" << "__gotoFirstThb");
	ret.insert("End",QStringList() << "0" << "__gotoLastThb");

	ret.insert("[M] Ctrl+Wheel Down",QStringList() << "0" << "__zoomOut");
	ret.insert("[M] Ctrl+Wheel Up",QStringList() << "0" << "__zoomIn");
	ret.insert("[M] Ctrl+Middle Button",QStringList() << "0" << "__zoomReset");
	ret.insert("[M] Right Button",QStringList() << "0" << "__showContext");

	return ret;

}

void GetAndDoStuff::saveShortcuts(QVariantList l) {

	QString header = "Version=" + QString::fromStdString(VERSION) + "\n";
	QString keys = "";
	QString mouse = "";
	foreach(QVariant s, l) {
		QVariantList s_l = s.toList();
		QString cl = QString::number(s_l.at(0).toInt());
		QString sh = (s_l.at(1).toBool() ? "[M] " : "") + s_l.at(2).toString().trimmed();
		QByteArray ds = s_l.at(3).toString().toUtf8().toPercentEncoding();
		if(s_l.at(1).toBool())
			mouse += QString("%1::%2::%3\n").arg(cl).arg(sh).arg(QString(ds));
		else
			keys += QString("%1::%2::%3\n").arg(cl).arg(sh).arg(QString(ds));
	}

	QFile file(QDir::homePath() + "/.photoqt/shortcuts");
    if(file.exists() && !file.remove()) {
		std::cerr << "ERROR: Unable to remove old shortcuts file" << std::endl;
		return;
	}

	if(!file.open(QIODevice::WriteOnly)) {
		std::cerr << "ERROR: Unable to open shortcuts file for writing/saving" << std::endl;
		return;
	}

	QTextStream out(&file);
	out << header << keys << mouse;

	file.close();

}

QString GetAndDoStuff::getShortcutFile() {

	QFile file(QDir::homePath() + "/.photoqt/shortcuts");
	if(!file.open(QIODevice::ReadOnly)) {
		std::cerr << "ERROR: Unable to read shortcuts file" << std::endl;
		return "";
	}
	QTextStream in(&file);
	QString all = QByteArray::fromPercentEncoding(in.readAll().toUtf8());
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

// Search for the file path of the icons in the hicolor theme (used by contextmenu)
QString GetAndDoStuff::getIconPathFromTheme(QString binary) {

	// We go through all the themeSearchPath elements
	for(int i = 0; i < QIcon::themeSearchPaths().length(); ++i) {

		// Setup path (this is the most likely directory) and format (PNG)
		QString path = QIcon::themeSearchPaths().at(i) + "/hicolor/32x32/apps/" + binary.trimmed() + ".png";
		if(QFile(path).exists())
			return "file:" + path;
		else {
			// Also check a smaller version
			path = path.replace("32x32","22x22");
			if(QFile(path).exists())
				return "file:" + path;
			else {
				// And check 24x24, if not in the two before, it most likely is in here (e.g., shotwell on my system)
				path = path.replace("22x22","24x24");
				if(QFile(path).exists())
					return "file:" + path;
			}
		}

		// Do the same checks as above for SVG

		path = path.replace("22x22","32x32").replace(".png",".svg");
		if(QFile(path).exists())
			return "file:" + path;
		else {
			path = path.replace("32x32","22x22");
			if(QFile(path).exists())
				return "file:" + path;
			else {
				path = path.replace("22x22","24x24");
				if(QFile(path).exists())
					return "file:" + path;
			}
		}
	}

	// Nothing found
	return "";

}

bool GetAndDoStuff::checkIfBinaryExists(QString exec) {
	QProcess p;
#if QT_VERSION >= 0x050200
	p.setStandardOutputFile(QProcess::nullDevice());
#endif
	p.start("which " + exec);
	p.waitForFinished();
	return p.exitCode() != 2;
}

void GetAndDoStuff::executeApp(QString exec, QString fname, QString close) {

	QProcess *p = new QProcess;
	exec = exec.replace("%f",'"' + fname + '"');
	exec = exec.replace("%d",'"' + QFileInfo(fname).absoluteDir().absolutePath() + '"');
	p->start(exec);
	while(!p->waitForStarted()) { }

	if(close == "1") qApp->quit();

}
void GetAndDoStuff::openInDefaultFileManager(QString file) {
    QDesktopServices::openUrl(QUrl("file:///" + QFileInfo(file).absolutePath()));
}
