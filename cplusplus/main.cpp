#include <QApplication>
#include "mainwindow.h"

int main(int argc, char *argv[]) {

	QApplication app(argc, argv);

#ifdef GM
	Magick::InitializeMagick(*argv);
#endif

	MainWindow w;
	w.showFullScreen();

	return app.exec();

}
