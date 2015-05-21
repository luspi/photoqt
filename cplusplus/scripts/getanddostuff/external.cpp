#include "external.h"

GetAndDoStuffExternal::GetAndDoStuffExternal(QObject *parent) : QObject(parent) { }
GetAndDoStuffExternal::~GetAndDoStuffExternal() { }

void GetAndDoStuffExternal::openLink(QString url) {
	QDesktopServices::openUrl(url);
}

void GetAndDoStuffExternal::executeApp(QString exec, QString fname) {

	QProcess *p = new QProcess;
	exec = exec.replace("%f",'"' + fname + '"');
	exec = exec.replace("%u",'"' + QFileInfo(fname).fileName() + '"');
	exec = exec.replace("%d",'"' + QFileInfo(fname).absoluteDir().absolutePath() + '"');

	p->start(exec);
	if(p->error() == 5)
		p->waitForStarted(2000);

}

void GetAndDoStuffExternal::openInDefaultFileManager(QString file) {
	QDesktopServices::openUrl(QUrl("file:///" + QFileInfo(file).absolutePath()));
}
