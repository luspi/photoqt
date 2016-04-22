#ifndef THUMBNAILSMANAGEMENT_H
#define THUMBNAILSMANAGEMENT_H

#include "../logger.h"
#include <QObject>
#include <QFileInfo>
#include <QDir>
#include <QtSql>
#include <iostream>

class ThumbnailManagement : public QObject {

	Q_OBJECT

public:
	ThumbnailManagement(QObject *parent = 0);

	Q_INVOKABLE qint64 getDatabaseFilesize();

	Q_INVOKABLE int getNumberDatabaseEntries();

	Q_INVOKABLE void cleanDatabase();
	Q_INVOKABLE void eraseDatabase();

private:
	QSqlDatabase db;

};


#endif // THUMBNAILSMANAGEMENT_H
