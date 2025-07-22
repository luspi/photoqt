/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

#include <pqc_providerthumb.h>
#include <pqc_providericon.h>
#include <pqc_settingscpp.h>
#include <pqc_configfiles.h>
#include <pqc_loadimage.h>
#include <scripts/cpp/pqc_scriptsfilespaths.h>
#include <QSvgRenderer>
#include <QPainter>
#include <QCryptographicHash>
#include <QCoreApplication>

#ifdef WIN32
#include <Windows.h>
#include <ShObjIdl.h>
#include <Shlwapi.h>
#include <thumbcache.h>
#endif

QQuickImageResponse *PQCAsyncImageProviderThumb::requestImageResponse(const QString &url, const QSize &requestedSize) {

    PQCAsyncImageResponseThumb *response = new PQCAsyncImageResponseThumb(url, ((requestedSize.isValid() && !requestedSize.isNull()) ? requestedSize : QSize(256,256)));
    QThreadPool::globalInstance()->setMaxThreadCount(qMax(1,PQCSettingsCPP::get().getThumbnailsMaxNumberThreads()));
    pool.start(response);
    return response;
}

PQCAsyncImageResponseThumb::PQCAsyncImageResponseThumb(const QString &url, const QSize &requestedSize) : m_requestedSize(requestedSize) {
    m_url = url;
    setAutoDelete(false);
    providerIcon = new PQCProviderIcon;

    if(!PQCSettingsCPP::get().getThumbnailsCacheBaseDirDefault())
        PQCConfigFiles::get().setThumbnailCacheBaseDir(PQCSettingsCPP::get().getThumbnailsCacheBaseDirLocation());

}

PQCAsyncImageResponseThumb::~PQCAsyncImageResponseThumb() {
    delete providerIcon;
}

