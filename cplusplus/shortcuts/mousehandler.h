#ifndef MOUSEHANDLER_H
#define MOUSEHANDLER_H

#include <QtDebug>
#include <QMouseEvent>
#include <QTime>
#include "keymodifier.h"

class MouseHandler : public QObject {

	Q_OBJECT

public:
	explicit MouseHandler(QObject *parent = 0) : QObject(parent) {
		gesturePath.clear();
		gesturePathPts.clear();
		threshold = 50;
		detecting = false;
		angleDelta = 0;
		button = "";
		numButtonClicked = 0;
		timeOfLastGesture = 0;
		touchgesture = false;
	}
	~MouseHandler() {}

	// Handle touch event -> call respective handler function
	bool handle(QEvent *e) {

		QEvent::Type type = e->type();

		// Filter out right events
		if(type != QEvent::Wheel
				&& type != QEvent::MouseButtonPress
				&& type != QEvent::MouseButtonDblClick
				&& type != QEvent::MouseButtonRelease
				&& type != QEvent::MouseMove
				&& type != QEvent::TouchEnd
				&& type != QEvent::TouchUpdate
				&& type != QEvent::TouchBegin)
			return false;

		if(type == QEvent::TouchEnd) {
			type = QEvent::MouseButtonRelease;
			touchgesture = true;
		} else if(type == QEvent::TouchUpdate) {
			touchgesture = true;
			return true;
		} else if(type == QEvent::TouchBegin) {
			touchgesture = true;
			return true;
		} else if(!detecting)
			touchgesture = false;

		if(type == QEvent::MouseButtonPress)
			++numButtonClicked;
		else if(type == QEvent::MouseButtonRelease)
			--numButtonClicked;

		if((type == QEvent::MouseMove && !detecting)
				|| (type == QEvent::MouseButtonRelease && numButtonClicked > 0))
			return false;

		if(type == QEvent::Wheel) {
			QWheelEvent *ev = (QWheelEvent*)e;
			gesturePath.clear();
			gesturePathPts.clear();
			gesturePathPts.append(ev->pos());
			startTime = QDateTime::currentMSecsSinceEpoch();
			angleDelta = ev->angleDelta().y();
			if(angleDelta > 0)
				button = "Wheel Up";
			else
				button = "Wheel Down";
			gestureEnded(e);
			return true;
		}

		if(!detecting)
			gestureStarted((QMouseEvent*)e);
		else if(type == QEvent::MouseButtonRelease || type == QEvent::TouchEnd)
			gestureEnded(e);
		else
			gestureUpdated((QMouseEvent*)e);

		return true;
	}

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

	bool touchgesture;

	qint64 timeOfLastGesture;

	void gestureStarted(QMouseEvent *e) {

		qint64 current = QDateTime::currentMSecsSinceEpoch();
		if(abs(current-timeOfLastGesture) < 200)
			return;

		timeOfLastGesture = current;

		detecting = true;

		// Reset variables
		gesturePath.clear();
		gesturePathPts.clear();

		// We only consider ONE finger and track its movement across
		gesturePathPts.append(e->pos());

		startTime = QDateTime::currentMSecsSinceEpoch();

		switch(e->button()) {

		case Qt::RightButton:
			button = "Right Button";
			break;
		case Qt::LeftButton:
			button = "Left Button";
			break;
		case Qt::MiddleButton:
			button = "Middle Button";
			break;
		case Qt::BackButton:
			button = "Back Button";
			break;
		case Qt::ForwardButton:
			button = "Forward Button";
			break;
		case Qt::TaskButton:
			button = "Task Button";
			break;
		case Qt::ExtraButton4:
			button = "Button #4";
			break;
		case Qt::ExtraButton5:
			button = "Button #5";
			break;
		case Qt::ExtraButton6:
			button = "Button #6";
			break;
		case Qt::ExtraButton7:
			button = "Button #7";
			break;
		case Qt::ExtraButton8:
			button = "Button #8";
			break;
		case Qt::ExtraButton9:
			button = "Button #9";
			break;
		case Qt::ExtraButton10:
			button = "Button #10";
			break;
		case Qt::ExtraButton11:
			button = "Button #11";
			break;
		case Qt::ExtraButton12:
			button = "Button #12";
			break;
		case Qt::ExtraButton13:
			button = "Button #13";
			break;
		case Qt::ExtraButton14:
			button = "Button #14";
			break;
		case Qt::ExtraButton15:
			button = "Button #15";
			break;
		case Qt::ExtraButton16:
			button = "Button #16";
			break;
		case Qt::ExtraButton17:
			button = "Button #17";
			break;
		case Qt::ExtraButton18:
			button = "Button #18";
			break;
		case Qt::ExtraButton19:
			button = "Button #19";
			break;
		case Qt::ExtraButton20:
			button = "Button #20";
			break;
		case Qt::ExtraButton21:
			button = "Button #21";
			break;
		case Qt::ExtraButton22:
			button = "Button #22";
			break;
		case Qt::ExtraButton23:
			button = "Button #23";
			break;
		case Qt::ExtraButton24:
			button = "Button #24";
			break;

		default:
			button = "Unknown Button...?";
		}

	}

	void gestureUpdated(QMouseEvent *e) {

		// Get current event point
		int dx = e->pos().x()-gesturePathPts.last().x();
		int dy = e->pos().y()-gesturePathPts.last().y();

		// Each one has to be counted to fingers detected
		// -> only if all fingers are still 'threshold' away
		// from 'master' finger
		bool detectedRight = false;
		bool detectedLeft = false;
		bool detectedUp = false;
		bool detectedDown = false;

		if(dx > threshold)
			detectedRight = true;
		else if(dx < -threshold)
			detectedLeft = true;

		if(dy > threshold)
			detectedDown = true;
		else if(dy < -threshold)
			detectedUp = true;

		bool upd = false;

		if(detectedRight) {
			upd = true;
			if(gesturePath.length() == 0 || gesturePath.last() != "E")
				gesturePath.append("E");
		}
		if(detectedLeft) {
			upd = true;
			if(gesturePath.length() == 0 || gesturePath.last() != "W")
				gesturePath.append("W");
		}
		if(detectedDown) {
			upd = true;
			if(gesturePath.length() == 0 || gesturePath.last() != "S")
				gesturePath.append("S");
		}
		if(detectedUp) {
			upd = true;
			if(gesturePath.length() == 0 || gesturePath.last() != "N")
				gesturePath.append("N");
		}

		// Store new touch point
		if(upd)
			gesturePathPts.append(e->pos());

		updatedMouseEvent(button, gesturePath, KeyModifier::extract((QKeyEvent*)e), touchgesture);

	}

	void gestureEnded(QEvent *e) {

		qint64 endTime = QDateTime::currentMSecsSinceEpoch();

		emit finishedMouseEvent(gesturePathPts.first(), gesturePathPts.last(),
								endTime-startTime, button, gesturePath,
								angleDelta, KeyModifier::extract((QKeyEvent*)e));

		detecting = false;
		angleDelta = 0;

	}

signals:
	void updatedMouseEvent(QString button, QStringList gesture, QString modifiers, bool touch);
	void finishedMouseEvent(QPoint start, QPoint end, qint64 duration, QString button, QStringList gesture, int wheelAngleDelta, QString modifiers);

};

#endif
