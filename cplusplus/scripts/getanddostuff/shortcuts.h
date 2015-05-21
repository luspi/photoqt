#ifndef GETANDDOSTUFFSHORTCUTS_H
#define GETANDDOSTUFF_H

#include <iostream>
#include <QObject>
#include <QVariantMap>
#include <QFile>
#include <QDir>
#include <QTextStream>

class GetAndDoStuffShortcuts : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuffShortcuts(QObject *parent = 0);
	~GetAndDoStuffShortcuts();

	QVariantMap getShortcuts();
	void saveShortcuts(QVariantList l);
	QVariantMap getDefaultShortcuts();
	QString getShortcutFile();
	QString filterOutShortcutCommand(QString combo, QString file);

};

#endif // GETANDDOSTUFF_H
