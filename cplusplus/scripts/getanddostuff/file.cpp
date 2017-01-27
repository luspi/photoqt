#include "file.h"

GetAndDoStuffFile::GetAndDoStuffFile(QObject *parent) : QObject(parent) { }
GetAndDoStuffFile::~GetAndDoStuffFile() { }

QString GetAndDoStuffFile::getFilenameQtImage() {

	return QFileDialog::getOpenFileName(0,"Please select image file",QDir::homePath());

}

QString GetAndDoStuffFile::getFilename(QString caption, QString dir, QString filter) {

	return QFileDialog::getOpenFileName(0, caption, dir, filter);

}

// Search for the file path of the icons in the hicolor theme (used by contextmenu)
QString GetAndDoStuffFile::getIconPathFromTheme(QString binary) {

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

QString GetAndDoStuffFile::getSaveFilename(QString caption, QString file) {

	return QFileDialog::getSaveFileName(0, caption, file);

}

QString GetAndDoStuffFile::removePathFromFilename(QString path, bool removeSuffix) {

	if(removeSuffix)
		return QFileInfo(path).baseName();
	return QFileInfo(path).fileName();

}

QString GetAndDoStuffFile::removeFilenameFromPath(QString file) {

	if(file.startsWith("file:/"))
		file = file.remove(0,6);
	if(file.startsWith("image://full/"))
		file = file.remove(0,13);

	return QFileInfo(file).absolutePath();

}

QString GetAndDoStuffFile::getSuffix(QString file) {

	return QFileInfo(file).completeSuffix();

}
