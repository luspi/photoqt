#include "shortcuts.h"

GetAndDoStuffShortcuts::GetAndDoStuffShortcuts(bool usedAtStartup, QObject *parent) : QObject(parent) {

	if(usedAtStartup) {
		watcher = nullptr;
		return;
	}

	// We watch the shortcuts file and inform the ui if it changed (in order to reload the shortcuts)
	watcher = new QFileSystemWatcher;
	setFilesToWatcher();
	connect(watcher, SIGNAL(fileChanged(QString)), this, SLOT(fileChanged()));

}

GetAndDoStuffShortcuts::~GetAndDoStuffShortcuts() {
	delete watcher;
}

void GetAndDoStuffShortcuts::setFilesToWatcher() {
	if(!QFile(CFG_SHORTCUTS_FILE).exists())
		QTimer::singleShot(250, this, SLOT(setFilesToWatcher()));
	else
		watcher->addPath(CFG_SHORTCUTS_FILE);
}

// The shortcutfile has changed
void GetAndDoStuffShortcuts::fileChanged() {

	// Inform ui. We use an actual int, as he value has to change for the on__Changed signal to get triggered
	emit shortcutFileChanged(QTime::currentTime().msecsSinceStartOfDay());

	// Re-add file to watcher
	setFilesToWatcher();

}

QVariantMap GetAndDoStuffShortcuts::getShortcuts() {

	QVariantMap ret;

	QFile file(CFG_SHORTCUTS_FILE);

	if(!file.exists()) {
		// Set-up Map of default shortcuts;
		LOG << DATE << "GetAndDoStuffShortcuts: INFO: Using default shortcuts set" << NL;
		return getDefaultShortcuts();
	}

	if(!file.open(QIODevice::ReadOnly)) {
		LOG << DATE << "GetAndDoStuffShortcuts: ERROR: failed to read shortcuts file" << NL;
		return QVariantMap();
	}

	QTextStream in(&file);
	QStringList all = in.readAll().split("\n");
	foreach(QString line, all) {
		if(line.startsWith("Version") || line.trimmed() == "") continue;
		QStringList parts = line.split("::");
		if(parts.length() != 3) {
			LOG << DATE << "GetAndDoStuffShortcuts: ERROR: invalid shortcuts data: " << line.toStdString() << NL;
			continue;
		}

		bool mouse = false;
		QString combo = parts[1];
		if(combo.startsWith("[M]")) {
			mouse = true;
			combo = combo.remove(0,4).trimmed();
		}
		ret.insert(combo,QStringList() << parts[0] << QByteArray::fromPercentEncoding(parts[2].toUtf8()) << (mouse ? "mouse" : "key"));
	}

	return ret;

}

