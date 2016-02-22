#include "imageproviderfull.h"

ImageProviderFull::ImageProviderFull() : QQuickImageProvider(QQuickImageProvider::Image) {

	verbose = false;

	settingsPerSession = new QSettings("photoqt_session");
	settings = new Settings;
	fileformats = new FileFormats();

	gmfiles = fileformats->formatsGmEnabled.join(",") + fileformats->formatsGmGhostscriptEnabled.join(",") + fileformats->formatsUntestedEnabled.join(",");
	qtfiles = fileformats->formatsQtEnabled.join(",");
	extrasfiles = fileformats->formatsExtrasEnabled.join(",");

}

ImageProviderFull::~ImageProviderFull() {
	delete settingsPerSession;
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
			  << (whatToUse=="gm" ? "GraphicsMagick" : (whatToUse=="qt" ? "ImageReader" : "External Tool"))
			  << " [" << whatToUse.toStdString() << "]" << std::endl;

	QImage ret;

	// Try to use XCFtools for XCF (if enabled)
	if(QFileInfo(filename).suffix().toLower() == "xcf" && whatToUse == "extra")
			ret = LoadImageXCF::load(filename,maxSize);

	// Try to use GraphicsMagick (if available)
	else if(whatToUse == "gm")
		ret = LoadImageGM::load(filename, maxSize);

	// Try to use Qt
	else
		ret = LoadImageQt::load(filename,maxSize,settings->exifrotation);

	return ret;

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

	if(usegm) use = "gm";
#endif

	return use;

}
