#include "imageproviderfull.h"

ImageProviderFull::ImageProviderFull() : QQuickImageProvider(QQuickImageProvider::Image) {

	verbose = false;

	settingsPerSession = new QSettings("photoqt_session");

	gmfiles = "*.avs,*.x,*.cals,*.cal,*.dcl,*.ras,*.cin,*.cut,*.acr,*.dcm,*.dicom,*.dic,*.dcx,*.dib,*.dpx,*.epdf,*.fax,*.fits,*.fts,*.fit,*.fpx,*.jng,*.mat,*.miff,*.mono,*.mtv,*.otb,*.p7,*.palm,*.pam,*.pcd,*.pcds,*.pcx,*.pdb,*.pict,*.pct,*.pic,*.pix,*.pal,*.pnm,*.psd,*.ptif,*.ptiff,*.sfw,*.sgi,*.sun,*.tga,*.txt,*.vicar,*.viff,*.wpg,*.xwd";
	qtfiles = "*.bmp,*.bitmap,*.dds,*.gif,*.tif,*.tiff,*.jpeg2000,*.jp2,*.jpc,*.j2k,*.jpf,*.jpx,*.jpm,*.mj2,*.mng,*.ico,*.icns,*.jpeg,*.jpg,*.png,*.pbm,*.pgm,*.ppm,*.svg,*.svgz,*.wbmp,*.webp,*.xbm,*.xpm,*.fil";
	extrasfiles = "";

}

QImage ImageProviderFull::requestImage(const QString &filename_encoded, QSize *size, const QSize &requestedSize) {

	QString filename = QByteArray::fromPercentEncoding(filename_encoded.toUtf8());

	qDebug() << "requestedsize:" << requestedSize;

	if(requestedSize.width() > 20 || requestedSize.height() > 20)
		maxSize = requestedSize;
	else
		maxSize = settingsPerSession->value("curSize").toSize();

	// Which GraphicsEngine should we use?
	QString whatToUse = whatDoIUse(filename);

	if(verbose)
		std::clog << "Using Graphicsengine: "
			  << (whatToUse=="gm" ? "GraphicsMagick" : (whatToUse=="qt" ? "ImageReader" : "External Tool"))
			  << " [" << whatToUse.toStdString() << "]" << std::endl;

	QImage ret;

	// Try to use XCFtools for XCF (if enabled)
	if(QFileInfo(filename).suffix().toLower() == "xcf" && whatToUse == "extra")
			ret = readImage_XCF(filename);

	// Try to use GraphicsMagick (if available)
	else if(whatToUse == "gm")
		ret = readImage_GM(filename);

	// Try to use Qt
	else
		ret = readImage_QT(filename);

	int w = ret.width();
	int h = ret.height();
	if(w < maxSize.width() && h < maxSize.height()) {
		QPixmap retS(w,maxSize.height());
		retS.fill(Qt::transparent);
		int x = 0;
		int y = 0;
		if(h < maxSize.height())
			y = (maxSize.height()-h)/2;
		QPainter retP(&retS);
		retP.drawImage(x,y,ret);
		retP.end();
		return retS.toImage();
	}

	return ret;

}

