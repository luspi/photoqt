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

	// A touch has been started -> reset variables
	bool touchStarted(QTouchEvent *e);

	// Update to touch
	bool touchUpdated(QTouchEvent *e);

	// A gesture has been finished
	bool touchEnded(QTouchEvent *);

signals:
	void receivedTouchEvent(QPointF start, QPointF end, qint64 duration, QStringList gesture);
	void setImageInteractiveMode(bool enabled);

};

#endif // TOUCHHANDLER_H
