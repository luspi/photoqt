#ifndef PQLOADIMAGEHELPER_H
#define PQLOADIMAGEHELPER_H

#include <QString>
#include <QCryptographicHash>
#include <QFileInfo>
#include "../../settings/imageformats.h"

class PQLoadImageHelper {

public:
    PQLoadImageHelper() {
        cache =  new QCache<QString,QImage>;
    }

    QString getUniqueCacheKey(QString filename) {
        return QCryptographicHash::hash(QString("%1%2").arg(filename).arg(QFileInfo(filename).lastModified().toMSecsSinceEpoch()).toUtf8(),QCryptographicHash::Md5).toHex();
    }

    QImage *getCachedImage(QString filename) {

        if(cache->contains(getUniqueCacheKey(filename))) {
            qDebug() << "get cached";
            return cache->object(getUniqueCacheKey(filename));
        }

        return new QImage();

    }

    bool saveImageToCache(QString filename, QImage *img) {

        qDebug() << "save to cache";

        // we need to use a copy of the image here as otherwise img will have two owners (BAD idea!)
        QImage *n = new QImage(*img);
        qDebug() << "format:" << n->format();
        return cache->insert(getUniqueCacheKey(filename), n, 1);

    }

    bool ensureImageFitsMaxSize(QImage *img, QSize maxSize) {

        if(maxSize.width() < 3 || maxSize.height() < 3)
            return false;

        if(img->width() > maxSize.width() || img->height() > maxSize.height()) {
            *img = img->scaled(maxSize.width(), maxSize.height(), ::Qt::KeepAspectRatio, ::Qt::SmoothTransformation);
            return true;
        }

        return false;

    }

private:
    QCache<QString,QImage> *cache;

};

#endif // PQIMAGELOADERHELPER_H
