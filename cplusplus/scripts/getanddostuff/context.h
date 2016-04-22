#ifndef GETANDDOSTUFFCONTEXT_H
#define GETANDDOSTUFFCONTEXT_H

#include "../../logger.h"
#include <iostream>
#include <QObject>
#include <QStringList>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QVariant>
#include <QDir>
#include <QProcess>
#include <QDateTime>

class GetAndDoStuffContext : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuffContext(QObject *parent = 0);
	~GetAndDoStuffContext();

	QStringList setDefaultContextMenuEntries();
	QStringList getContextMenu();
	qint64 getContextMenuFileModifiedTime();
	void saveContextMenu(QVariantList m);
	bool checkIfBinaryExists(QString exec);

};


#endif // GETANDDOSTUFFCONTEXT_H
