#ifndef GETANDDOSTUFFSHORTCUTS_H
#define GETANDDOSTUFFSHORTCUTS_H

#include <iostream>
#include <thread>
#include <QObject>
#include <QVariantMap>
#include <QFile>
#include <QDir>
#include <QTextStream>
#include <QTime>
#include <QFileSystemWatcher>
#include <QTimer>

class GetAndDoStuffShortcuts : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuffShortcuts(bool usedAtStartup = false, QObject *parent = 0);
	~GetAndDoStuffShortcuts();

	QVariantMap getShortcuts();
	void saveShortcuts(QVariantMap l);
	QVariantMap getDefaultShortcuts();
	QString getShortcutFile();
	QString filterOutShortcutCommand(QString combo, QString file);

private:
	QFileSystemWatcher *watcher;

private slots:
	void fileChanged();
	void setFilesToWatcher();

signals:
	void shortcutFileChanged(int);

};

#endif // GETANDDOSTUFFSHORTCUTS_H
