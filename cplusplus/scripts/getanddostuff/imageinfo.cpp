#include "imageinfo.h"

GetAndDoStuffImageInfo::GetAndDoStuffImageInfo(QObject *parent) : QObject(parent) {
	provider = new ImageProviderFull();
	mov = new QMovie;
}
GetAndDoStuffImageInfo::~GetAndDoStuffImageInfo() { }

bool GetAndDoStuffImageInfo::isImageAnimated(QString path) {

	if(path.startsWith("image://full/"))
		path = path.remove(0,13);
	if(path.contains("::photoqt::"))
		path = path.split("::photoqt::").at(0);

	return QMovie::supportedFormats().contains(QFileInfo(path).suffix().toLower().toUtf8());

}

QSize GetAndDoStuffImageInfo::getAnimatedImageSize(QString path) {

	path = path.remove("image://full/");
	path = path.remove("file:/");

	if(path.trimmed() == "") {
		std::cout << "empty...";
		return QSize();
	}

	QImageReader reader(path);
	return reader.size();

}

QList<int> GetAndDoStuffImageInfo::getNumFramesAndDuration(QString filename) {

	if(filename.startsWith("image://full/"))
		filename = filename.remove(0,13);

	if(filename.contains("::photoqt::"))
		filename = filename.split("::photoqt::").at(0);

	QList<int> ret = QList<int>() << 1 << 0;

	if(!QImageReader(filename).supportsAnimation()) {
		mov->stop();
		return ret;
	}

	if(mov->fileName() != filename) {
		delete mov;
		mov = new QMovie(filename);
		// the movie needs to be running to get the right value for nextFrameDelay()
		mov->start();
	}
	if(mov->frameCount() > 1) {
		ret[0] = mov->frameCount();
		ret[1] = mov->nextFrameDelay();
		return ret;
	}

	return ret;

}

QString GetAndDoStuffImageInfo::getLastModified(QString filename) {
	if(filename.startsWith("image://full/"))
		filename = filename.remove(0,13);
	if(filename.contains("::photoqt::"))
		filename = filename.split("::photoqt::").at(0);
	return QFileInfo(filename).lastModified().toString("HHmmsszzz");
}
