#include "mousehandler.h"

MouseHandler::MouseHandler(QObject *parent) : QObject(parent) {
	gesturePath.clear();
	gesturePathPts.clear();
	threshold = 50;
	detecting = false;
	angleDelta = 0;
	button = "";
	numButtonClicked = 0;
}

MouseHandler::~MouseHandler() { }

bool MouseHandler::handle(QEvent *e) {

	QEvent::Type type = e->type();

	// Filter out right events
	if(type != QEvent::Wheel
			&& type != QEvent::MouseButtonPress
			&& type != QEvent::MouseButtonDblClick
			&& type != QEvent::MouseButtonRelease
			&& type != QEvent::MouseMove)
		return false;

	if(((type == QEvent::MouseButtonRelease) && numButtonClicked > 1)) {
		--numButtonClicked;
		return false;
	}

	if((type == QEvent::MouseMove) && (!detecting || numButtonClicked == 0))
		return false;

	if(type == QEvent::MouseButtonPress)
		++numButtonClicked;
	else if(type == QEvent::MouseButtonRelease)
		--numButtonClicked;

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
	else if(type == QEvent::MouseButtonRelease)
		gestureEnded(e);
	else
		gestureUpdated((QMouseEvent*)e);

	return true;
}

void MouseHandler::gestureStarted(QMouseEvent *e) {

	detecting = true;

	// Reset variables
	gesturePath.clear();
	gesturePathPts.clear();

	// We only consider ONE finger and track its movement across
	gesturePathPts.append(e->pos());

	startTime = QDateTime::currentMSecsSinceEpoch();

	button = MouseButton::extract(e);

}

void MouseHandler::gestureUpdated(QMouseEvent *e) {

	// Calculate the distance moved since last event
	int dx = e->pos().x()-gesturePathPts.last().x();
	int dy = e->pos().y()-gesturePathPts.last().y();
	double distance = std::sqrt(std::pow(dx,2)+std::pow(dy,2));

	// Get the angle of the current resulting mouse direction
	int angle = ((std::atan2(dy,dx)/M_PI)*180);
	angle = (angle+360)%360;

	bool movedAtLeastThresholdDistance = false;
	bool signalUpdateToMouseGesture = false;

	// If mouse was moved far enough
	if(distance > threshold) {

		// moved right
		if(angle <= 45 || angle > 315) {
			if(gesturePath.length() == 0 || gesturePath.last() != "E") {
				gesturePath.append("E");
				signalUpdateToMouseGesture = true;
			}
		// moved up
		} else if(angle > 45 && angle <= 135) {
			if(gesturePath.length() == 0 || gesturePath.last() != "S") {
				gesturePath.append("S");
				signalUpdateToMouseGesture = true;
			}
		// moved left
		} else if(angle > 135 && angle <= 225) {
			if(gesturePath.length() == 0 || gesturePath.last() != "W") {
				gesturePath.append("W");
				signalUpdateToMouseGesture = true;
			}
		// moved down
		} else if(angle > 225 && angle <= 315) {
			if(gesturePath.length() == 0 || gesturePath.last() != "N") {
				gesturePath.append("N");
				signalUpdateToMouseGesture = true;
			}
		}

		movedAtLeastThresholdDistance = true;

		// Store new touch point
		gesturePathPts.append(e->pos());

	}

	if(signalUpdateToMouseGesture || (movedAtLeastThresholdDistance && gesturePath.length() == 1))
		emit updatedMouseEvent(button, gesturePath, KeyModifier::extract(e));

}

void MouseHandler::gestureEnded(QEvent *e) {

	qint64 endTime = QDateTime::currentMSecsSinceEpoch();

	emit finishedMouseEvent(gesturePathPts.first(), gesturePathPts.last(),
							endTime-startTime, button, gesturePath,
							angleDelta, KeyModifier::extract(e));

	detecting = false;
	angleDelta = 0;

}

void MouseHandler::gestureCancelled() {
	gesturePath.clear();
	gesturePathPts.clear();
	detecting = false;
	angleDelta = 0;
	button = "";
	numButtonClicked = 0;
}
