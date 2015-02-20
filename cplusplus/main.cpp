#include <QApplication>
#include "mainwindow.h"
#include <QQmlDebuggingEnabler>
#include <QSignalMapper>

int main(int argc, char *argv[]) {

	QQmlDebuggingEnabler enabler;

	QApplication app(argc, argv);

#ifdef GM
	Magick::InitializeMagick(*argv);
#endif

	MainWindow w;
	w.showFullScreen();

	if(argc > 1) {
		QTimer *timer = new QTimer;
		timer->setSingleShot(true);
		timer->setInterval(200);
		QSignalMapper *mapper = new QSignalMapper;
		mapper->setMapping(timer, argv[1]);
		QObject::connect(timer, SIGNAL(timeout()), mapper, SLOT(map()));
		QObject::connect(mapper, SIGNAL(mapped(QString)), &w, SLOT(openNewFile(QString)));
		timer->start();
	} else
		w.openNewFile();

	return app.exec();

}