QImage ImageProviderFull::readImage_QT(QString filename) {

	// For reading SVG files
	QSvgRenderer svg;
	QPixmap svg_pixmap;

	// For all other supported file types
	QImageReader reader;

	// Return image
	QImage img;

	// Suffix, for easier access later-on
	QString suffix = QFileInfo(filename).suffix().toLower();

	if(suffix == "svg") {

		// Loading SVG file
		svg.load(filename);

		// Invalid vector graphic
		if(!svg.isValid()) {
			std::cerr << "[reader svg] Error: invalid svg file" << std::endl;
			QPixmap pix(":/img/plainerrorimg.png");
			QPainter paint(&pix);
			QTextDocument txt;
			txt.setHtml("<center><div style=\"text-align: center; font-size: 12pt; font-wight: bold; color: white; background: none;\">ERROR LOADING IMAGE<br><br><bR>The file doesn't contain valid a vector graphic</div></center>");
			paint.translate(100,150);
			txt.setTextWidth(440);
			txt.drawContents(&paint);
			paint.end();
			origSize = pix.size();
			return pix.toImage();
		}

		// Render SVG into pixmap
		svg_pixmap = QPixmap(svg.defaultSize());
		svg_pixmap.fill(Qt::transparent);
		QPainter painter(&svg_pixmap);
		svg.render(&painter);

		// Store the width/height for later use
		origSize = svg.defaultSize();

	} else {

		// Setting QImageReader
		reader.setFileName(filename);

		// Store the width/height for later use
		origSize = reader.size();

		// Sometimes the size returned by reader.size() is <= 0 (observed for, e.g., .jp2 files)
		// -> then we need to load the actual image to get dimensions
		if(origSize.width() <= 0 || origSize.height() <= 0) {
			qDebug() << "[imagereader qt] failed to read origsize";
			QImageReader r;
			r.setFileName(filename);
			origSize = r.read().size();
		}

	}

	int dispWidth = origSize.width();
	int dispHeight = origSize.height();

	double q;

	if(dispWidth > maxSize.width()) {
			q = maxSize.width()/(dispWidth*1.0);
			dispWidth *= q;
			dispHeight *= q;
	}

	// If thumbnails are kept visible, then we need to subtract their height from the absolute height otherwise they overlap with the main image
	if(dispHeight > maxSize.height()) {
		q = maxSize.height()/(dispHeight*1.0);
		dispWidth *= q;
		dispHeight *= q;
	}

	// Finalise SVG files
	if(suffix == "svg") {

		// Convert pixmap to image
		img = svg_pixmap.toImage();

	} else {

		// Scale imagereader
		reader.setScaledSize(QSize(dispWidth,dispHeight));

		// Eventually load the image
		img = reader.read();

		// If an error occured
		if(img.isNull()) {
			QString err = reader.errorString();
			std::cerr << "[reader qt] Error: file failed to load: " << err.toStdString() << std::endl;
			std::cerr << "Filename: " << filename.toStdString() << std::endl;
			QPixmap pix(":/img/plainerrorimg.png");
			QPainter paint(&pix);
			QTextDocument txt;
			txt.setHtml(QString("<center><div style=\"text-align: center; font-size: 12pt; font-wight: bold; color: white; background: none;\"><b>ERROR LOADING IMAGE</b><br><br><bR>%1</div></center>").arg(err));
			paint.translate(100,150);
			txt.setTextWidth(440);
			txt.drawContents(&paint);
			paint.end();
			return pix.toImage();
		}

	}

	return img;

}

