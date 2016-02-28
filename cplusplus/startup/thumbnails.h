#ifndef STARTUPCHECK_STARTUPTHUMBNAILS_H
#define STARTUPCHECK_STARTUPTHUMBNAILS_H

#include <QFile>
#include <QtSql>
#include "../logger.h"

namespace StartupCheck {

	namespace Thumbnails {

		static inline void checkThumbnailsDatabase(int update, bool nothumbs, QString *settingsText, bool verbose) {

			if(verbose) LOG << DATE << "StartupCheck::Thumbnails" << std::endl;

			// We do two checks here:
			// 1) if 'thumbs'/'no-thumbs' option passed -> double check settings
			// 2) check database state

			// --> (1)
			if(nothumbs) {
				if(settingsText->contains("ThumbnailDisable=0"))
					*settingsText = settingsText->replace("ThumbnailDisable=0","ThumbnailDisable=1");
				else if(!settingsText->contains("ThumbnailDisable="))
					*settingsText += "ThumbnailDisable=1\n";
			} else {
				if(settingsText->contains("ThumbnailDisable=1"))
					*settingsText = settingsText->replace("ThumbnailDisable=1","ThumbnailDisable=0");
			}

			// --> (2)
			// Check if thumbnail database exists. If not, create it
			QFile database(CFG_THUMBNAILS_DB);
			if(!database.exists()) {

				if(verbose) LOG << DATE << "Create Thumbnail Database" << std::endl;

				QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "thumbDB1");
				db.setDatabaseName(CFG_THUMBNAILS_DB);
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
				db.setDatabaseName(CFG_THUMBNAILS_DB);
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

#endif // STARTUPCHECK_STARTUPTHUMBNAILS_H
