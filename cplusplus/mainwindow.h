#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QObject>
#include <QQuickView>
#include <QQuickItem>
#include <QQmlProperty>
#include <QFileDialog>
#include <QQmlContext>
#include <QShortcut>
#include <QSystemTrayIcon>
#include <QtDebug>

#include "scripts/getanddostuff.h"
#include "scripts/getmetadata.h"
#include "scripts/thumbnailsmanagement.h"
#include "handlefiles/loaddir.h"
#include "imageprovider/imageproviderthumbnail.h"
#include "imageprovider/imageproviderfull.h"
#include "settings/settings.h"
#include "settings/fileformats.h"
#include "settings/settingssession.h"
#include "variables.h"
#include "shortcuts/shortcuts.h"

class MainWindow : public QQuickView {

	Q_OBJECT

public:
	explicit MainWindow(QWindow *parent = 0);
	~MainWindow();

	// These are used by main.cpp when thumbnails are disabled at startup, or to set default fileformats
	void disableThumbnails() { settingsPermanent->thumbnailDisable = true; }
	void setDefaultFileFormats() { fileformats->getFormats(""); }

public slots:
    void openNewFile(QString usethis = "");
    void openNewFile(QVariant usethis);

private:
	QQuickItem *item;
	QObject *object;
	LoadDir *loadDir;

	SettingsSession *settingsPerSession;
	Settings *settingsPermanent;
	FileFormats *fileformats;
	Variables *variables;

	Shortcuts *shortcuts;


	int currentCenter;
	QList<int> loadThumbnailsInThisOrder;
	QList<int> smartLoadThumbnailsInThisOrder;

	QString mouseCombo;
	QPoint mouseOrigPoint;
	int mouseDx;
	int mouseDy;

	QSystemTrayIcon *trayIcon;

private slots:

	void resized();

	void handleThumbnails(QVariant centerPos);
	void loadMoreThumbnails();
	void didntLoadThisThumbnail(QVariant pos);

	void detectedKeyCombo(QString combo);

    void hideToSystemTray();
    void quitPhotoQt();
    void trayAction(QSystemTrayIcon::ActivationReason reason);

protected:
	bool event(QEvent *e);
	void keyPressEvent(QKeyEvent *e);
	void keyReleaseEvent(QKeyEvent *e);
	void wheelEvent(QWheelEvent *e);
	void mousePressEvent(QMouseEvent *e);
	void mouseReleaseEvent(QMouseEvent *e);
	void mouseMoveEvent(QMouseEvent *e);

signals:
	void doSetupModel();


};

#endif // MAINWINDOW_H
