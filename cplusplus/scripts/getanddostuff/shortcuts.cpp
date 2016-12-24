#include "shortcuts.h"

GetAndDoStuffShortcuts::GetAndDoStuffShortcuts(bool usedAtStartup, QObject *parent) : QObject(parent) {

	if(usedAtStartup) {
		watcher = nullptr;
		return;
	}

	// We watch the shortcuts file and inform the ui if it changed (in order to reload the shortcuts)
	watcher = new QFileSystemWatcher;
	setFilesToWatcher();
	connect(watcher, SIGNAL(fileChanged(QString)), this, SLOT(fileChanged(QString)));

}

GetAndDoStuffShortcuts::~GetAndDoStuffShortcuts() {
	delete watcher;
}

void GetAndDoStuffShortcuts::setFilesToWatcher() {
	if(!QFile(CFG_KEY_SHORTCUTS_FILE).exists() || !QFile(CFG_MOUSE_SHORTCUTS_FILE).exists())
		QTimer::singleShot(250, this, SLOT(setFilesToWatcher()));
	else
		watcher->addPaths(QStringList() << CFG_KEY_SHORTCUTS_FILE << CFG_MOUSE_SHORTCUTS_FILE);
}

// The shortcutfile has changed
void GetAndDoStuffShortcuts::fileChanged(QString filename) {

	// Inform ui. We use an actual int, as he value has to change for the on__Changed signal to get triggered
	if(filename == CFG_KEY_SHORTCUTS_FILE)
		emit keyShortcutFileChanged(QTime::currentTime().msecsSinceStartOfDay());
	else if(filename == CFG_MOUSE_SHORTCUTS_FILE)
		emit mouseShortcutFileChanged(QTime::currentTime().msecsSinceStartOfDay());

	// Re-add file to watcher
	setFilesToWatcher();

}

QVariantMap GetAndDoStuffShortcuts::getKeyShortcuts() {

	QVariantMap ret;

	QFile file(CFG_KEY_SHORTCUTS_FILE);

	if(!file.exists()) {
		// Set-up Map of default shortcuts;
		LOG << CURDATE << "GetAndDoStuffShortcuts: INFO: Using default key shortcuts set" << NL;
		return getDefaultKeyShortcuts();
	}

	if(!file.open(QIODevice::ReadOnly)) {
		LOG << CURDATE << "GetAndDoStuffShortcuts: ERROR: failed to read key shortcuts file" << NL;
		return QVariantMap();
	}

	QTextStream in(&file);
	QStringList all = in.readAll().split("\n");
	foreach(QString line, all) {
		if(line.startsWith("Version") || line.trimmed() == "") continue;
		QStringList parts = line.split("::");
		if(parts.length() != 3) {
			LOG << CURDATE << "GetAndDoStuffShortcuts: ERROR: invalid key shortcuts data: " << line.toStdString() << NL;
			continue;
		}

		ret.insert(parts[1],QStringList() << parts[0] << parts[2]);
	}

	return ret;

}

QVariantMap GetAndDoStuffShortcuts::getMouseShortcuts() {

	QVariantMap ret;

	QFile file(CFG_MOUSE_SHORTCUTS_FILE);

	if(!file.exists()) {
		// Set-up Map of default shortcuts;
		LOG << CURDATE << "GetAndDoStuffShortcuts: INFO: Using default mouse shortcuts set" << NL;
		return getDefaultMouseShortcuts();
	}

	if(!file.open(QIODevice::ReadOnly)) {
		LOG << CURDATE << "GetAndDoStuffShortcuts: ERROR: failed to read mouse shortcuts file" << NL;
		return QVariantMap();
	}

	QTextStream in(&file);
	QStringList all = in.readAll().split("\n");
	foreach(QString line, all) {
		if(line.startsWith("Version") || line.trimmed() == "") continue;
		QStringList parts = line.split("::");
		if(parts.length() != 3) {
			LOG << CURDATE << "GetAndDoStuffShortcuts: ERROR: invalid mouse shortcuts data: " << line.toStdString() << NL;
			continue;
		}

		ret.insert(parts[1],QStringList() << parts[0] << parts[2]);
	}

	return ret;

}

QVariantMap GetAndDoStuffShortcuts::getTouchShortcuts() {

	QVariantMap ret;

	QFile file(CFG_TOUCH_SHORTCUTS_FILE);

	if(!file.exists()) {
		// Set-up Map of default shortcuts;
		LOG << CURDATE << "GetAndDoStuff::TouchShortcuts: INFO: Using default touch shortcuts set" << NL;
		return getDefaultTouchShortcuts();
	}

	if(!file.open(QIODevice::ReadOnly)) {
		LOG << CURDATE << "GetAndDoStuff::TouchShortcuts: ERROR: failed to read touch shortcuts file" << NL;
		return QVariantMap();
	}

	QTextStream in(&file);
	QStringList all = in.readAll().split("\n");
	foreach(QString line, all) {
		if(line.startsWith("Version") || line.trimmed() == "") continue;
		QStringList parts = line.split("::");
		if(parts.length() != 5) {
			LOG << CURDATE << "GetAndDoStuff::TouchShortcuts: ERROR: invalid touch shortcuts data: " << line.toStdString() << NL;
			continue;
		}

		ret.insert(QString("%1::%2::%3").arg(parts[1]).arg(parts[2]).arg(parts[3]),QStringList() << parts[0] << parts[4]);

	}

	return ret;

}

