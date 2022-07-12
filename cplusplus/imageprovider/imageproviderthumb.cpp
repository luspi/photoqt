/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include "imageproviderthumb.h"
#include "../settings/settings.h"

QQuickImageResponse *PQAsyncImageProviderThumb::requestImageResponse(const QString &url, const QSize &requestedSize) {

    DBG << CURDATE << "PQAsyncImageProviderThumb::requestImageResponse()" << NL
        << CURDATE << "** url = " << url.toStdString() << NL;

    PQAsyncImageResponseThumb *response = new PQAsyncImageResponseThumb(url, ((requestedSize.isValid() && !requestedSize.isNull()) ? requestedSize : QSize(256,256)));
    QThreadPool::globalInstance()->setMaxThreadCount(qMax(1,PQSettings::get()["thumbnailsMaxNumberThreads"].toInt()));
    pool.start(response);
    return response;
}

PQAsyncImageResponseThumb::PQAsyncImageResponseThumb(const QString &url, const QSize &requestedSize) : m_requestedSize(requestedSize) {
    m_url = url;
    if(url.startsWith("::muted::")) {
        m_muted = true;
        m_url = m_url.remove(0, 9);
    } else
        m_muted = false;
    setAutoDelete(false);
    foundExternalUnrar = -1;
    loader = new PQLoadImage;
    load_err = new PQLoadImageErrorImage;
}

PQAsyncImageResponseThumb::~PQAsyncImageResponseThumb() {
    delete loader;
    delete load_err;
}

QQuickTextureFactory *PQAsyncImageResponseThumb::textureFactory() const {
    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

void PQAsyncImageResponseThumb::muteColors(QImage &img) {

    for (int y = 0; y < img.height(); y++) {
        QRgb *line = (QRgb *) img.scanLine(y);
        for (int x = 0; x < img.width(); x++) {
            auto hsv = QColor(line[x]).toHsv();
            hsv.setHsv(hsv.hsvHue(), hsv.hsvSaturation(), qMin(hsv.value()/4, 64));
            line[x] = hsv.rgb();
        }
    }

}

void PQAsyncImageResponseThumb::run() {

    QString filename = QByteArray::fromPercentEncoding(m_url.toUtf8());
    filename = filename.replace("&#39;","'");

    // Create the md5 hash for the thumbnail file
    QByteArray path = QUrl::fromLocalFile(filename).toString().toUtf8();
    QByteArray md5 = QCryptographicHash::hash(path,QCryptographicHash::Md5).toHex();

    // Prepare the return QImage
    QImage p;

    // We always opt for the 256px resolution for the thumbnails,
    // as then we don't have to re-create thumbnails depending on change in settings
    bool lookInCache = (m_requestedSize.width() == 256 && m_requestedSize.height() == 256);

    // If files in XDG_CACHE_HOME/thumbnails/ shall be used, then do use them
    if(lookInCache && PQSettings::get()["thumbnailsCache"].toBool()) {

        // If there exists a thumbnail of the current file already
        if(QFile(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails/large/" + md5 + ".png").exists()) {

            DBG << CURDATE << "ImageProviderThumbnail: Found cached thumbnail (file cache): "
                << QFileInfo(filename).fileName().toStdString() << NL;

            p.load(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails/large/" + md5 + ".png");
            uint mtime = p.text("Thumb::MTime").trimmed().toInt();

            // Use image if it's up-to-date
            if(QFileInfo(filename).lastModified().toTime_t() == mtime) {

                if(m_muted)
                    muteColors(p);

                m_image = p;
                Q_EMIT finished();
                return;
            } else
                DBG << CURDATE << "ImageProviderThumbnail: Image was modified since thumbnail creation, not using cached thumbnail: "
                    << QFileInfo(filename).fileName().toStdString() << NL;

        }

    }

    /**********************************************************/

    // If file wasn't loaded from file or database, then it doesn't exist yet (or isn't up-to-date anymore) and we have to create it

    QString filenameForChecking = filename;
    if(filenameForChecking.contains("::PQT::"))
        filenameForChecking = filenameForChecking.split("::PQT::").at(1);
    if(filenameForChecking.contains("::ARC::"))
        filenameForChecking = filenameForChecking.split("::ARC::").at(1);

    // We create a temporary pointer, so that we can delete it properly afterwards
    if(!QFileInfo::exists(filenameForChecking)) {
        QString err = QCoreApplication::translate("imageprovider", "File failed to load, it does not exist!");
        LOG << CURDATE << "ImageProviderThumb: ERROR: " << err.toStdString() << NL;
        LOG << CURDATE << "ImageProviderThumb: Filename: " << filenameForChecking.toStdString() << NL;
        m_image = load_err->load(err);
        Q_EMIT finished();
        return;
    }

    // Load image
    QSize origSize;
    QString msg = loader->load(filename, m_requestedSize, origSize, p);

    /**********************************************************/

    if(p.isNull() || msg != "") {

        m_image = QIcon(":/filedialog/unknownfile.svg").pixmap(m_requestedSize).toImage();
        Q_EMIT finished();
        return;

    }

    if((p.width() < m_requestedSize.width() && p.height() < m_requestedSize.height())) {
        DBG << CURDATE << "ImageProviderThumbnail: Image is smaller than potential thumbnail, no need to cache: "
            << QFileInfo(filename).fileName().toStdString() << NL;

        m_image = p;
        Q_EMIT finished();
        return;
    }

    // scale thumbnail
    if(m_requestedSize.width() > 2 && m_requestedSize.height() > 2 && origSize.width() > m_requestedSize.width() && origSize.height() > m_requestedSize.height())
        p = p.scaled(m_requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    // Create file cache thumbnail
    if(lookInCache && PQSettings::get()["thumbnailsCache"].toBool() && msg != "x") {

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
            else
                DBG << CURDATE << "ImageProviderThumbnail: Successfully cached thumbnail (file cache): "
                    << QFileInfo(filename).fileName().toStdString() << NL;

        }

    }

    // check if colors are to be muted
    if(m_muted)
        muteColors(p);

    // aaaaand done!
    m_image = p;
    Q_EMIT finished();

}
