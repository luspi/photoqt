#include "shortcuts.h"

GetAndDoStuffShortcuts::GetAndDoStuffShortcuts(QObject *parent) : QObject(parent) {

	// We watch the shortcuts file and inform the ui if it changed (in order to reload the shortcuts)
	watcher = new QFileSystemWatcher;
	watcher->addPath(QDir::homePath() + "/.photoqt/shortcuts");
	connect(watcher, SIGNAL(fileChanged(QString)), this, SLOT(fileChanged()));

}

GetAndDoStuffShortcuts::~GetAndDoStuffShortcuts() { }

// The shortcutfile has changed
void GetAndDoStuffShortcuts::fileChanged() {

	// Inform ui. We use an actual int, as he value has to change for the on__Changed signal to get triggered
	emit shortcutFileChanged(QTime::currentTime().msecsSinceStartOfDay());

	// Re-add file to watcher (for more details see watcher in setting.h)
#ifdef C11
	QFileInfo checkFile(QDir::homePath() + "/.photoqt/shortcuts");
	while(!checkFile.exists())
		std::this_thread::sleep_for(std::chrono::milliseconds(10));
#endif
	watcher->addPath(QDir::homePath() + "/.photoqt/shortcuts");

}

QVariantMap GetAndDoStuffShortcuts::getShortcuts() {

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

QVariantMap GetAndDoStuffShortcuts::getDefaultShortcuts() {

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

void GetAndDoStuffShortcuts::saveShortcuts(QVariantList l) {

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

QString GetAndDoStuffShortcuts::getShortcutFile() {

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

QString GetAndDoStuffShortcuts::filterOutShortcutCommand(QString combo, QString file) {

	if(!file.contains("::" + combo + "::"))
		return "";

	return file.split("::" + combo + "::").at(1).split("\n").at(0).trimmed();

}
