#ifndef PQASYNCIMAGEPROVIDERTHUMB_H
#define PQASYNCIMAGEPROVIDERTHUMB_H

#include <QQuickAsyncImageProvider>
#include <QThreadPool>
#include <QPixmapCache>
#include <QMimeDatabase>
#include <QCryptographicHash>
#include "../settings/imageformats.h"
#include "loadimage.h"

class PQAsyncImageProviderThumb : public QQuickAsyncImageProvider {

public:
    QQuickImageResponse *requestImageResponse(const QString &url, const QSize &requestedSize) override;

private:
    QThreadPool pool;
};

class PQAsyncImageResponseThumb : public QQuickImageResponse, public QRunnable {

public:
    PQAsyncImageResponseThumb(const QString &url, const QSize &requestedSize);

    QQuickTextureFactory *textureFactory() const override;

    void run() override;

    QString m_url;
    QSize m_requestedSize;
    QImage m_image;

private:
    QMimeDatabase mimedb;

    int foundExternalUnrar;

    QString whatDoIUse(QString filename);

    PQLoadImage *loader;
    PQLoadImageErrorImage *load_err;

};

#endif // PQASYNCIMAGEPROVIDERTHUMB_H
