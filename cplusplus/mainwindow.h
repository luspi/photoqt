#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QObject>
#include <QQuickView>
#include <QQuickItem>
#include <QQmlProperty>
#include <QFileDialog>
#include <QQmlContext>
#include <QShortcut>
#include <QtDebug>

#include "scripts/getstuff.h"
#include "scripts/getmetadata.h"
#include "handlefiles/loaddir.h"
#include "imageprovider/imageproviderthumbnail.h"
#include "imageprovider/imageproviderfull.h"
#include "settings/settings.h"
#include "settings/settingssession.h"
#include "variables.h"

class MainWindow : public QQuickView {

	Q_OBJECT

public:
	explicit MainWindow(QWindow *parent = 0);
	~MainWindow();

public slots:
	void openNewFile(QString usethis = "");

private:
	QQuickItem *item;
	QObject *object;
	LoadDir *loadDir;

	SettingsSession *settingsPerSession;
	Settings *settingsPermanent;
	Variables *variables;


	int currentCenter;
	QList<int> loadThumbnailsInThisOrder;
	QList<int> smartLoadThumbnailsInThisOrder;

private slots:

	void resized();

	void handleThumbnails(QVariant centerPos);
	void loadMoreThumbnails();
	void didntLoadThisThumbnail(QVariant pos);

signals:
	void doSetupModel();


};

#endif // MAINWINDOW_H