QVariantMap GetAndDoStuffShortcuts::getDefaultShortcuts() {

	QVariantMap ret;
	ret.insert("O",QStringList() << "0" << "__open" << "key");
	ret.insert("Ctrl+O",QStringList() << "0" << "__open" << "key");
	ret.insert("Right",QStringList() << "0" << "__next" << "key");
	ret.insert("Space",QStringList() << "0" << "__next" << "key");
	ret.insert("Left",QStringList() << "0" << "__prev" << "key");
	ret.insert("Backspace",QStringList() << "0" << "__prev" << "key");

	ret.insert("+",QStringList() << "0" << "__zoomIn" << "key");
	ret.insert("=",QStringList() << "0" << "__zoomIn" << "key");
	ret.insert("Ctrl++",QStringList() << "0" << "__zoomIn" << "key");
	ret.insert("Ctrl+=",QStringList() << "0" << "__zoomIn" << "key");
	ret.insert("-",QStringList() << "0" << "__zoomOut" << "key");
	ret.insert("Ctrl+-",QStringList() << "0" << "__zoomOut" << "key");
	ret.insert("0",QStringList() << "0" << "__zoomReset" << "key");
	ret.insert("1",QStringList() << "0" << "__zoomActual" << "key");
	ret.insert("Ctrl+1",QStringList() << "0" << "__zoomActual" << "key");

	ret.insert("R",QStringList() << "0" << "__rotateR" << "key");
	ret.insert("L",QStringList() << "0" << "__rotateL" << "key");
	ret.insert("Ctrl+0",QStringList() << "0" << "__rotate0" << "key");
	ret.insert("Ctrl+H",QStringList() << "0" << "__flipH" << "key");
	ret.insert("Ctrl+V",QStringList() << "0" << "__flipV" << "key");

	ret.insert("Ctrl+X",QStringList() << "0" << "__scale" << "key");
	ret.insert("Ctrl+E",QStringList() << "0" << "__hideMeta" << "key");
	ret.insert("E",QStringList() << "0" << "__settings" << "key");
	ret.insert("I",QStringList() << "0" << "__about" << "key");
	ret.insert("M",QStringList() << "0" << "__slideshow" << "key");
	ret.insert("Shift+M",QStringList() << "0" << "__slideshowQuick" << "key");
	ret.insert("W",QStringList() << "0" << "__wallpaper" << "key");

	ret.insert("F2",QStringList() << "0" << "__rename" << "key");
	ret.insert("Ctrl+C",QStringList() << "0" << "__copy" << "key");
	ret.insert("Ctrl+M",QStringList() << "0" << "__move" << "key");
	ret.insert("Delete",QStringList() << "0" << "__delete" << "key");

	ret.insert("S",QStringList() << "0" << "__stopThb" << "key");
	ret.insert("Ctrl+R",QStringList() << "0" << "__reloadThb" << "key");
	ret.insert("Escape",QStringList() << "0" << "__hide" << "key");
	ret.insert("Q",QStringList() << "0" << "__close" << "key");
	ret.insert("Ctrl+Q",QStringList() << "0" << "__close" << "key");

	ret.insert("Home",QStringList() << "0" << "__gotoFirstThb" << "key");
	ret.insert("End",QStringList() << "0" << "__gotoLastThb" << "key");

	ret.insert("Ctrl+Wheel Down",QStringList() << "0" << "__zoomOut" << "mouse");
	ret.insert("Ctrl+Wheel Up",QStringList() << "0" << "__zoomIn" << "mouse");
	ret.insert("Ctrl+Middle Button",QStringList() << "0" << "__zoomReset" << "mouse");
	ret.insert("Right Button",QStringList() << "0" << "__showContext" << "mouse");

	return ret;

}

void GetAndDoStuffShortcuts::saveShortcuts(QVariantMap l) {

	QString header = "Version=" + QString::fromStdString(VERSION) + "\n";
	QString keys = "";
	QString mouse = "";

	foreach(QString key, l.keys()) {

		QStringList vals = l[key].toStringList();

		QString cl = QString::number(vals.at(0).toInt());
		QString sh = key;
		QByteArray ds = vals.at(1).toUtf8().toPercentEncoding();

		if(vals.at(2) == "mouse")
			mouse += QString("%1::[M] %2::%3\n").arg(cl).arg(sh).arg(QString(ds));
		else
			keys += QString("%1::%2::%3\n").arg(cl).arg(sh).arg(QString(ds));

	}

	QFile file(CFG_SHORTCUTS_FILE);
	if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
		LOG << DATE << "GetAndDoStuffShortcuts: ERROR: Unable to open shortcuts file for writing/saving" << NL;
		return;
	}

	QTextStream out(&file);
	out << header << keys << mouse;

	file.close();

}

QString GetAndDoStuffShortcuts::getShortcutFile() {

	QFile file(CFG_SHORTCUTS_FILE);
	if(!file.open(QIODevice::ReadOnly)) {
		LOG << DATE << "GetAndDoStuffShortcuts: ERROR: Unable to read shortcuts file" << NL;
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
