#include "imageproviderthumbnail.h"

ImageProviderThumbnail::ImageProviderThumbnail() : QQuickImageProvider(QQuickImageProvider::Image) {

    imageproviderfull = new ImageProviderFull;

    // Setup database
    db = QSqlDatabase::addDatabase("QSQLITE","thumbDB" + QString::number(rand()));
    db.setDatabaseName(CFG_THUMBNAILS_DB);
    db.open();

    // Get permanent and temporary settings
    settings = new Settings;

    // No transaction has been started yet
    dbTransactionStarted = false;

}

QImage ImageProviderThumbnail::requestImage(const QString &filename_encoded, QSize *, const QSize &requestedSize) {

    QByteArray filename = QByteArray::fromPercentEncoding(filename_encoded.toUtf8());

    dontCreateThumbnailNew = false;

    // Do some special action
    if(filename.startsWith("__**__")) {
        // Smartly preload this thumbnail
        if(filename.startsWith("__**__smart")) {
            filename = filename.remove(0,11);
            dontCreateThumbnailNew = true;
        // Commit database and exit
        } else {
            if(dbTransactionStarted) if(!db.commit()) qDebug() << "[imageprovider thumbs] ERROR: CAN'T commit DB TRANSACTION!";
            dbTransactionStarted = false;
            return QImage(1,1,QImage::Format_ARGB32);
        }
    }

    // Some general settings that are needed multiple times later-on
    int width = requestedSize.width();
    if(width == -1) width = settings->thumbnailsize;

    // Return full thumbnail
    return getThumbnailImage(filename);

}

