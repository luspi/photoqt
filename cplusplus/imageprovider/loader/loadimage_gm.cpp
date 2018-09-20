#include "loader.h"

QImage PLoadImage::GraphicsMagick(QString filename, QSize maxSize) {

#ifdef GM

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "LoadImageGM: Loading image using GraphicsMagick: " << QFileInfo(filename).fileName().toStdString() << NL;

    unsigned int finalWidth;
    unsigned int finalHeight;

    // We first read the image into memory
    QFile file(filename);
    if(!file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "LoadImageGM: reader gm - ERROR opening file, returning empty image" << NL;
        return QImage();
    }
    char *data = new char[file.size()];
    qint64 s = file.read(data, file.size());

    // A return value of -1 means error
    if (s == -1) {
        delete[] data;
        LOG << CURDATE << "LoadImageGM: reader gm - ERROR reading image file data" << NL;
        return QImage();
    }
    // Read image into blob
    Magick::Blob blob(data, static_cast<size_t>(file.size()));
    try {

        // Prepare Magick
        QString suf = QFileInfo(filename).suffix().toUpper();
        Magick::Image image;

        // Detect and set Magick format
        std::string magick = getImageMagickString(suf.toLower());
        if(magick != "") image.magick(magick);

        // Read image into Magick
        image.read(blob);

        finalWidth = image.columns();
        finalHeight = image.rows();

        // Scale image if necessary
        if(maxSize.width() != -1) {

            double q;

            if(static_cast<int>(finalWidth) > maxSize.width()) {
                    q = maxSize.width()/(finalWidth*1.0);
                    finalWidth *= q;
                    finalHeight *= q;
            }
            if(static_cast<int>(finalHeight) > maxSize.height()) {
                q = maxSize.height()/(finalHeight*1.0);
                finalWidth *= q;
                finalHeight *= q;
            }

            // For small images we can use the faster algorithm, as the quality is good enough for that
            if(finalWidth < 300 && finalHeight < 300)
                image.thumbnail(Magick::Geometry(finalWidth,finalHeight));
            else
                image.scale(Magick::Geometry(finalWidth,finalHeight));

        }

        // Write Magick as BMP to memory
        // We used to use PNG here, but BMP is waaaayyyyyy faster (even faster than JPG)
        Magick::Blob ob;
        image.magick("BMP");
        image.write(&ob);

        // And load JPG from memory into QImage
        const QByteArray imgData(reinterpret_cast<const char*>(ob.data()), static_cast<int>(ob.length()));
        QImage img = QImage::fromData(imgData);//((maxSize.width() > -1 ? maxSize : finalSize), QImage::Format_ARGB32);

        // And we're done!
        delete[] data;
        return img;

    } catch(Magick::Exception &error_) {
        delete[] data;
        LOG << CURDATE << "LoadImageGM: reader gm Error: " << error_.what() << NL;
        return PErrorImage::load(QString(error_.what()));
    }

#else
    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "LoadImageGM: PhotoQt was compiled without GraphicsMagick support, returning error image" << NL;
    return PErrorImage::load("Failed to load image with GraphicsMagick!");
#endif


}

#ifdef GM
std::string PLoadImage::getImageMagickString(QString suf) {

    std::string magick = suf.toUpper().toStdString();

    if(suf == "x")

        magick = "AVS";

    else if(suf == "ct1" || suf == "cal" || suf == "ras" || suf == "ct2" || suf == "ct3" || suf == "nif" || suf == "ct4" || suf == "c4")

        magick = "CALS";

    else if(suf == "acr" || suf == "dicom" || suf == "dic")

        magick = "DCM";

    else if(suf == "pct" || suf == "pic")

        magick = "PICT";

    else if(suf == "pal")

        magick = "PIX";

    else if(suf == "wbm")

        magick = "WBMP";

    else if(suf == "jpe")

        magick = "JPEG";

    else if(suf == "mif")

        magick = "MIFF";

    else if(suf == "alb" || suf == "sfw" || suf == "pwm")

        magick = "PWP";

    else if(suf == "bw" || suf == "rgb" || suf == "rgba")

        magick = "SGI";

    else if(suf == "ras" || suf == "rast" || suf == "rs" || suf == "sr" || suf == "scr" ||
            suf == "im1" || suf == "im8" || suf == "im24" || suf == "im32")

        magick = "SUN";

    else if(suf == "icb" || suf == "vda" || suf == "vst")

        magick = "TGA";

    else if(suf == "vic" || suf == "img")

        magick = "VICAR";

    else if(suf == "bm")

        magick = "XBM";

    return magick;
}
#endif
