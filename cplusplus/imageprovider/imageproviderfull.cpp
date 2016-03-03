#include "imageproviderfull.h"

ImageProviderFull::ImageProviderFull() : QQuickImageProvider(QQuickImageProvider::Image) {

	verbose = false;

	settingsPerSession = new QSettings("photoqt_session");
	settings = new Settings;
	fileformats = new FileFormats(verbose);

	gmfiles = fileformats->formats_gm.join(",") + fileformats->formats_gm_ghostscript.join(",") + fileformats->formats_untested.join(",");
	qtfiles = fileformats->formats_qt.join(",");
	extrasfiles = fileformats->formats_extras.join(",");
	rawfiles = fileformats->formats_raw.join(",");

}

ImageProviderFull::~ImageProviderFull() {
	delete settingsPerSession;
	delete settings;
	delete fileformats;
}

QImage ImageProviderFull::requestImage(const QString &filename_encoded, QSize *size, const QSize &requestedSize) {

	QString filename = QByteArray::fromPercentEncoding(filename_encoded.toUtf8());

	if(requestedSize.width() > 20 || requestedSize.height() > 20)
		maxSize = requestedSize;
	else
		// This indicates that the image has been zoomed -> no scaling!
		maxSize = QSize(-1,-1);

	// Which GraphicsEngine should we use?
	QString whatToUse = whatDoIUse(filename);

	if(verbose)
		std::clog << "Using Graphicsengine: "
			  << (whatToUse=="gm" ? "GraphicsMagick" : (whatToUse=="qt" ? "ImageReader" : (whatToUse=="raw" ? "LibRaw" : "External Tool")))
			  << " [" << whatToUse.toStdString() << "]" << std::endl;

	// Try to use XCFtools for XCF (if enabled)
	if(QFileInfo(filename).suffix().toLower() == "xcf" && whatToUse == "extra")
			return LoadImageXCF::load(filename,maxSize);

	// Try to use GraphicsMagick (if available)
	else if(whatToUse == "gm")
		return LoadImageGM::load(filename, maxSize);

	else if(whatToUse == "raw")
		return LoadImageRaw::load(filename, maxSize);

	// Try to use Qt
	else
		return LoadImageQt::load(filename,maxSize,settings->exifrotation);

}

QString ImageProviderFull::whatDoIUse(QString filename) {

	QString use = "qt";

	if(filename.trimmed() == "") return use;

	if(extrasfiles.trimmed() != "") {

		// We need this list for GM and EXTRA below
		QStringList extrasFiles = extrasfiles.split(",");

		// Check for extra
		for(int i = 0; i < extrasFiles.length(); ++i) {
			// We need to remove the first character of qtfiles.at(i), since that is a "*"
			if(filename.toLower().endsWith(QString(extrasFiles.at(i)).remove(0,2)))  {
				use = "extra";
				break;
			}
		}

	}

#ifdef RAW

	if(rawfiles.trimmed() != "") {

		QStringList rawFiles = rawfiles.split(",");

		// Check for raw
		for(int i = 0; i < rawFiles.length(); ++i) {
			// We need to remove the first character of qtfiles.at(i), since that is a "*"
			if(filename.toLower().endsWith(QString(rawFiles.at(i)).remove(0,1)))  {
				use = "raw";
				break;
			}
		}

	}

#endif

#ifdef GM

	// Check for GM (i.e., check for not qt and not extra)
	bool usegm = true;
	QStringList qtFiles = qtfiles.split(",");

	for(int i = 0; i < qtFiles.length(); ++i) {
		// We need to remove the first character of qtfiles.at(i), since that is a "*"
		if(filename.toLower().endsWith(QString(qtFiles.at(i)).remove(0,1)) && QString(qtFiles.at(i)).trimmed() != "")
			usegm = false;
	}
	if(extrasfiles.trimmed() != "") {

		// We need this list for GM and EXTRA below
		QStringList extrasFiles = extrasfiles.split(",");
		for(int i = 0; i < extrasFiles.length(); ++i) {
			// We need to remove the first character of qtfiles.at(i), since that is a "*"
			if(filename.toLower().endsWith(QString(extrasFiles.at(i)).remove(0,2)) && QString(extrasFiles.at(i)).trimmed() != "")
				usegm = false;
		}
	}

#ifdef RAW

	if(rawfiles.trimmed() != "") {
		QStringList rawFiles = rawfiles.split(",");
		// Check for raw
		for(int i = 0; i < rawFiles.length(); ++i) {
			// We need to remove the first character of qtfiles.at(i), since that is a "*"
			if(filename.toLower().endsWith(QString(rawFiles.at(i)).remove(0,1)) && QString(rawFiles.at(i)).trimmed() != "")
				usegm = false;
		}
	}

#endif


	if(usegm) use = "gm";
#endif

	return use;

}
