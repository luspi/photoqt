#include "imageproviderthumb.h"
#include "loader/errorimage.h"
#include "loader/loadimage_qt.h"

QQuickImageResponse *PQAsyncImageProviderThumb::requestImageResponse(const QString &url, const QSize &requestedSize) {
    PQAsyncImageResponseThumb *response = new PQAsyncImageResponseThumb(url, requestedSize);
    pool.start(response);
    return response;
}

PQAsyncImageResponseThumb::PQAsyncImageResponseThumb(const QString &url, const QSize &requestedSize) : m_url(url), m_requestedSize(requestedSize) {
    setAutoDelete(false);
    imageformats = new PQImageFormats;
}

QQuickTextureFactory *PQAsyncImageResponseThumb::textureFactory() const {
    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

void PQAsyncImageResponseThumb::run() {

    QString filename = QByteArray::fromPercentEncoding(m_url.toUtf8());

//    QString typeCache = "files"; // (settings->thumbnailCacheFile ? "files" : "db");
    bool cacheEnabled = true; // settings->thumbnailCache;

    // Create the md5 hash for the thumbnail file
    QByteArray path = QUrl::fromLocalFile(filename).toString().toUtf8();
    QByteArray md5 = QCryptographicHash::hash(path,QCryptographicHash::Md5).toHex();

    // Prepare the return QImage
    QImage p;

    // We always opt for the 256px resolution for the thumbnails,
    // as then we don't have to re-create thumbnails depending on change in settings
    m_requestedSize = QSize(256, 256);

    // If files in XDG_CACHE_HOME/thumbnails/ shall be used, then do use them
    if(cacheEnabled) {

        // If there exists a thumbnail of the current file already
        if(QFile(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails/large/" + md5 + ".png").exists()) {

            if(qgetenv("PHOTOQT_DEBUG") == "yes")
                LOG << CURDATE << "ImageProviderThumbnail: Found cached thumbnail (file cache): " <<
                       QFileInfo(filename).fileName().toStdString() << NL;

            p.load(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails/large/" + md5 + ".png");
            uint mtime = p.text("Thumb::MTime").trimmed().toInt();

            // Use image if it's up-to-date
            if(QFileInfo(filename).lastModified().toTime_t() == mtime) {
                m_image = p;
                emit finished();
                return;
            }
            else if(qgetenv("PHOTOQT_DEBUG") == "yes")
                LOG << CURDATE << "ImageProviderThumbnail: Image was modified since thumbnail creation, not using cached thumbnail: " <<
                       QFileInfo(filename).fileName().toStdString() << NL;

        }

    }

    /**********************************************************/

    // If file wasn't loaded from file or database, then it doesn't exist yet (or isn't up-to-date anymore) and we have to create it

    // We create a temporary pointer, so that we can delete it properly afterwards
    if(!QFileInfo(filename).exists()) {
        QString err = QCoreApplication::translate("imageprovider", "File failed to load, it doesn't exist!");
        LOG << CURDATE << "ImageProviderFull: ERROR: " << err.toStdString() << NL;
        LOG << CURDATE << "ImageProviderFull: Filename: " << filename.toStdString() << NL;
        p = PQLoadImage::ErrorImage::load(err);
    }

    // Which GraphicsEngine should we use?
    QString whatToUse = whatDoIUse(filename);

    QSize origSize;

    // the unique key for caching
    QByteArray cachekey = getUniqueCacheKey(filename);

    if(whatToUse == "qt")
        p = PQLoadImage::Qt::load(filename, m_requestedSize, &origSize, true);

    // return scaled version
    if(m_requestedSize.width() > 2 && m_requestedSize.height() > 2 && origSize.width() > m_requestedSize.width() && origSize.height() > m_requestedSize.height())
        p = p.scaled(m_requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    /**********************************************************/

    if(p.isNull()) {

        m_image = QIcon(":/filedialog/unknownfile.svg").pixmap(m_requestedSize).toImage();
        emit finished();
        return;

    }

    if((p.width() < m_requestedSize.width() && p.height() < m_requestedSize.height())) {
        if(qgetenv("PHOTOQT_DEBUG") == "yes")
            LOG << CURDATE << "ImageProviderThumbnail: Image is smaller than potential thumbnail, no need to cache: " <<
                   QFileInfo(filename).fileName().toStdString() << NL;
        m_image = p;
        emit finished();
        return;
    }

    // Create file cache thumbnail
    if(cacheEnabled) {

        // If the file itself wasn't read from the thumbnails folder, is not a temporary file, and if the original file isn't at thumbnail size itself
        if(!filename.startsWith(QString(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails").toUtf8())
                && !filename.startsWith(QDir::tempPath().toUtf8())) {

            // Set some required (and additional) meta information
            p.setText("Thumb::URI", QString("file://%1").arg(QString(filename)));
            p.setText("Thumb::MTime", QString("%1").arg(QFileInfo(filename).lastModified().toTime_t()));
            QString mime = mimedb.mimeTypeForFile(filename, QMimeDatabase::MatchContent).name();
            // this is the default mime type if no mime type is available or file cannot be found
            if(mime != "application/octet-stream")
                p.setText("Thumb::Mimetype", mime);
#if (QT_VERSION >= QT_VERSION_CHECK(5, 10, 0))
            p.setText("Thumb::Size", QString("%1").arg(p.sizeInBytes()));
#else
            QFileInfo info(filename);
            p.setText("Thumb::Size", QString("%1").arg(info.size()));
#endif

            // If the file does already exist, then the image has likely been updated -> delete old thumbnail image
            if(QFile(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails/large/" + md5 + ".png").exists())
                QFile(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails/large/" + md5 + ".png").remove();

            // And save new thumbnail image
            if(!p.save(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails/large/" + md5 + ".png"))
                LOG << CURDATE << "ImageProviderThumbnail: ERROR creating new thumbnail file: " <<
                       QFileInfo(filename).fileName().toStdString() << NL;
            else if(qgetenv("PHOTOQT_DEBUG") == "yes")
                LOG << CURDATE << "ImageProviderThumbnail: Successfully cached thumbnail (file cache): " <<
                       QFileInfo(filename).fileName().toStdString() << NL;

        }

    }

    // aaaaand done!
    m_image = p;
    emit finished();

}

QString PQAsyncImageResponseThumb::whatDoIUse(QString filename) {

    if(filename.trimmed() == "") return "qt";

    QString useThisFilename = filename;
    QFileInfo info(useThisFilename);

    /***********************************************************/
    // Qt image plugins

    if(info.suffix().toLower() == "svg" || info.suffix().toLower() == "svgz")
        return "svg";

    if(imageformats->getEnabledFileformatsQt().contains("*." + info.suffix().toLower()))
        return "qt";

    return "qt";

}

QByteArray PQAsyncImageResponseThumb::getUniqueCacheKey(QString path) {
    path = path.remove("image://full/");
    path = path.remove("file:/");
    QFileInfo info(path);
    QString fn = QString("%1%2").arg(path).arg(info.lastModified().toMSecsSinceEpoch());
    return QCryptographicHash::hash(fn.toUtf8(),QCryptographicHash::Md5).toHex();
}
