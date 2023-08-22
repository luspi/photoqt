#include <pqc_resolutioncache.h>

#include <QFileInfo>
#include <QCryptographicHash>
#include <QSize>

PQCResolutionCache::PQCResolutionCache(QObject *parent) : QObject(parent) {}
PQCResolutionCache::~PQCResolutionCache() {}

void PQCResolutionCache::saveResolution(QString filename, QSize res) {
    qDebug() << "args: filename =" << filename;
    qDebug() << "args: res =" << res;
    resolution[getKey(filename)] = res;
}

QSize PQCResolutionCache::getResolution(QString filename) {
    return resolution[getKey(filename)];
}

QString PQCResolutionCache::getKey(QString filename) {
    QFileInfo info(filename);
    return QCryptographicHash::hash(QString("%1%2").arg(filename).arg(info.size()).toUtf8(),QCryptographicHash::Md5).toHex();
}
