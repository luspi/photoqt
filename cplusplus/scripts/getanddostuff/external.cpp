#include "external.h"

GetAndDoStuffExternal::GetAndDoStuffExternal(QObject *parent) : QObject(parent) { }
GetAndDoStuffExternal::~GetAndDoStuffExternal() { }

void GetAndDoStuffExternal::openLink(QString url) {
	QDesktopServices::openUrl(url);
}

void GetAndDoStuffExternal::executeApp(QString exec, QString fname) {

	fname = QByteArray::fromPercentEncoding(fname.toUtf8());

	QProcess *p = new QProcess;
	exec = exec.replace("%f", "\"" + fname + "\"");
	exec = exec.replace("%u", "\"" + QFileInfo(fname).fileName() + "\"");
	exec = exec.replace("%d", "\"" + QFileInfo(fname).absoluteDir().absolutePath() + "\"");

	p->startDetached(exec);
	if(p->error() == 5)
		p->waitForStarted(2000);

	delete p;

}

void GetAndDoStuffExternal::openInDefaultFileManager(QString file) {
	QDesktopServices::openUrl(QUrl("file:/" + QFileInfo(file).absolutePath()));
}

QString GetAndDoStuffExternal::exportConfig() {

	QString zipFile = QFileDialog::getSaveFileName(0, "Select Location", QDir::homePath() + "/photoqtconfig.pqt", "PhotoQt Config File (*.pqt);;All Files (*.*)");

	if(QFileInfo(zipFile).suffix() == "")
		zipFile += ".pqt";

	ZipWriter writer(zipFile);
	QHash<QString,QString> allfiles;
	allfiles["CFG_SETTINGS_FILE"] = CFG_SETTINGS_FILE;
	allfiles["CFG_FILEFORMATS_FILE"] = CFG_FILEFORMATS_FILE;
	allfiles["CFG_CONTEXTMENU_FILE"] = CFG_CONTEXTMENU_FILE;
	allfiles["CFG_KEY_SHORTCUTS_FILE"] = CFG_KEY_SHORTCUTS_FILE;
	allfiles["CFG_MOUSE_SHORTCUTS_FILE"] = CFG_MOUSE_SHORTCUTS_FILE;
	allfiles["CFG_TOUCH_SHORTCUTS_FILE"] = CFG_TOUCH_SHORTCUTS_FILE;

	QHash<QString, QString>::const_iterator i = allfiles.constBegin();
	while(i != allfiles.constEnd()) {

		QFile file(i.value());
		if(!file.open(QIODevice::ReadOnly)) {
			std::stringstream ss;
			ss << "ERROR: Unable to open '" << i.value().toStdString() << "' file for composing config file: " << file.errorString().trimmed().toStdString();
			LOG << "[[[DATE]]] " << ss.str() << NL;
			return QString::fromStdString(ss.str());
		}

		writer.addFile(i.key(),file.readAll());

		file.close();

		++i;
	}

	writer.close();

	return "";

}

QString GetAndDoStuffExternal::importConfig(QString filename) {

	QHash<QString,QString> allfiles;
	allfiles["CFG_SETTINGS_FILE"] = CFG_SETTINGS_FILE;
	allfiles["CFG_FILEFORMATS_FILE"] = CFG_FILEFORMATS_FILE;
	allfiles["CFG_CONTEXTMENU_FILE"] = CFG_CONTEXTMENU_FILE;
	allfiles["CFG_KEY_SHORTCUTS_FILE"] = CFG_KEY_SHORTCUTS_FILE;
	allfiles["CFG_MOUSE_SHORTCUTS_FILE"] = CFG_MOUSE_SHORTCUTS_FILE;
	allfiles["CFG_TOUCH_SHORTCUTS_FILE"] = CFG_TOUCH_SHORTCUTS_FILE;

	ZipReader reader(filename);
	foreach(ZipReader::FileInfo item, reader.fileInfoList()) {

		QFile file(allfiles[item.filePath]);
		if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
			std::stringstream ss;
			ss << "ERROR: Unable to open '" << allfiles[item.filePath].toStdString() << "' for writing/truncating: " << file.errorString().trimmed().toStdString();
			LOG << "[[[DATE]]] " << ss.str() << NL;
			return QString::fromStdString(ss.str());
		}

		file.write(reader.fileData(item.filePath));

		file.close();

	}

	reader.close();

	return "";

}

void GetAndDoStuffExternal::restartPhotoQt(QString loadThisFileAfter) {
	qApp->quit();
	QProcess::startDetached(qApp->arguments()[0], QStringList() << QString("RESTARTRESTARTRESTART%1").arg(loadThisFileAfter));
}
