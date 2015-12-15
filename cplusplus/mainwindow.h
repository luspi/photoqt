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

#include "logger.h"
#include "scripts/getanddostuff.h"
#include "scripts/getmetadata.h"
#include "scripts/thumbnailsmanagement.h"
#include "handlefiles/loaddir.h"
#include "imageprovider/imageproviderthumbnail.h"
#include "imageprovider/imageproviderfull.h"
#include "imageprovider/imageprovidericon.h"
#include "settings/settings.h"
#include "settings/fileformats.h"
#include "settings/settingssession.h"
#include "variables.h"
#include "shortcuts/shortcuts.h"
#include "tooltip/tooltip.h"

class MainWindow : public QQuickView {

	Q_OBJECT

public:
	explicit MainWindow(bool verbose, QWindow *parent = 0);
	~MainWindow();

	// These are used by main.cpp when thumbnails are disabled at startup, or to set default fileformats
	void disableThumbnails() { settingsPermanent->thumbnailDisable = true; }
	void setDefaultFileFormats() { fileformats->getFormats(""); }

	// Set only by main.cpp at start-up, contains filename passed via command line
	QString startup_filename;

	void showStartup(QString type);

public slots:
	void openNewFile();
	void openNewFile(QVariant usethis, QVariant filter = QVariant());

	// This is used by main.cpp (see there (at the end of file) for details)
	void resetZoom() { QMetaObject::invokeMethod(object,"resetZoom"); }

	// This is used by main.cpp to set the window geometry (we do NOT call 'open file' yet, this is handled in main.cpp (with timers))
	void updateWindowGeometry();

	// Re-implement show/hide functions to update properties
	void show() { variables->hiddenToTrayIcon = false; object->setProperty("windowshown",true); QQuickView::show(); }
	void showMaximized() { variables->hiddenToTrayIcon = false; object->setProperty("windowshown",true); QQuickView::showMaximized(); }
	void showFullScreen() { variables->hiddenToTrayIcon = false; object->setProperty("windowshown",true); QQuickView::showFullScreen(); }
	void hide() { variables->hiddenToTrayIcon = true; object->setProperty("windowshown",false); QQuickView::hide(); }

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

	QFileDialog *filedialog;

	int overrideCursorHowOftenSet;

private slots:

	void handleOpenFileEvent(QString usethis = "");

	void handleThumbnails(QVariant centerPos);
	void loadMoreThumbnails();
	void didntLoadThisThumbnail(QVariant pos);

	void detectedKeyCombo(QString combo);

	void showTrayIcon();
	void hideTrayIcon();

    void hideToSystemTray();
    void quitPhotoQt();
    void trayAction(QSystemTrayIcon::ActivationReason reason);

	void remoteAction(QString cmd);

	void updateWindowXandY();

	void resetWindowGeometry();

	void qmlVerboseMessage(QVariant loc, QVariant msg);

	void setOverrideCursor() { ++overrideCursorHowOftenSet; qApp->setOverrideCursor(Qt::WaitCursor); }
	void restoreOverrideCursor() { for(int i = 0; i < overrideCursorHowOftenSet; ++i) qApp->restoreOverrideCursor(); overrideCursorHowOftenSet = 0; }

protected:
	bool event(QEvent *e);
	void wheelEvent(QWheelEvent *e);
	void mousePressEvent(QMouseEvent *e);
	void mouseReleaseEvent(QMouseEvent *e);
	void mouseMoveEvent(QMouseEvent *e);
	void resizeEvent(QResizeEvent *e);

signals:
	void doSetupModel();


};

#endif // MAINWINDOW_H
