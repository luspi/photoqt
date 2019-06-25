#include <QProcess>
#include <QDir>
#include <QImageReader>

#include "../../logger.h"
#include "helper.h"

namespace PQLoadImage {

    namespace XCF {

        static QString errormsg = "";

        static QImage load(QString filename, QSize maxSize, QSize *origSize) {

            QImage cachedImg = PQLoadImage::Helper::getCachedImage(filename);
            if(!cachedImg.isNull()) {
                PQLoadImage::Helper::ensureImageFitsMaxSize(cachedImg, maxSize);
                return cachedImg;
            }

            // We first check if xcftools is actually installed
            QProcess which;
            which.setStandardOutputFile(QProcess::nullDevice());
            which.start("which xcf2png");
            which.waitForFinished();
            // If it isn't -> display error
            if(which.exitCode()) {
                LOG << CURDATE << "LoadImageXCF: reader xcf - Error: xcftools not found" << NL;
                errormsg = "Error: xcftools not found";
                return QImage();
            }

            // Convert xcf to png using xcf2png (part of xcftools)
            QProcess p;
            p.execute(QString("xcf2png \"%1\" -o %2").arg(filename).arg(QDir::tempPath() + "/photoqt_xcf.png"));

            // And load it
            QImageReader reader(QDir::tempPath() + "/photoqt_xcf.png");

            *origSize = reader.size();

            bool scaledImageDoNotCache = false;

            // Make sure image fits into size specified by maxSize
            if(maxSize.width() > 5 && maxSize.height() > 5) {
                double q = 1;
                if(reader.size().width() > maxSize.width())
                    q = (double)maxSize.width()/(double)reader.size().width();
                if(reader.size().height()*q > maxSize.height())
                    q = (double)maxSize.height()/(double)reader.size().height();
                reader.setScaledSize(reader.size()*q);
                if(fabs(q-1) > std::numeric_limits<double>::epsilon()*5)
                    scaledImageDoNotCache = true;
            }

            QImage img = reader.read();

            if(!scaledImageDoNotCache)
                PQLoadImage::Helper::saveImageToCache(filename, img);

            return img;

        }

    }

}
