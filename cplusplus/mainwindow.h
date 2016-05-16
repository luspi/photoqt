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
#include "touchhandler.h"
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
#include "settings/colour.h"
#include "variables.h"
#include "shortcuts/shortcuts.h"
#include "shortcuts/shortcutsnotifier.h"
#include "tooltip/tooltip.h"

class MainWindow : public QQuickView {

	Q_OBJECT

public:
	explicit MainWindow(bool verbose, QWindow *parent = 0);
	~MainWindow();

	void showStartup(QString type);

public slots:
	void handleOpenFileEvent(QString filename, QString filter = "");

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

	int overrideCursorHowOftenSet;


	TouchHandler *touch;


private slots:

	void handleThumbnails(int centerPos);
	void loadMoreThumbnails();
	void didntLoadThisThumbnail(int pos);

	void detectedKeyCombo(QString combo);

	void showTrayIcon();
	void hideTrayIcon();

	void hideToSystemTray();
	void quitPhotoQt();
	void trayAction(QSystemTrayIcon::ActivationReason reason);

	void remoteAction(QString cmd);

	void updateWindowXandY();

	void resetWindowGeometry();

	void qmlVerboseMessage(QString loc, QString msg);

	void setOverrideCursor() { ++overrideCursorHowOftenSet; qApp->setOverrideCursor(Qt::WaitCursor); }
	void restoreOverrideCursor() { for(int i = 0; i < overrideCursorHowOftenSet; ++i) qApp->restoreOverrideCursor(); overrideCursorHowOftenSet = 0; }

	void passOnTouchEvent(QPointF startPoint, QPointF endPoint, qint64 duration, int numFingers, QStringList gesture) {
		QMetaObject::invokeMethod(object, "touchEvent", Q_ARG(QVariant, startPoint), Q_ARG(QVariant, endPoint), Q_ARG(QVariant, duration), Q_ARG(QVariant, numFingers), Q_ARG(QVariant, gesture));
	}
	void setImageInteractiveMode(bool enabled) { QMetaObject::invokeMethod(object, "setImageInteractiveMode", Q_ARG(QVariant, enabled)); }

	void loadStatus(QQuickView::Status status) {
		if(status == QQuickView::Error)
			for(int i = 0; i < this->errors().length(); ++i)
				LOG << CURDATE << "QQuickView QML LOADING ERROR: " << this->errors().at(i).toString().toStdString() << NL;
	}

	void stopThumbnails() {
		variables->keepLoadingThumbnails = false;
	}
	void reloadThumbnails() {
		variables->keepLoadingThumbnails = true;
		loadMoreThumbnails();
	}

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
