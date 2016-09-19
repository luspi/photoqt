#ifndef TOUCHHANDLER_H
#define TOUCHHANDLER_H

#include <QtDebug>
#include <QTouchEvent>
#include <QTime>
#include <cmath>
#include <QTimer>

class TouchHandler : public QObject {

	Q_OBJECT

public:
	explicit TouchHandler(QObject *parent = 0);
	~TouchHandler();

	// Handle touch event -> call respective handler function
	bool handle(QEvent *e);
	bool isTouchGestureDetecting() { return amDetecting; }

private:

	// Some variables handling the movement
	QList<QStringList> touchPath;
	QList<QList<QTouchEvent::TouchPoint> > touchPathPts;
	int threshold;
	qint64 startTime;
	bool amDetecting;
	int numFingers;

	int gestureTimeoutMs;

	QPointF gestureCenterPointStart;
	QPointF gestureCenterPointEnd;

	// A touch has been started -> reset variables
	void touchStarted(QTouchEvent *e);

	// Update to touch
	void touchUpdated(QTouchEvent *e);

	// A gesture has been finished
	void touchEnded(QTouchEvent *);

	// A gesture has been cancelled
	void touchCancelled();

	QVariantList analyseGestureUpToNow();

signals:
	void updatedTouchEvent(QPointF start, QPointF end, QString type, unsigned int numFingers, qint64 duration, QStringList path);
	void receivedTouchEvent(QPointF start, QPointF end, QString type, unsigned int numFingers, qint64 duration, QStringList path);
	void setImageInteractiveMode(bool enabled);

};

#endif // TOUCHHANDLER_H
