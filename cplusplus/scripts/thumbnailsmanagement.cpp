#include "thumbnailsmanagement.h"

ThumbnailManagement::ThumbnailManagement(QObject *parent) : QObject(parent) {

	// Opening the thumbnail database
	db = QSqlDatabase::addDatabase("QSQLITE", "thumbDB");
	db.setDatabaseName(CFG_THUMBNAILS_DB);
	if(!db.open())
		std::cerr << "ERROR: Can't open thumbnail database: " << db.lastError().text().trimmed().toStdString() << std::endl;

}

qint64 ThumbnailManagement::getDatabaseFilesize() {

	return QFileInfo(CFG_THUMBNAILS_DB).size()/1024;

}

int ThumbnailManagement::getNumberDatabaseEntries() {

	QSqlQuery query(db);
	query.exec("SELECT COUNT(filepath) AS c FROM Thumbnails");
	if(query.lastError().text().trimmed().length()) {
		std::cerr << "ERROR: (Count) " << query.lastError().text().trimmed().toStdString() << std::endl;
		query.clear();
		return 0;
	}

	query.next();

	int num = query.value(query.record().indexOf("c")).toInt();
	query.clear();
	return num;

}

void ThumbnailManagement::cleanDatabase() {

//	if(verbose) std::clog << "thb: Clean database" << std::endl;

	QSqlQuery query(db);

	// First, we remove all entries with empty filepath (something went wrong there)
	query.prepare("DELETE FROM Thumbnails WHERE filepath=''");
	query.exec();
	query.clear();

	// Then lets look at the remaining entries
	query.prepare("SELECT * FROM Thumbnails");
	query.exec();

	// First we create a list of items that are to be deleted
	QList<QStringList> toDel;
	while(query.next()) {
		QString path = query.value(query.record().indexOf("filepath")).toString();
		int mtime = query.value(query.record().indexOf("filelastmod")).toInt();

		if(!QFile(path).exists() || mtime != int(QFileInfo(path).lastModified().toTime_t())) {

			QStringList l;
			l << path << QString("%1").arg(mtime);
			toDel << l;

		}

	}
	query.clear();

	// Then we actually delete all the items
	for(int i = 0; i < toDel.length(); ++i) {

		QSqlQuery query2(db);
		query2.prepare("DELETE FROM Thumbnails WHERE filepath=:path AND filelastmod=:mod");
		query2.bindValue(":mod",toDel.at(i).at(1));
		query2.bindValue(":path",toDel.at(i).at(0));
		query2.exec();
		if(query2.lastError().text().trimmed().length())
			std::cerr << "ERROR (del): " << query2.lastError().text().trimmed().toStdString() << std::endl;
		query2.clear();

	}

	// Error catching
	if(db.lastError().text().trimmed().length())
		std::cerr << "ERROR (after del): " << db.lastError().text().trimmed().toStdString() << std::endl;


	// Compress database
	QSqlQuery query3(db);
	query3.prepare("VACUUM");
	query3.exec();
	if(query3.lastError().text().trimmed().length())
		std::cerr << "ERROR: (Vacuum) " << query3.lastError().text().trimmed().toStdString() << std::endl;
	query3.clear();

}

void ThumbnailManagement::eraseDatabase() {

//	if(verbose) std::clog << "thb: Erase database" << std::endl;

	QSqlQuery query(db);

	// DROP old table with all data
	query.prepare("DROP TABLE Thumbnails");
	query.exec();
	if(query.lastError().text().trimmed().length())
		std::cerr << "ERROR: (Drop) " << query.lastError().text().trimmed().toStdString() << std::endl;
	query.clear();

	// VACUUM database (decrease size)
	query.prepare("VACUUM");
	query.exec();
	if(query.lastError().text().trimmed().length())
		std::cerr << "ERROR: (Vacuum) " << query.lastError().text().trimmed().toStdString() << std::endl;
	query.clear();

	// Create new table
	query.prepare("CREATE TABLE Thumbnails (filepath TEXT,thumbnail BLOB, filelastmod INT, thumbcreated INT, origwidth INT, origheight INT)");
	query.exec();
	if(query.lastError().text().trimmed().length())
		std::cerr << "ERROR (Creating Thumbnail Datbase): " << query.lastError().text().trimmed().toStdString() << std::endl;
	query.clear();

}
