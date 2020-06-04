#ifndef PQLOADIMAGEHELPER_H
#define PQLOADIMAGEHELPER_H

#include <QString>
#include <QCryptographicHash>
#include <QFileInfo>
#include "../pixmapcache.h"
#include "../../settings/imageformats.h"

namespace PQLoadImage {

    namespace Helper {

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

        static bool saveImageToCache(QString filename, QImage &img) {

            return PQPixmapCache::get().insert(getUniqueCacheKey(filename), QPixmap::fromImage(img));

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
