#include <QFile>

#include "../../logger.h"

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#endif

namespace PQLoadImage {

    namespace GraphicsMagick {

        static QString errormsg = "";

#ifdef GM
        static std::string getImageMagickString(QString suf);
#endif

        static QImage load(QString filename, QSize maxSize, QSize *origSize) {

#ifdef GM

            QSize finalSize;

            // We first read the image into memory
            QFile file(filename);
            if(!file.open(QIODevice::ReadOnly)) {
                errormsg = "ERROR opening file, returning empty image";
                LOG << CURDATE << "PQLoadImage::GraphicsMagick::load(): ERROR opening file, returning empty image" << NL;
                return QImage();
            }
            char *data = new char[file.size()];
            qint64 s = file.read(data, file.size());

            // A return value of -1 means error
            if (s == -1) {
                delete[] data;
                LOG << CURDATE << "PQLoadImage::GraphicsMagick::load(): ERROR reading image file data" << NL;
                errormsg = "ERROR reading image file data";
                return QImage();
            }
            // Read image into blob
            Magick::Blob blob(data, file.size());
            try {

                // Prepare Magick
                QString suf = QFileInfo(filename).suffix().toUpper();
                Magick::Image image;

                // Detect and set Magick format
                std::string magick = getImageMagickString(suf.toLower());
                if(magick != "") image.magick(magick);

                // Read image into Magick
                image.read(blob);

                finalSize = QSize(image.columns(), image.rows());
                *origSize = finalSize;

                // Scale image if necessary
                if(maxSize.width() != -1) {

                    double q;

                    if(finalSize.width() > maxSize.width()) {
                        q = maxSize.width()/(finalSize.width()*1.0);
                        finalSize.setWidth(finalSize.width()*q);
                        finalSize.setHeight(finalSize.height()*q);
                    }
                    if(finalSize.height() > maxSize.height()) {
                        q = maxSize.height()/(finalSize.height()*1.0);
                        finalSize.setWidth(finalSize.width()*q);
                        finalSize.setHeight(finalSize.height()*q);
                    }

                    // For small images we can use the faster algorithm, as the quality is good enough for that
                    if(finalSize.width() < 300 && finalSize.height() < 300)
                        image.thumbnail(Magick::Geometry(finalSize.width(),finalSize.height()));
                    else
                        image.scale(Magick::Geometry(finalSize.width(),finalSize.height()));

                }

                // Write Magick as BMP to memory
                // We used to use PNG here, but BMP is waaaayyyyyy faster (even faster than JPG)
                Magick::Blob ob;
                image.magick("BMP");
                image.write(&ob);

                // And load JPG from memory into QImage
                const QByteArray imgData((char*)(ob.data()),ob.length());
                QImage img = QImage::fromData(imgData);

                // And we're done!
                delete[] data;
                return img;

            } catch(Magick::Exception &e) {
                delete[] data;
                LOG << CURDATE << "PQLoadImage::GraphicsMagick::load(): Exception: " << e.what() << NL;
                errormsg = QString("GraphicsMagick Exception: %1").arg(e.what());
                return QImage();
            }

#endif

            errormsg = "Failed to load image with GraphicsMagick!";
            return QImage();

        }

#ifdef GM
        static std::string getImageMagickString(QString suf) {

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

    }

}
