#include <QApplication>
#include "mainwindow.h"
#include <QQmlDebuggingEnabler>

int main(int argc, char *argv[]) {

	QQmlDebuggingEnabler enabler;

	QApplication app(argc, argv);

#ifdef GM
	Magick::InitializeMagick(*argv);
#endif

	MainWindow w;
	w.showFullScreen();

	return app.exec();

}
