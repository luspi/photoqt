#ifndef STARTUPTHUMBNAILS_H
#define STARTUPTHUMBNAILS_H

#include <QFile>
#include <QtSql>
#include "../logger.h"

namespace StartupCheck {

	namespace Thumbnails {

		static inline void checkThumbnailsDatabase(int update, bool verbose) {

			if(verbose) LOG << DATE << "StartupCheck::Thumbnails" << std::endl;

			// Check if thumbnail database exists. If not, create it
			QFile database(QDir::homePath() + "/.photoqt/thumbnails");
			if(!database.exists()) {

				if(verbose) LOG << DATE << "Create Thumbnail Database" << std::endl;

				QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "thumbDB1");
				db.setDatabaseName(QDir::homePath() + "/.photoqt/thumbnails");
				if(!db.open()) LOG << DATE << "ERROR: Couldn't open thumbnail database:" << db.lastError().text().trimmed().toStdString() << std::endl;
				QSqlQuery query(db);
				query.prepare("CREATE TABLE Thumbnails (filepath TEXT,thumbnail BLOB, filelastmod INT, thumbcreated INT, origwidth INT, origheight INT)");
				query.exec();
				if(query.lastError().text().trimmed().length()) LOG << DATE << "ERROR (Creating Thumbnail Datbase):" << query.lastError().text().trimmed().toStdString() << std::endl;
				query.clear();


			} else if(update != 0) {

				if(verbose) LOG << DATE << "Opening Thumbnail Database" << std::endl;

				// Opening the thumbnail database
				QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE","thumbDB2");
				db.setDatabaseName(QDir::homePath() + "/.photoqt/thumbnails");
				if(!db.open()) LOG << DATE << "ERROR: Couldn't open thumbnail database:" << db.lastError().text().trimmed().toStdString() << std::endl;

				QSqlQuery query_check(db);
				query_check.prepare("SELECT COUNT( * ) AS 'Count' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Thumbnails' AND COLUMN_NAME = 'origwidth'");
				query_check.exec();
				query_check.next();
				if(query_check.record().value(0) == 0) {
					QSqlQuery query(db);
					query.prepare("ALTER TABLE Thumbnails ADD COLUMN origwidth INT");
					query.exec();
					if(query.lastError().text().trimmed().length()) LOG << DATE << "ERROR (Adding origwidth to Thumbnail Database):" << query.lastError().text().trimmed().toStdString() << std::endl;
					query.clear();
					query.prepare("ALTER TABLE Thumbnails ADD COLUMN origheight INT");
					query.exec();
					if(query.lastError().text().trimmed().length()) LOG << DATE << "ERROR (Adding origheight to Thumbnail Database):" << query.lastError().text().trimmed().toStdString() << std::endl;
					query.clear();
				}
				query_check.clear();

			}

		}

	}

}

#endif // STARTUPTHUMBNAILS_H