QVariantMap GetAndDoStuffShortcuts::getAllShortcuts() {

	QVariantMap ret;

	QVariantMap keys = getKeyShortcuts();
	QVariantMap mouse = getMouseShortcuts();
	QVariantMap touch = getTouchShortcuts();

	QVariantMap::const_iterator i = keys.constBegin();
	while(i != keys.constEnd()) {
		ret.insert(i.key(),i.value());
		++i;
	}
	i = mouse.constBegin();
	while(i != mouse.constEnd()) {
		ret.insert(i.key(),i.value());
		++i;
	}
	i = touch.constBegin();
	while(i != touch.constEnd()) {
		ret.insert(i.key(),i.value());
		++i;
	}

	return ret;

}

QVariantMap GetAndDoStuffShortcuts::getDefaultKeyShortcuts() {

	QVariantMap ret;
	ret.insert("O",QStringList() << "0" << "__open");
	ret.insert("Ctrl+O",QStringList() << "0" << "__open");
	ret.insert("Right",QStringList() << "0" << "__next");
	ret.insert("Space",QStringList() << "0" << "__next");
	ret.insert("Left",QStringList() << "0" << "__prev");
	ret.insert("Backspace",QStringList() << "0" << "__prev");
	ret.insert("Ctrl+F", QStringList() << "0" << "__filterImages");

	ret.insert("+",QStringList() << "0" << "__zoomIn");
	ret.insert("=",QStringList() << "0" << "__zoomIn");
	ret.insert("Ctrl++",QStringList() << "0" << "__zoomIn");
	ret.insert("Ctrl+=",QStringList() << "0" << "__zoomIn");
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
	ret.insert("S", QStringList() << "0" << "__stopThb");
	ret.insert("Ctrl+R", QStringList() << "0" << "__reloadThb");

	ret.insert("F2",QStringList() << "0" << "__rename");
	ret.insert("Ctrl+C",QStringList() << "0" << "__copy");
	ret.insert("Ctrl+M",QStringList() << "0" << "__move");
	ret.insert("Delete",QStringList() << "0" << "__delete");

	ret.insert("Escape",QStringList() << "0" << "__hide");
	ret.insert("Q",QStringList() << "0" << "__close");
	ret.insert("Ctrl+Q",QStringList() << "0" << "__close");

	ret.insert("Home",QStringList() << "0" << "__gotoFirstThb");
	ret.insert("End",QStringList() << "0" << "__gotoLastThb");

	return ret;

}

QVariantMap GetAndDoStuffShortcuts::getDefaultMouseShortcuts() {
	QVariantMap ret;
	ret.insert("Ctrl+Wheel Down",QStringList() << "0" << "__zoomIn");
	ret.insert("Ctrl+Wheel Up",QStringList() << "0" << "__zoomOut");
	ret.insert("Ctrl+Middle Button",QStringList() << "0" << "__zoomReset");
	ret.insert("Right Button+SES",QStringList() << "0" << "__zoomReset");
	return ret;
}

QVariantMap GetAndDoStuffShortcuts::getDefaultTouchShortcuts() {
	QVariantMap ret;
	ret.insert("2::swipe::E", QStringList() << "0" << "__next");
	ret.insert("2::swipe::W", QStringList() << "0" << "__prev");
	return ret;
}

void GetAndDoStuffShortcuts::saveShortcuts(QVariantMap l) {

	QString keys_cont = "Version=" + QString::fromStdString(VERSION) + "\n";
	QString mouse_cont = "Version=" + QString::fromStdString(VERSION) + "\n";
	QString touch_cont = "Version=" + QString::fromStdString(VERSION) + "\n";

	QVariantMap::const_iterator i = l.constBegin();
	while(i != l.constEnd()) {

		QString sh = i.key();
		bool close = (i.value().toList().at(0).toString()=="1");
		QString cmd = i.value().toList().at(1).toString();
		QString type = i.value().toList().at(2).toString();

		if(type == "key")
			keys_cont += QString("%1::%2::%3\n").arg((int)close).arg(sh).arg(cmd);
		else if(type == "mouse")
			mouse_cont += QString("%1::%2::%3\n").arg((int)close).arg(sh).arg(cmd);
		else if(type == "touch")
			touch_cont += QString("%1::%2::%3\n").arg((int)close).arg(sh).arg(cmd);

		++i;
	}

	QString type[3]{"key","mouse","touch"};

	for(unsigned int i = 0; i < 3; ++i) {

		QFile file;
		file.setFileName(type[i] == "key" ? CFG_KEY_SHORTCUTS_FILE : (type[i] == "mouse" ? CFG_MOUSE_SHORTCUTS_FILE : CFG_TOUCH_SHORTCUTS_FILE));
		if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
			LOG << CURDATE << "GetAndDoStuffShortcuts: ERROR: Unable to open " << type[i].toStdString() << " shortcuts file for writing/saving" << NL;
			return;
		}

		QTextStream out(&file);
		out << (type[i] == "key" ? keys_cont : (type[i] == "mouse" ? mouse_cont : touch_cont));

		file.close();

	}

}

QString GetAndDoStuffShortcuts::getKeyShortcutFile() {

	QFile file(CFG_KEY_SHORTCUTS_FILE);
	if(!file.open(QIODevice::ReadOnly)) {
		LOG << CURDATE << "GetAndDoStuffShortcuts: ERROR: Unable to read shortcuts file" << NL;
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

bool GetAndDoStuffShortcuts::isTouchScreenAvailable() {

	unsigned int counter = 0;
	for(int i = 0; i < QTouchDevice::devices().length(); ++i) {
		if(QTouchDevice::devices().at(i)->type() == QTouchDevice::TouchScreen)
			++counter;
	}

	return (counter > 0);

}
