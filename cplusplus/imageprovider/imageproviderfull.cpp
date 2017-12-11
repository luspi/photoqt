#include "imageproviderfull.h"

ImageProviderFull::ImageProviderFull() : QQuickImageProvider(QQuickImageProvider::Image) {

    verbose = false;

    settings = new Settings;
    fileformats = new FileFormats(verbose);

    gmfiles = fileformats->formats_gm.join(",") + fileformats->formats_gm_ghostscript.join(",") + fileformats->formats_untested.join(",");
    qtfiles = fileformats->formats_qt.join(",");
    extrasfiles = fileformats->formats_extras.join(",");
    rawfiles = fileformats->formats_raw.join(",");

    pixmapcache = new QCache<QByteArray, QPixmap>;
    pixmapcache->setMaxCost(1024*settings->pixmapCache);

    loaderGM = new LoadImageGM;
    loaderQT = new LoadImageQt;
    loaderRAW = new LoadImageRaw;
    loaderXCF = new LoadImageXCF;

}

ImageProviderFull::~ImageProviderFull() {
    delete settings;
    delete fileformats;
    delete pixmapcache;
}

QImage ImageProviderFull::requestImage(const QString &filename_encoded, QSize *, const QSize &requestedSize) {

    QString full_filename = QByteArray::fromPercentEncoding(filename_encoded.toUtf8());
    QString filename = full_filename;

    // Which GraphicsEngine should we use?
    QString whatToUse = whatDoIUse(filename);

    if(verbose)
        LOG << CURDATE << "ImageProviderFull: Using Graphicsengine: "
            << (whatToUse=="gm" ? "GraphicsMagick" : (whatToUse=="qt" ? "ImageReader" : (whatToUse=="raw" ? "LibRaw" : "External Tool")))
            << " [" << whatToUse.toStdString() << "]" << NL;


    QImage ret;

    QByteArray cachekey = getUniqueCacheKey(filename);

    if(pixmapcache->contains(cachekey)) {
        QPixmap *pix = pixmapcache->object(cachekey);
        if(!pix->isNull()) {

            ret = pix->toImage();

            if(requestedSize.width() > 2 && requestedSize.height() > 2 && ret.width() > requestedSize.width() && ret.height() > requestedSize.height())
                return ret.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

            return ret;
        }
    }

    // Try to use XCFtools for XCF (if enabled)
    if(QFileInfo(filename).suffix().toLower() == "xcf" && whatToUse == "extra")
            ret = loaderXCF->load(filename,maxSize);

    // Try to use GraphicsMagick (if available)
    else if(whatToUse == "gm")
        ret = loaderGM->load(filename, maxSize);

    else if(whatToUse == "raw")
        ret = loaderRAW->load(filename, maxSize);

    // Try to use Qt
    else
        ret = loaderQT->load(filename,maxSize,settings->exifrotation);

    QPixmap *newpixPt = new QPixmap(ret.width(), ret.height());
    *newpixPt = QPixmap::fromImage(ret);
    if(!newpixPt->isNull()) {
        pixmapcache->insert(cachekey, newpixPt, newpixPt->width()*newpixPt->height()*newpixPt->depth()/(8*1024));
    }

    if(requestedSize.width() > 2 && requestedSize.height() > 2 && ret.width() > requestedSize.width() && ret.height() > requestedSize.height())
        ret = ret.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    return ret;

}

QString ImageProviderFull::whatDoIUse(QString filename) {

    if(filename.trimmed() == "") return "qt";

    if(extrasfiles.trimmed() != "") {

        // We need this list for GM and EXTRA below
        QStringList extrasFiles = extrasfiles.split(",");

        // Check for extra
        for(int i = 0; i < extrasFiles.length(); ++i) {
            // We need to remove the first character of qtfiles.at(i), since that is a "*"
            if(filename.toLower().endsWith(QString(extrasFiles.at(i)).remove(0,2)))
                return "extra";
        }

    }

#ifdef RAW

    if(rawfiles.trimmed() != "") {

        QStringList rawFiles = rawfiles.split(",");

        // Check for raw
        for(int i = 0; i < rawFiles.length(); ++i) {
            // We need to remove the first character of qtfiles.at(i), since that is a "*"
            if(filename.toLower().endsWith(QString(rawFiles.at(i)).remove(0,1)))
                return "raw";
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


    if(usegm) return "gm";
#endif

    return "qt";

}

QByteArray ImageProviderFull::getUniqueCacheKey(QString path) {
    path = path.remove("image://full/");
    path = path.remove("file:/");
    QFileInfo info(path);
    QString fn = QString("%1%2").arg(path).arg(info.lastModified().toMSecsSinceEpoch());
    return QCryptographicHash::hash(fn.toUtf8(),QCryptographicHash::Md5).toHex();
}
