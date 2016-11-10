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
#include "shortcuts/touchhandler.h"
#include "shortcuts/mousehandler.h"
#include "shortcuts/keyhandler.h"
#include "scripts/getanddostuff.h"
#include "scripts/getmetadata.h"
#include "scripts/thumbnailsmanagement.h"
#include "scripts/imagewatch.h"
#include "handlefiles/loaddir.h"
#include "imageprovider/imageproviderthumbnail.h"
#include "imageprovider/imageproviderfull.h"
#include "imageprovider/imageprovidericon.h"
#include "settings/settings.h"
#include "settings/fileformats.h"
#include "settings/settingssession.h"
#include "settings/colour.h"
#include "variables.h"
#include "shortcuts/shortcutsnotifier.h"
#include "tooltip/tooltip.h"

class MainWindow : public QQuickView {

	Q_OBJECT

public:
	explicit MainWindow(bool verbose, QWindow *parent = 0);
	~MainWindow();

	void showStartup(QString type, QString filename);

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

	int currentCenter;
	QVector<int> loadThumbnailsInThisOrder;
	QVector<int> smartLoadThumbnailsInThisOrder;

	QString mouseCombo;
	QPoint mouseOrigPoint;
	int mouseDx;
	int mouseDy;

	QSystemTrayIcon *trayIcon;

	int overrideCursorHowOftenSet;


	TouchHandler *touchHandler;
	MouseHandler *mouseHandler;
	KeyHandler *keyHandler;

	bool touchEventInProgress;

private slots:

	void handleThumbnails(int centerPos);
	void loadMoreThumbnails();
	void didntLoadThisThumbnail(int pos);

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

	void passOnKeyEvent(QString combo) {
		QMetaObject::invokeMethod(object, "updateKeyCombo",
					  Q_ARG(QVariant, combo));
	}

	void passOnUpdatedTouchEvent(QPointF startPoint, QPointF endPoint,
								 QString type, unsigned int numFingers,
								 qint64 duration, QStringList path) {
		mouseHandler->abort();
		QMetaObject::invokeMethod(object, "updatedTouchEvent", Q_ARG(QVariant, startPoint),
								  Q_ARG(QVariant, endPoint), Q_ARG(QVariant, type),
								  Q_ARG(QVariant, numFingers), Q_ARG(QVariant, duration),
								  Q_ARG(QVariant, path));
	}

	void passOnFinishedTouchEvent(QPointF startPoint, QPointF endPoint,
								  QString type, unsigned int numFingers,
								  qint64 duration, QStringList path) {
		mouseHandler->abort();
		QMetaObject::invokeMethod(object, "finishedTouchEvent", Q_ARG(QVariant, startPoint),
								  Q_ARG(QVariant, endPoint), Q_ARG(QVariant, type),
								  Q_ARG(QVariant, numFingers), Q_ARG(QVariant, duration),
								  Q_ARG(QVariant, path));
	}
	void setImageInteractiveMode(bool enabled) { QMetaObject::invokeMethod(object, "setImageInteractiveMode", Q_ARG(QVariant, enabled)); }


	void passOnFinishedMouseEvent(QPoint start, QPoint end, qint64 duration,
						  QString button, QStringList gesture, int wheelAngleDelta, QString modifiers) {
		if(!touchEventInProgress)
			QMetaObject::invokeMethod(object, "finishedMouseEvent", Q_ARG(QVariant, start),
									  Q_ARG(QVariant, end), Q_ARG(QVariant, duration),
									  Q_ARG(QVariant, button), Q_ARG(QVariant, gesture),
									  Q_ARG(QVariant, wheelAngleDelta), Q_ARG(QVariant, modifiers));
	}
	void passOnUpdatedMouseEvent(QString button, QStringList gesture, QString modifiers) {
		QMetaObject::invokeMethod(object, "updatedMouseEvent",Q_ARG(QVariant, button), Q_ARG(QVariant, gesture),
								  Q_ARG(QVariant, modifiers));
	}

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

signals:
	void doSetupModel();

};

#endif // MAINWINDOW_H
