/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef STARTUPCHECK_STARTUPTHUMBNAILS_H
#define STARTUPCHECK_STARTUPTHUMBNAILS_H

#include <QFile>
#include <QtSql>
#include "../logger.h"

namespace StartupCheck {

    namespace Thumbnails {

        static inline void checkThumbnailsDatabase(int update, bool nothumbs, QString *settingsText, bool verbose) {

            if(verbose) LOG << CURDATE << "StartupCheck::Thumbnails" << NL;

            // We do two checks here:
            // 1) if 'thumbs'/'no-thumbs' option passed -> double check settings
            // 2) check database state

            // --> (1)
            if(nothumbs) {
                if(settingsText->contains("ThumbnailDisable=0"))
                    *settingsText = settingsText->replace("ThumbnailDisable=0","ThumbnailDisable=1");
                else if(!settingsText->contains("ThumbnailDisable="))
                    *settingsText += "ThumbnailDisable=1\n";
            }

            // --> (2)
            // Check if thumbnail database exists. If not, create it
            QFile database(CFG_THUMBNAILS_DB);
            if(!database.exists()) {

                if(verbose) LOG << CURDATE << "Create Thumbnail Database" << NL;

                QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "thumbDB1");
                db.setDatabaseName(CFG_THUMBNAILS_DB);
                if(!db.open()) LOG << CURDATE << "ERROR: Couldn't open thumbnail database:" << db.lastError().text().trimmed().toStdString() << NL;
                QSqlQuery query(db);
                query.prepare("CREATE TABLE Thumbnails (filepath TEXT,thumbnail BLOB, filelastmod INT, thumbcreated INT, origwidth INT, origheight INT)");
                query.exec();
                if(query.lastError().text().trimmed().length()) LOG << CURDATE << "ERROR (Creating Thumbnail Datbase):" << query.lastError().text().trimmed().toStdString() << NL;
                query.clear();


            } else if(update != 0) {

                if(verbose) LOG << CURDATE << "Opening Thumbnail Database" << NL;

                // Opening the thumbnail database
                QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE","thumbDB2");
                db.setDatabaseName(CFG_THUMBNAILS_DB);
                if(!db.open()) LOG << CURDATE << "ERROR: Couldn't open thumbnail database:" << db.lastError().text().trimmed().toStdString() << NL;

                QSqlQuery query_check(db);
                query_check.prepare("SELECT COUNT( * ) AS 'Count' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Thumbnails' AND COLUMN_NAME = 'origwidth'");
                query_check.exec();
                query_check.next();
                if(query_check.record().value(0) == 0) {
                    QSqlQuery query(db);
                    query.prepare("ALTER TABLE Thumbnails ADD COLUMN origwidth INT");
                    query.exec();
                    if(query.lastError().text().trimmed().length()) LOG << CURDATE << "ERROR (Adding origwidth to Thumbnail Database):" << query.lastError().text().trimmed().toStdString() << NL;
                    query.clear();
                    query.prepare("ALTER TABLE Thumbnails ADD COLUMN origheight INT");
                    query.exec();
                    if(query.lastError().text().trimmed().length()) LOG << CURDATE << "ERROR (Adding origheight to Thumbnail Database):" << query.lastError().text().trimmed().toStdString() << NL;
                    query.clear();
                }
                query_check.clear();

            }

        }

    }

}

#endif // STARTUPCHECK_STARTUPTHUMBNAILS_H
