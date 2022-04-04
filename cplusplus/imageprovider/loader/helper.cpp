#include "helper.h"

PQLoadImageHelper::PQLoadImageHelper() {
    mincost = 15;
    cache =  new QCache<QString,QImage>;
    cache->setMaxCost(qMax(mincost, PQSettings::get()["imageviewCache"].toInt()));
}

PQLoadImageHelper::~PQLoadImageHelper() {
    delete cache;
}

QString PQLoadImageHelper::getUniqueCacheKey(QString filename) {
    return QCryptographicHash::hash(QString("%1%2").arg(filename).arg(QFileInfo(filename).lastModified().toMSecsSinceEpoch()).toUtf8(),QCryptographicHash::Md5).toHex();
}

bool PQLoadImageHelper::getCachedImage(QString filename, QImage &img) {

    if(cache->contains(getUniqueCacheKey(filename))) {
        img = *cache->object(getUniqueCacheKey(filename));
        return true;
    }

    return false;

}

bool PQLoadImageHelper::saveImageToCache(QString filename, QImage *img) {

    // we need to use a copy of the image here as otherwise img will have two owners (BAD idea!)
    QImage *n = new QImage(*img);
#if QT_VERSION >= QT_VERSION_CHECK(5, 10, 0)
    return cache->insert(getUniqueCacheKey(filename), n, qMin(mincost, qMax(1,static_cast<int>(n->sizeInBytes()/(1024.0*1024.0)))));
#else
    return cache->insert(getUniqueCacheKey(filename), n, qMin(mincost, qMax(1,static_cast<int>(n->byteCount()/(1024.0*1024.0)))));
#endif

}

bool PQLoadImageHelper::ensureImageFitsMaxSize(QImage &img, QSize maxSize) {

    if(maxSize.width() < 3 || maxSize.height() < 3)
        return false;

    if(img.width() > maxSize.width() || img.height() > maxSize.height()) {
        img = img.scaled(maxSize.width(), maxSize.height(), ::Qt::KeepAspectRatio, ::Qt::SmoothTransformation);
        return true;
    }

    return false;

}