QImage ImageProviderFull::readImage_GM(QString filename) {

#ifdef GM

	QFile file(filename);
	file.open(QIODevice::ReadOnly);
	char *data = new char[file.size()];
	qint64 s = file.read(data, file.size());
	if (s < file.size()) {
		delete[] data;
		if(verbose) std::cerr << "[reader gm] ERROR reading image file data" << std::endl;
		return QImage();
	}

	Magick::Blob blob(data, file.size());
	try {
		Magick::Image image;

		QString suf = QFileInfo(filename).suffix().toLower();

		if(suf == "x" || suf == "avs")

			image.magick("AVS");

		else if(suf == "cals" || suf == "cal" || suf == "dcl"  || suf == "ras")

			image.magick("CALS");

		else if(suf == "cgm")

			image.magick("CGM");

		else if(suf == "cut")

			image.magick("CUT");

		else if(suf == "cur")

			image.magick("CUR");

		else if(suf == "acr" || suf == "dcm" || suf == "dicom" || suf == "dic")

			image.magick("DCM");

		else if(suf == "fax")

			image.magick("FAX");

		else if(suf == "ico")

			image.magick("ICO");

		else if(suf == "mono") {

			image.magick("MONO");
			image.size(Magick::Geometry(4000,3000));

		} else if(suf == "mtv")

			image.magick("MTV");

		else if(suf == "otb")

			image.magick("OTB");

		else if(suf == "palm")

			image.magick("PALM");

		else if(suf == "pfb")

			image.magick("PFB");

		else if(suf == "pict" || suf == "pct" || suf == "pic")

			image.magick("PICT");

		else if(suf == "pix"
			|| suf == "pal")

			image.magick("PIX");

		else if(suf == "tga")

			image.magick("TGA");

		else if(suf == "ttf")

			image.magick("TTF");

		else if(suf == "txt")

			image.magick("TXT");

		else if(suf == "wbm"
			|| suf == "wbmp")

			image.magick("WBMP");


		image.read(blob);
		Magick::Blob ob;
		image.type(Magick::TrueColorMatteType);
		image.magick("PNG");
		image.write(&ob);
		const QByteArray imgData((char*)(ob.data()),ob.length());
		QImage img(maxSize, QImage::Format_ARGB32);
		img.loadFromData(imgData);
		return img;

	} catch(Magick::Exception &error_) {
		delete[] data;
		std::cerr << "[reader gm] Error: " << error_.what() << std::endl;
		QPixmap pix(":/img/plainerrorimg.png");
		QPainter paint(&pix);
		QTextDocument txt;
		txt.setHtml("<center><div style=\"text-align: center; font-size: 12pt; font-wight: bold; color: white; background: none;\">ERROR LOADING IMAGE<br><br><bR>" + QString(error_.what()) + "</div></center>");
		paint.translate(100,150);
		txt.setTextWidth(440);
		txt.drawContents(&paint);
		paint.end();
		pix.save(QDir::tempPath() + "/photoqt_tmp.png");
//		fileformat = "";
		origSize = pix.size();
//		scaleImg1 = -1;
//		scaleImg2 = -1;
//		animatedImg = false;
		return pix.toImage();
	}

#endif

	return QImage();

}

QImage ImageProviderFull::readImage_XCF(QString filename) {

	// We first check if xcftools is actually installed
	QProcess which;
#if QT_VERSION >= 0x050200
	which.setStandardOutputFile(QProcess::nullDevice());
#endif
	which.start("which xcf2png");
	which.waitForFinished();
	// If it isn't -> display error
	if(which.exitCode()) {
		std::cerr << "[reader xcf] Error: xcftools not found" << std::endl;
		QPixmap pix(":/img/plainerrorimg.png");
		QPainter paint(&pix);
		QTextDocument txt;
		txt.setHtml("<center><div style=\"text-align: center; font-size: 12pt; font-wight: bold; color: white; background: none;\">ERROR LOADING IMAGE<br><br><bR>PhotoQt relies on 'xcftools'' to display XCF images, but it wasn't found!</div></center>");
		paint.translate(100,150);
		txt.setTextWidth(440);
		txt.drawContents(&paint);
		paint.end();
//		fileformat = "";
		origSize = pix.size();
//		scaleImg1 = -1;
//		scaleImg2 = -1;
//		animatedImg = false;
		return pix.toImage();
	}

	// Convert xcf to png using xcf2png (part of xcftools)
	QProcess p;
	p.execute(QString("xcf2png \"%1\" -o %2").arg(filename).arg(QDir::tempPath() + "/photoqt_tmp.png"));

	// And load it
	return readImage_QT(QDir::tempPath() + "/photoqt_tmp.png");

}

QString ImageProviderFull::whatDoIUse(QString filename) {

	QString use = "qt";

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
		if(filename.toLower().endsWith(QString(qtFiles.at(i)).remove(0,1)))
			usegm = false;
	}
	if(extrasfiles.trimmed() != "") {

		// We need this list for GM and EXTRA below
		QStringList extrasFiles = extrasfiles.split(",");
		for(int i = 0; i < extrasFiles.length(); ++i) {
			// We need to remove the first character of qtfiles.at(i), since that is a "*"
			if(filename.toLower().endsWith(QString(extrasFiles.at(i)).remove(0,2)))
				usegm = false;
		}
	}

	if(usegm) use = "gm";
#endif

	return use;

}
