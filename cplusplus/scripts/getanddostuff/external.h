#ifndef GETANDDOSTUFFEXTERNAL_H
#define GETANDDOSTUFFEXTERNAL_H

#include <QObject>
#include <QDesktopServices>
#include <QProcess>
#include <QFileInfo>
#include <QDir>
#include <QUrl>

class GetAndDoStuffExternal : public QObject {

	Q_OBJECT

public:
	explicit GetAndDoStuffExternal(QObject *parent = 0);
	~GetAndDoStuffExternal();

	void executeApp(QString exec, QString fname);
	void openLink(QString url);
	void openInDefaultFileManager(QString file);

};

#endif // GETANDDOSTUFFEXTERNAL_H
