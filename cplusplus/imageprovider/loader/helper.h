#ifndef PQLOADIMAGEHELPER_H
#define PQLOADIMAGEHELPER_H

#include <QString>
#include <QCryptographicHash>
#include <QFileInfo>
#include "../pixmapcache.h"
#include "../../settings/imageformats.h"

namespace PQLoadImage {

    namespace Helper {

        static int foundExternalUnrar = -1;

        static QString whatEngineDoIUse(QString filename) {

            if(filename.trimmed() == "") return "qt";

            QString useThisFilename = filename;
            QFileInfo info(useThisFilename);

            /***********************************************************/
            // Qt image plugins

            if(info.suffix().toLower() == "svg" || info.suffix().toLower() == "svgz")
                return "svg";

            if(PQImageFormats::get().getEnabledFileformatsQt().contains("*." + info.suffix().toLower()))
                return "qt";

            if(PQImageFormats::get().getEnabledFileformatsXCF().contains("*." + info.suffix().toLower()))
                return "xcftools";

            if(PQImageFormats::get().getEnabledFileformatsPoppler().contains("*." + info.suffix().toLower()))
                return "poppler";

            if(PQImageFormats::get().getEnabledFileformatsGm().contains("*." + info.suffix().toLower()))
                return "gm";

            if(PQImageFormats::get().getEnabledFileformatsRAW().contains("*." + info.suffix().toLower()))
                return "raw";

            if(PQImageFormats::get().getEnabledFileformatsDevIL().contains("*." + info.suffix().toLower()))
                return "devil";

            if(PQImageFormats::get().getEnabledFileformatsFreeImage().contains("*." + info.suffix().toLower()))
                return "freeimage";

            if(info.suffix().toLower() == "rar" || info.suffix().toLower() == "cbr") {
                if(foundExternalUnrar == -1) {
                    QProcess which;
                    which.setStandardOutputFile(QProcess::nullDevice());
                    which.start("which unrar");
                    which.waitForFinished();
                    foundExternalUnrar = which.exitCode() ? 0 : 1;
                }
                if(foundExternalUnrar == 1)
                    return "unrar";
            }

            if(PQImageFormats::get().getEnabledFileformatsArchive().contains("*." + info.suffix().toLower()))
                return "archive";

            if(PQImageFormats::get().getEnabledFileformatsVideo().contains("*." + info.suffix().toLower()))
                return "video";

            return "qt";

        }

        static QString getUniqueCacheKey(QString filename) {
            return QCryptographicHash::hash(QString("%1%2").arg(filename).arg(QFileInfo(filename).lastModified().toMSecsSinceEpoch()).toUtf8(),QCryptographicHash::Md5).toHex();
        }

        static QImage getCachedImage(QString filename) {

            QPixmap retPix;
            if(PQPixmapCache::get().find(getUniqueCacheKey(filename), &retPix)) {

                QImage ret = retPix.toImage();

                if(!ret.isNull())
                    return ret;

            }

            return QImage();

        }

        static void saveImageToCache(QString filename, QImage &img) {

            PQPixmapCache::get().insert(getUniqueCacheKey(filename), QPixmap::fromImage(img));

        }

        static bool ensureImageFitsMaxSize(QImage &img, QSize maxSize) {

            if(maxSize.width() < 3 || maxSize.height() < 3)
                return false;

            if(img.width() > maxSize.width() || img.height() > maxSize.height()) {
                img = img.scaled(maxSize.width(), maxSize.height(), ::Qt::KeepAspectRatio, ::Qt::SmoothTransformation);
                return true;
            }

            return false;

        }

    }

}

#endif // PQIMAGELOADERHELPER_H
