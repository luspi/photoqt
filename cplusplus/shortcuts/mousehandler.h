#ifndef MOUSEHANDLER_H
#define MOUSEHANDLER_H

#include <QtDebug>
#include <QMouseEvent>
#include <QTime>
#include "keymodifier.h"

class MouseHandler : public QObject {

	Q_OBJECT

public:
	explicit MouseHandler(QObject *parent = 0);
	~MouseHandler();

	// Handle touch event -> call respective handler function
	bool handle(QEvent *e);

	bool isDetecting() { return detecting; }
	void abort() { gestureCancelled(); }

private:

	// Some variables handling the movement
	QStringList gesturePath;
	QList<QPoint> gesturePathPts;
	int threshold;
	qint64 startTime;

	QString button;
	int angleDelta;

	bool detecting;

	int numButtonClicked;

	void gestureStarted(QMouseEvent *e);
	void gestureUpdated(QMouseEvent *e);
	void gestureEnded(QEvent *e);
	void gestureCancelled();

signals:
	void updatedMouseEvent(QString button, QStringList gesture, QString modifiers);
	void finishedMouseEvent(QPoint start, QPoint end, qint64 duration, QString button, QStringList gesture, int wheelAngleDelta, QString modifiers);

};

#endif