QImage ImageProviderThumbnail::getThumbnailImage(QByteArray filename) {

    QString typeCache = (settings->thbcachefile ? "files" : "db");
    bool cacheEnabled = settings->thumbnailcache;

    if(!db.isOpen()) db.open();

    // Create the md5 hash for the thumbnail file
    QByteArray path = "file://" + filename;
    QByteArray md5 = QCryptographicHash::hash(path,QCryptographicHash::Md5).toHex();

    // Prepare the return QImage
    QImage p;

    // We always opt for the 256px resolution for the thumbnails,
    // as then we don't have to re-create thumbnails depending on change in settings
    int ts = 256;

    origwidth = -1;
    origheight = -1;

    bool wasoncecreated = false;

    // If files in ~/.thumbnails/ shall be used, then do use them
    if(typeCache == "files" && cacheEnabled) {

        // If there exists a thumbnail of the current file already
        if(QFile(QDir::homePath() + "/.thumbnails/large/" + md5 + ".png").exists() && cacheEnabled) {

//			if(verbose) LOG << CURDATE << "ImageProviderThumbnail: thread: Loading existing thumb from file: " << createThisOne << NL;

            p.load(QDir::homePath() + "/.thumbnails/large/" + md5 + ".png");
            uint mtime = p.text("Thumb").remove("MTime:").trimmed().toInt();

            // Use image if it's up-to-date
            if(QFileInfo(filename).lastModified().toTime_t() == mtime) {
                QSize dim = allSizes.value(filename);
                origwidth = dim.width();
                origheight = dim.height();
                wasoncecreated = true;
            }

        }

    // otherwise use the database (default)
    } else if(cacheEnabled) {

        QSqlQuery query(db);
        query.prepare("SELECT thumbnail,filelastmod,origwidth,origheight FROM Thumbnails WHERE filepath=:fpath");
        query.bindValue(":fpath",filename);
        query.exec();
        if(query.next()) {

            if(query.value(query.record().indexOf("filelastmod")).toUInt() == QFileInfo(filename).lastModified().toTime_t()) {
//				if(verbose) LOG << CURDATE << "ImageProviderThumbnail: thread: Loading existing thumb from db: " << createThisOne << NL;
                QByteArray b;
                b = query.value(query.record().indexOf("thumbnail")).toByteArray();
                p.loadFromData(b);
                origwidth = query.value(query.record().indexOf("origwidth")).toInt();
                origheight = query.value(query.record().indexOf("origheight")).toInt();
                wasoncecreated = true;
            }


        }

        query.clear();

    }

    // If file wasn't loaded from file or database, then it doesn't exist yet (or isn't up-to-date anymore) and we have to create it

    if(!wasoncecreated && !dontCreateThumbnailNew) {

        // We create a temporary pointer, so that we can delete it properly afterwards
        QSize *tmp = new QSize(ts,ts);
        p = imageproviderfull->requestImage(filename.toPercentEncoding(),tmp,QSize(ts,ts));
        delete tmp;

        origwidth = imageproviderfull->origSize.width();
        origheight = imageproviderfull->origSize.height();

        if(typeCache == "files" && cacheEnabled) {

            // If the file itself wasn't read from the thumbnails folder, is not a temporary file, and if the original file isn't at thumbnail size itself
            if(filename.startsWith(QString(CFG_THUMBNAILS_DB).toUtf8())
                    && !filename.startsWith(QDir::tempPath().toUtf8())
                    && (p.height() > ts || p.width() > ts)) {

                // We use a QImageWriter (faster, metainfo support) - the path is a temporary path (for reason, see below)
                QImageWriter writer(QDir::tempPath() + "/" + md5 + "__photo.png","png");

                // The following meta information is required by the freedesktop standard
                writer.setText("Thumb::MTime",QString("%1").arg(QFileInfo(filename).lastModified().toTime_t()));

                // We write the temporary file
                writer.write(p);

                // If the file still doesn't exist, copy it to the right location (>> protection from concurrency)
                if(QFile(QDir::homePath() + "/cache/.thumbnails/large/" + md5 + ".png").exists())
                    QFile(QDir::homePath() + "/cache/.thumbnails/large/" + md5 + ".png").remove();

                if(!QFile(QDir::tempPath() + "/" + md5 + "__photo.png").copy(QDir::homePath() + "/cache/.thumbnails/large/" + md5 + ".png"))
                    LOG << CURDATE << "ImageProviderThumbnail: ERROR creating new thumbnail file!" << NL;
                // Delete temporary file
                QFile(QDir::tempPath() + "/" + md5 + "__photo.png").remove();

            }

        } else if(cacheEnabled) {

            if(!dbTransactionStarted) {
                if(!db.transaction())
                    qDebug() << "[imageprovider thumbs] ERROR: CAN'T START DB TRANSACTION!";
                dbTransactionStarted = true;
            }

            QSqlQuery query2(db);

            QByteArray b;
            QBuffer buf(&b);
            buf.open(QIODevice::WriteOnly);

            // If file has transparent areas, we save it as png to preserver transparency. Otherwise we choose jpg (smaller)
            if(p.hasAlphaChannel())
                p.save(&buf,"PNG");
            else
                p.save(&buf,"JPG");

            // If it was once created, i.e. if the file changed (i.e. if last mod date changed), then we have to update it
            if(wasoncecreated)
                query2.prepare("UPDATE Thumbnails SET filepath=:path,thumbnail=:thb,filelastmod=:mod,thumbcreated=:crt,origwidth=:origw,origheight=:origh WHERE filepath=:path");
            else
                query2.prepare("INSERT INTO Thumbnails(filepath,thumbnail,filelastmod,thumbcreated,origwidth,origheight) VALUES(:path,:thb,:mod,:crt,:origw,:origh)");

            query2.bindValue(":path",filename);
            query2.bindValue(":thb",b);
            query2.bindValue(":mod",QFileInfo(filename).lastModified().toTime_t());
            query2.bindValue(":crt",QDateTime::currentMSecsSinceEpoch());
            query2.bindValue(":origw",origwidth);
            query2.bindValue(":origh",origheight);
            query2.exec();
            if(query2.lastError().text().trimmed().length())
                LOG << CURDATE << "ImageProviderThumbnail: ERROR [" << QString(filename).toStdString() << "]: " << query2.lastError().text().trimmed().toStdString() << NL;
            query2.clear();

        }

    } else if(!wasoncecreated && dontCreateThumbnailNew)
        p = QImage(1,1,QImage::Format_ARGB32);

    return p;

}

ImageProviderThumbnail::~ImageProviderThumbnail() {
    if(dbTransactionStarted) if(!db.commit()) qDebug() << "[imageprovider thumbs ~] ERROR: CAN'T commit DB TRANSACTION!";
    db.close();
    delete imageproviderfull;
    delete settings;
}
