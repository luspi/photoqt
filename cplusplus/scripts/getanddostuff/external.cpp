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

	// Obtain a filename from the user
	QString zipFile = QFileDialog::getSaveFileName(0, "Select Location", QDir::homePath() + "/photoqtconfig.pqt", "PhotoQt Config File (*.pqt);;All Files (*.*)");

	// if no suffix, append the pqt suffix
	if(QFileInfo(zipFile).suffix() == "")
		zipFile += ".pqt";

	// All the config files to be exported
	QHash<QString,QString> allfiles;
	allfiles["CFG_SETTINGS_FILE"] = CFG_SETTINGS_FILE;
	allfiles["CFG_FILEFORMATS_FILE"] = CFG_FILEFORMATS_FILE;
	allfiles["CFG_CONTEXTMENU_FILE"] = CFG_CONTEXTMENU_FILE;
	allfiles["CFG_KEY_SHORTCUTS_FILE"] = CFG_KEY_SHORTCUTS_FILE;
	allfiles["CFG_MOUSE_SHORTCUTS_FILE"] = CFG_MOUSE_SHORTCUTS_FILE;
	allfiles["CFG_TOUCH_SHORTCUTS_FILE"] = CFG_TOUCH_SHORTCUTS_FILE;

	// Start a writer for the zip file
	ZipWriter writer(zipFile);

	// Iterate over filenames to be exported
	QHash<QString, QString>::const_iterator i = allfiles.constBegin();
	while(i != allfiles.constEnd()) {

		// Create and open file in read only mode
		QFile file(i.value());
		if(!file.open(QIODevice::ReadOnly)) {
			std::stringstream ss;
			ss << "ERROR: Unable to open '" << i.value().toStdString() << "' file for composing config file: " << file.errorString().trimmed().toStdString();
			LOG << "[[[DATE]]] " << ss.str() << NL;
			// on error, return error string
			return QString::fromStdString(ss.str());
		}

		// Add the file to the zip file
		writer.addFile(i.key(),file.readAll());

		file.close();

		++i;
	}

	// close zip writer
	writer.close();

	return "";

}

QString GetAndDoStuffExternal::importConfig(QString filename) {

	// All the config files to be imported
	QHash<QString,QString> allfiles;
	allfiles["CFG_SETTINGS_FILE"] = CFG_SETTINGS_FILE;
	allfiles["CFG_FILEFORMATS_FILE"] = CFG_FILEFORMATS_FILE;
	allfiles["CFG_CONTEXTMENU_FILE"] = CFG_CONTEXTMENU_FILE;
	allfiles["CFG_KEY_SHORTCUTS_FILE"] = CFG_KEY_SHORTCUTS_FILE;
	allfiles["CFG_MOUSE_SHORTCUTS_FILE"] = CFG_MOUSE_SHORTCUTS_FILE;
	allfiles["CFG_TOUCH_SHORTCUTS_FILE"] = CFG_TOUCH_SHORTCUTS_FILE;

	// Start zip reader
	ZipReader reader(filename);
	// and iterate over all files in the zip file
	foreach(ZipReader::FileInfo item, reader.fileInfoList()) {

		// start file with file path to be written to
		QFile file(allfiles[item.filePath]);
		if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
			std::stringstream ss;
			ss << "ERROR: Unable to open '" << allfiles[item.filePath].toStdString() << "' for writing/truncating: " << file.errorString().trimmed().toStdString();
			LOG << "[[[DATE]]] " << ss.str() << NL;
			// on error, return error string
			return QString::fromStdString(ss.str());
		}

		// write file
		file.write(reader.fileData(item.filePath));

		file.close();

	}

	// finish reader
	reader.close();

	return "";

}

void GetAndDoStuffExternal::restartPhotoQt(QString loadThisFileAfter) {
	// restart PhotoQt, prepend 'RESTARTRESTARTRESTART' to file to be loader
	// -> this causes PhotoQt to load at startup to make sure this instance is first properly closed
	qApp->quit();
	QProcess::startDetached(qApp->arguments()[0], QStringList() << QString("RESTARTRESTARTRESTART%1").arg(loadThisFileAfter));
}
