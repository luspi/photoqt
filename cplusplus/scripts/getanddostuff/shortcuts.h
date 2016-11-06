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
#include "../../logger.h"
#include <QtDebug>
#include <QTouchDevice>

class GetAndDoStuffShortcuts : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuffShortcuts(bool usedAtStartup = false, QObject *parent = 0);
	~GetAndDoStuffShortcuts();

	QVariantMap getKeyShortcuts();
	QVariantMap getMouseShortcuts();
	QVariantMap getTouchShortcuts();
	QVariantMap getAllShortcuts();
	void saveShortcuts(QVariantMap l);
	QVariantMap getDefaultKeyShortcuts();
	QVariantMap getDefaultMouseShortcuts();
	QVariantMap getDefaultTouchShortcuts();
	QString getKeyShortcutFile();
	QString filterOutShortcutCommand(QString combo, QString file);
	bool isTouchScreenAvailable();

private:
	QFileSystemWatcher *watcher;

private slots:
	void fileChanged(QString filename);
	void setFilesToWatcher();

signals:
	void keyShortcutFileChanged(int);
	void mouseShortcutFileChanged(int);

};

#endif // GETANDDOSTUFFSHORTCUTS_H
