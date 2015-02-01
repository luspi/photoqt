#include "imageproviderthumbnail.h"

ImageProviderThumbnail::ImageProviderThumbnail() : QQuickImageProvider(QQuickImageProvider::Pixmap) {

	// Setup database
	db = QSqlDatabase::addDatabase("QSQLITE","thumbDB" + QString::number(rand()));
	db.setDatabaseName(QDir::homePath() + "/.photoqt/thumbnails");
	db.open();

	// Get permanent and temporary settings
	settings = new Settings;

	// No transaction has been started yet
	dbTransactionStarted = false;

}

QPixmap ImageProviderThumbnail::requestPixmap(const QString &filename_encoded, QSize *size, const QSize &requestedSize) {

	QByteArray filename = QByteArray::fromPercentEncoding(filename_encoded.toUtf8());

	// Commit database and exit
	if(filename.startsWith("__**__")) {
		if(db.isOpen()) db.commit();
		db.close();
		dbTransactionStarted = false;
		return QPixmap(1,1);
	}

	// Some general settings that are needed multiple times later-on
	int width = requestedSize.width();
	if(width == -1) width = settings->value("Thumbnail/ThumbnailSize").toInt();
	int thbsize = settings->value("Thumbnail/ThumbnailSize").toInt();

	// Get full thumbnail
	QImage thumbnail = getThumbnailImage(filename, width);


	// Scaling it here as opposed to simple passing it on to QML and letting it handle the scaling there
	// yields much better quality (no matter if 'smooth' or 'minimap' property is set in QML)

	// Get right image dimensions
	int w = thumbnail.width();
	int h = thumbnail.height();
	if(w > thbsize) {
		double q = (double)thbsize/(double)w;
		w *= q;
		h *= q;
	}
	if(h > thbsize) {
		double q = (double)thbsize/(double)h;
		w *= q;
		h *= q;
	}

	// Scale image
	thumbnail = thumbnail.scaled(w,h,Qt::IgnoreAspectRatio,Qt::SmoothTransformation);

	return QPixmap::fromImage(thumbnail);

}

QImage ImageProviderThumbnail::getThumbnailImage(QByteArray filename, int thbsize) {

	QString typeCache = (settings->value("Thumbnail/ThbCacheFile").toBool() ? "files" : "db");
	bool cacheEnabled = settings->value("Thumbnail/ThumbnailCache").toBool();

	if(!db.isOpen()) db.open();

	// Create the md5 hash for the thumbnail file
	QByteArray path = "file://" + filename;
	QByteArray md5 = QCryptographicHash::hash(path,QCryptographicHash::Md5).toHex();

	// Prepare the return QImage
	QImage p;

	// We always opt for the 256px resolution for the thumbnails,
	// as then we don't have to re-create thumbnails depending on change in settings
	int ts = 256;

	int origwidth = -1;
	int origheight = -1;

	bool wasoncecreated = false;

	// If files in ~/.thumbnails/ shall be used, then do use them
	if(typeCache == "files" && cacheEnabled) {

		// If there exists a thumbnail of the current file already
		if(QFile(QDir::homePath() + "/.thumbnails/large/" + md5 + ".png").exists() && cacheEnabled) {

//			if(verbose) std::clog << "thread: Loading existing thumb from file: " << createThisOne << std::endl;

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
		query.exec(QString("SELECT thumbnail,filelastmod,origwidth,origheight FROM Thumbnails WHERE filepath='%1'").arg(QString::fromUtf8(filename)));
		if(query.next()) {

			if(query.value(query.record().indexOf("filelastmod")).toUInt() == QFileInfo(filename).lastModified().toTime_t()) {
//				if(verbose) std::clog << "thread: Loading existing thumb from db: " << createThisOne << std::endl;
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

	if(!wasoncecreated) {

		ImageProviderFull image;
		p = image.requestImage(filename.toPercentEncoding(),new QSize(ts,ts),QSize(ts,ts));

		origwidth = image.origSize.width();
		origheight = image.origSize.height();

		if(typeCache == "files" && cacheEnabled) {

			// If the file itself wasn't read from the thumbnails folder, is not a temporary file, and if the original file isn't at thumbnail size itself
			if(filename.startsWith((QDir::homePath() + "/.thumbnails/").toLatin1())
					&& !filename.startsWith(QDir::tempPath().toLatin1())
					&& (p.height() > ts || p.width() > ts)) {

				// We use a QImageWriter (faster, metainfo support) - the path is a temporary path (for reason, see below)
				QImageWriter writer(QDir::tempPath() + "/" + md5 + "__photo.png","png");

				// The following meta information is required by the freedesktop standard
				writer.setText("Thumb::MTime",QString("%1").arg(QFileInfo(filename).lastModified().toTime_t()));

				// We write the temporary file
				writer.write(p);

				// If the file still doesn't exist, copy it to the right location (>> protection from concurrency)
				if(QFile(QDir::homePath() + "/.thumbnails/large/" + md5 + ".png").exists())
					QFile(QDir::homePath() + "/.thumbnails/large/" + md5 + ".png").remove();

				if(!QFile(QDir::tempPath() + "/" + md5 + "__photo.png").copy(QDir::homePath() + "/.thumbnails/large/" + md5 + ".png"))
					std::cerr << "ERROR creating new thumbnail file!" << std::endl;
				// Delete temporary file
				QFile(QDir::tempPath() + "/" + md5 + "__photo.png").remove();

			}

		} else if(cacheEnabled) {

			if(!dbTransactionStarted) {
				db.transaction();
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
				std::cerr << "ERROR [" << filename.toStdString() << "]: " << query2.lastError().text().trimmed().toStdString() << std::endl;
			query2.clear();

		}

	}

	return p;

}

ImageProviderThumbnail::~ImageProviderThumbnail() {
	db.commit();
	db.close();
}