QQuickTextureFactory *PQCAsyncImageResponseThumb::textureFactory() const {
    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

void PQCAsyncImageResponseThumb::run() {
    loadImage();
}

void PQCAsyncImageResponseThumb::loadImage() {

    qDebug() << "";

    QString filename = QByteArray::fromPercentEncoding(m_url.toUtf8());
    filename = filename.replace("&#39;","'");

    QString filenameForChecking = filename;
    if(filenameForChecking.contains("::PDF::"))
        filenameForChecking = filenameForChecking.split("::PDF::").at(1);
    if(filenameForChecking.contains("::ARC::"))
        filenameForChecking = filenameForChecking.split("::ARC::").at(1);

    if(PQCSettingsCPP::get().getThumbnailsIconsOnly() || PQCScriptsFilesPaths::get().isExcludeDirFromCaching(filenameForChecking)) {
        QSize origSize;
        m_image = providerIcon->requestImage(QFileInfo(filename).suffix(), &origSize, m_requestedSize);
        Q_EMIT finished();
        return;
    }

    // Prepare the return QImage
    QImage p;

#ifdef WIN32

    // we SKIP this for now until writing thumbnails to the cache also works
    // when re-enabled, we need to make sure to also check the quality of the thumbnail to make sure it is appropriate
    /*

    // on Windows we check the global thumbnail cache for a cached thumbnail
    // if we find one we can stop, otherwise we generate a new one

    const wchar_t *wFilePath = reinterpret_cast<const wchar_t *>(QDir::toNativeSeparators(filenameForChecking).utf16());

    HRESULT hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);

    if(SUCCEEDED(hr)) {

        IShellItem *pShellItem = nullptr;
        hr = SHCreateItemFromParsingName(wFilePath, NULL, IID_PPV_ARGS(&pShellItem));

        if(SUCCEEDED(hr)) {

            IThumbnailCache *pThumbnailCache = nullptr;
            hr = CoCreateInstance(CLSID_LocalThumbnailCache, NULL, CLSCTX_INPROC, IID_PPV_ARGS(&pThumbnailCache));

            if(SUCCEEDED(hr)) {

                WTS_CACHEFLAGS cacheFlags;
                ISharedBitmap *shared_bitmap;
                hr = pThumbnailCache->GetThumbnail(pShellItem, m_requestedSize.width(), WTS_INCACHEONLY, &shared_bitmap, &cacheFlags, NULL);

                if(SUCCEEDED(hr)) {

                    HBITMAP hBitmap;
                    hr = shared_bitmap->GetSharedBitmap(&hBitmap);

                    if(SUCCEEDED(hr)) {
                        p = QImage::fromHBITMAP(hBitmap);
                        DeleteObject(&hBitmap); // Free the bitmap handle
                    }

                }

                pThumbnailCache->Release();

            }

            pShellItem->Release();

        }

        CoUninitialize();

    }

    if(!p.isNull()) {
        m_image = p;
        Q_EMIT finished();
        return;
    }

    */

#endif

    // Create the md5 hash for the thumbnail file
    QByteArray path = QUrl::fromLocalFile(filename).toString().toUtf8();
    QByteArray md5 = QCryptographicHash::hash(path,QCryptographicHash::Md5).toHex();

    QString cachedir = "";
    if(m_requestedSize.width() >= 512) {
        cachedir = "xx-large";
        m_requestedSize = QSize(1024,1024);
    } else if(m_requestedSize.width() >= 256) {
        cachedir = "x-large";
        m_requestedSize = QSize(512,512);
    } else if(m_requestedSize.width() >= 128) {
        cachedir = "large";
        m_requestedSize = QSize(256, 256);
    } else {
        cachedir = "normal";
        m_requestedSize = QSize(128, 128);
    }


    const QString thumbcachepath = PQCConfigFiles::get().THUMBNAIL_CACHE_DIR() + "/" + cachedir + "/" + md5 + ".png";

    // If files in XDG_CACHE_HOME/thumbnails/ shall be used, then do use them
    if(PQCSettingsCPP::get().getThumbnailsCache()) {

        // If there exists a thumbnail of the current file already
        if(QFile(thumbcachepath).exists()) {

            p.load(thumbcachepath);
            uint mtime = p.text("Thumb::MTime").trimmed().toInt();

            // Use image if it's up-to-date
            if(QFileInfo(filenameForChecking).lastModified().toSecsSinceEpoch() == mtime) {
                m_image = p;
                Q_EMIT finished();
                return;
            } else
                qDebug() << "Image was modified since thumbnail creation, not using cached thumbnail:" << QFileInfo(filename).fileName();

        }

    }

    /**********************************************************/

    // If file wasn't loaded from file or database, then it doesn't exist yet (or isn't up-to-date anymore) and we have to create it

    // We create a temporary pointer, so that we can delete it properly afterwards
    if(!QFileInfo::exists(filenameForChecking)) {
        QString err = QCoreApplication::translate("imageprovider", "File failed to load, it does not exist!");
        qWarning() << "ERROR:" << err;
        qWarning() << "Filename:" << filenameForChecking;
        m_image = QImage();
        Q_EMIT finished();
        return;
    }

    // Load image
    QSize origSize;
    PQCLoadImage::get().load(filename, m_requestedSize, origSize, p);

    /**********************************************************/

    if(p.isNull()) {

        const QString suf = QFileInfo(filenameForChecking).suffix().toLower();
        QString iconname = ":/filetypes/unknown.svg";
        if(QFile::exists(QString(":/filetypes/%1.svg").arg(suf)))
            iconname = QString(":/filetypes/%1.svg").arg(suf);

        QSvgRenderer svg;
        if(!svg.load(iconname))
            qWarning() << "Failed to load svg:" << iconname;

        m_image = QImage(m_requestedSize, QImage::Format_ARGB32);
        m_image.fill(::Qt::transparent);
        QPainter painter(&m_image);
        svg.render(&painter);
        painter.end();

        Q_EMIT finished();

        return;

    }

    if((p.width() < m_requestedSize.width() && p.height() < m_requestedSize.height())) {
        m_image = p;
        Q_EMIT finished();
        return;
    }

    // scale thumbnail
    if(m_requestedSize.isValid() && (origSize.width() > m_requestedSize.width() || origSize.height() > m_requestedSize.height()))
        p = p.scaled(m_requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    // Create file cache thumbnail
    if(PQCSettingsCPP::get().getThumbnailsCache()) {

        // If the file itself wasn't read from the thumbnails folder, is not a temporary file, and if the original file isn't at thumbnail size itself
        if(!filename.startsWith(QString(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR()).toUtf8()) && !filename.startsWith(QDir::tempPath().toUtf8())) {

            // make sure cache directory exists
            QDir dir;
            QFileInfo info(thumbcachepath);
            dir.mkpath(info.absolutePath());

            // Set some required (and additional) meta information
            p.setText("Thumb::URI", QString("file://%1").arg(QString(filename)));
            p.setText("Thumb::MTime", QString("%1").arg(QFileInfo(filenameForChecking).lastModified().toSecsSinceEpoch()));
            QString mime = mimedb.mimeTypeForFile(filenameForChecking, QMimeDatabase::MatchContent).name();
            // this is the default mime type if no mime type is available or file cannot be found
            if(mime != "application/octet-stream")
                p.setText("Thumb::Mimetype", mime);
            p.setText("Thumb::Size", QString("%1").arg(p.sizeInBytes()));

            // If the file does already exist, then the image has likely been updated -> delete old thumbnail image
            if(QFile(thumbcachepath).exists())
                QFile(thumbcachepath).remove();

            // And save new thumbnail image
            if(!p.save(thumbcachepath))
                qWarning() << "ERROR creating new thumbnail file:" << QFileInfo(filename).fileName();

        }

    }

    m_image = p;

    // aaaaand done!
    Q_EMIT finished();

}
