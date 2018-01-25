#include "imageproviderthumbnail.h"

ImageProviderThumbnail::ImageProviderThumbnail() : QQuickImageProvider(QQuickImageProvider::Image) {

    imageproviderfull = new ImageProviderFull;

    // Get permanent and temporary settings
    settings = new SlimSettingsReadOnly;

    // Setup database
    db = QSqlDatabase::addDatabase("QSQLITE","thumbDB" + QString::number(rand()));
    db.setDatabaseName(ConfigFiles::THUMBNAILS_DB());
    if(settings->thumbnailCache && !settings->thumbnailCacheFile)
        db.open();

    // No transaction has been started yet
    dbTransactionStarted = false;

}

QImage ImageProviderThumbnail::requestImage(const QString &filename_encoded, QSize *, const QSize &requestedSize) {

    QByteArray filename = QByteArray::fromPercentEncoding(filename_encoded.toUtf8());

    filename = filename.replace("//","/");

    if(!QFileInfo(filename).exists()) {
        QString err = QCoreApplication::translate("imageprovider", "File failed to load, it doesn't exist!");
        LOG << CURDATE << "ImageProviderFull: ERROR: " << err.toStdString() << NL;
        LOG << CURDATE << "ImageProviderFull: Filename: " << filename.toStdString() << NL;
        return ErrorImage::load(err);
    }

    // Return full thumbnail
    return getThumbnailImage(filename);

}

QImage ImageProviderThumbnail::getThumbnailImage(QByteArray filename) {

    QString typeCache = (settings->thumbnailCacheFile ? "files" : "db");
    bool cacheEnabled = settings->thumbnailCache;

    if(cacheEnabled && typeCache == "db" && !db.isOpen()) db.open();

    // Create the md5 hash for the thumbnail file
    QByteArray path = "file://" + filename;
    QByteArray md5 = QCryptographicHash::hash(path,QCryptographicHash::Md5).toHex();

    // Prepare the return QImage
    QImage p;

    // We always opt for the 256px resolution for the thumbnails,
    // as then we don't have to re-create thumbnails depending on change in settings
    int ts = 256;

    // If files in XDG_CACHE_HOME/thumbnails/ shall be used, then do use them
    if(typeCache == "files" && cacheEnabled) {

        // If there exists a thumbnail of the current file already
        if(QFile(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails/large/" + md5 + ".png").exists()) {

            p.load(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails/large/" + md5 + ".png");
            uint mtime = p.text("Thumb::MTime").trimmed().toInt();

            // Use image if it's up-to-date
            if(QFileInfo(filename).lastModified().toTime_t() == mtime)
                return p;

        }

    // otherwise use the database (default)
    } else if(cacheEnabled) {

        needToReCreatedDbThumbnail = false;

        // Query database
        QSqlQuery query(db);
        query.prepare("SELECT thumbnail,filelastmod FROM Thumbnails WHERE filepath=:fpath");
        query.bindValue(":fpath",filename);
        query.exec();

        // Check for found value
        if(query.next()) {

            // Check if updated
            if(query.value(query.record().indexOf("filelastmod")).toUInt() == QFileInfo(filename).lastModified().toTime_t()) {

                // If current thumbnail -> load it
                QByteArray b;
                b = query.value(query.record().indexOf("thumbnail")).toByteArray();
                p.loadFromData(b);

                // Cleaning up
                query.clear();

                // Return image
                return p;

            // The original image has been changed -> need to recreate thumbnail image
            } else
                needToReCreatedDbThumbnail = true;


        }

        // Cleaning up
        query.clear();

    }

    // If file wasn't loaded from file or database, then it doesn't exist yet (or isn't up-to-date anymore) and we have to create it

    // We create a temporary pointer, so that we can delete it properly afterwards
    QSize *tmp = new QSize(ts,ts);
    p = imageproviderfull->requestImage(filename.toPercentEncoding(),tmp,QSize(ts,ts));
    delete tmp;

    // Only if the image itself is smaller than the requested thumbnail size are both dimensions less than (strictly) than ts
    if(p.width() < ts && p.height() < ts)
        return p;

    // Create file cache thumbnail
    if(typeCache == "files" && cacheEnabled) {

        // If the file itself wasn't read from the thumbnails folder, is not a temporary file, and if the original file isn't at thumbnail size itself
        if(!filename.startsWith(QString(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails").toUtf8())
                && !filename.startsWith(QDir::tempPath().toUtf8())) {

            // Set some required (and additional) meta information
            p.setText("Thumb::URI", QString("file://%1").arg(QString(filename)));
            p.setText("Thumb::MTime", QString("%1").arg(QFileInfo(filename).lastModified().toTime_t()));
            QMimeDatabase mimedb;
            p.setText("Thumb::Mimetype", mimedb.mimeTypeForFile(filename).name());
            p.setText("Thumb::Size", QString("%1").arg(p.sizeInBytes()));

            // If the file does already exist, then the image has likely been updated -> delete old thumbnail image
            if(QFile(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails/large/" + md5 + ".png").exists())
                QFile(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails/large/" + md5 + ".png").remove();

            // And save new thumbnail image
            if(!p.save(ConfigFiles::GENERIC_CACHE_DIR() + "/thumbnails/large/" + md5 + ".png"))
                LOG << CURDATE << "ImageProviderThumbnail: ERROR creating new thumbnail file!" << NL;

        }

    // if not file caching -> db caching
    } else if(cacheEnabled) {

        // make sure transaction is started
        if(!dbTransactionStarted) {
            if(!db.transaction())
                qDebug() << "[imageprovider thumbs] ERROR: CAN'T START DB TRANSACTION!";
            dbTransactionStarted = true;
        }

        QSqlQuery query2(db);

        // convert image to bytearray
        QByteArray b;
        QBuffer buf(&b);
        buf.open(QIODevice::WriteOnly);

        // Always use png format
        p.save(&buf,"PNG");

        // If it was once created, i.e. if the file changed (i.e. if last mod date changed), then we have to update it
        if(needToReCreatedDbThumbnail)
            query2.prepare("UPDATE Thumbnails SET filepath=:path,thumbnail=:thb,filelastmod=:mod,thumbcreated=:crt WHERE filepath=:path");
        else
            query2.prepare("INSERT INTO Thumbnails(filepath,thumbnail,filelastmod,thumbcreated) VALUES(:path,:thb,:mod,:crt)");

        // bind the thumbnail properties
        query2.bindValue(":path",filename);
        query2.bindValue(":thb",b);
        query2.bindValue(":mod",QFileInfo(filename).lastModified().toTime_t());
        query2.bindValue(":crt",QDateTime::currentMSecsSinceEpoch());
        query2.exec();

        if(query2.lastError().text().trimmed().length())
            LOG << CURDATE << "ImageProviderThumbnail: ERROR [" << QString(filename).toStdString() << "]: " << query2.lastError().text().trimmed().toStdString() << NL;

        // cleaning up
        query2.clear();

    }

    // aaaaand done!
    return p;

}

ImageProviderThumbnail::~ImageProviderThumbnail() {
    if(dbTransactionStarted) if(!db.commit()) qDebug() << "[imageprovider thumbs ~] ERROR: CAN'T commit DB TRANSACTION!";
    db.close();
    delete imageproviderfull;
    delete settings;
}
