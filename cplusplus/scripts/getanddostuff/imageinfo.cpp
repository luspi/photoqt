#include "imageinfo.h"

GetAndDoStuffImageInfo::GetAndDoStuffImageInfo(QObject *parent) : QObject(parent) {
	provider = new ImageProviderFull();
}
GetAndDoStuffImageInfo::~GetAndDoStuffImageInfo() { }

QList<int> GetAndDoStuffImageInfo::getGreyscaleHistogramValues(QString filename) {

	QSize *tmp = new QSize();
	QImage img = provider->requestImage(filename, tmp, QSize());
	delete tmp;

	// Read and store image dimensions
	int w = img.width();
	int h = img.height();

	// In here we store how many pixels there are per grayscale value.
	QList<int> levels;
	for(int i = 0; i < 256; ++i)
		levels.push_back(0);

	// Loop over all rows of the image
	for(int i = 0; i < h; ++i) {

		// Get the pixel data of row i of the image
		QRgb *rowData = (QRgb*)img.scanLine(i);

		// Loop over all columns
		for(int j = 0; j < w; ++j) {

			// Get pixel data of pixel at column j in row i
			QRgb pixelData = rowData[j];

			// Get RGB values
			int red = qRed(pixelData);
			int green = qGreen(pixelData);
			int blue = qBlue(pixelData);

			// Compute the gray level
			int gray_level = qGray(red,green,blue);

			// Add a pixel at current gray level
			++levels[gray_level];

		}

	}

	return levels;

}

QList<int> GetAndDoStuffImageInfo::getColorHistogramValues(QString filename) {

	QSize *tmp = new QSize();
	QImage img = provider->requestImage(filename, tmp, QSize());
	delete tmp;

	// Read and store image dimensions
	int w = img.width();
	int h = img.height();

	// In here we store how many pixels there are per grayscale value.
	QList<int> levels;
	for(int i = 0; i < 3*256; ++i)
		levels.push_back(0);

	// Loop over all rows of the image
	for(int i = 0; i < h; ++i) {

		// Get the pixel data of row i of the image
		QRgb *rowData = (QRgb*)img.scanLine(i);

		// Loop over all columns
		for(int j = 0; j < w; ++j) {

			// Get pixel data of pixel at column j in row i
			QRgb pixelData = rowData[j];

			// Get RGB values
			int red = qRed(pixelData);
			int green = qGreen(pixelData);
			int blue = qBlue(pixelData);

			// Add a pixel at current gray level
			++levels[red];
			++levels[256+green];
			++levels[2*256+blue];

		}

	}

	return levels;

}

QList<int> GetAndDoStuffImageInfo::getNumFramesAndDuration(QString filename) {

	if(filename.startsWith("image://full/"))
		filename = filename.remove(0,13);

	if(filename.contains("::photoqt::"))
		filename = filename.split("::photoqt::").at(0);

	QList<int> ret = QList<int>() << 1 << 0;

	QMovie mov(filename);
	// the movie needs to be running to get the right value for nextFrameDelay()
	mov.start();
	if(mov.frameCount() > 1) {
		ret[0] = mov.frameCount();
		ret[1] = std::max(mov.nextFrameDelay(),100);
		mov.stop();
		return ret;
	}

	return ret;

}
