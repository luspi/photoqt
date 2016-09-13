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

	if(type == QEvent::MouseButtonPress)
		++numButtonClicked;
	else if(type == QEvent::MouseButtonRelease)
		--numButtonClicked;

	if(((type == QEvent::MouseMove) && !detecting)
			|| ((type == QEvent::MouseButtonRelease) && numButtonClicked > 0))
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

void MouseHandler::gestureUpdated(QMouseEvent *e) {

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

	emit updatedMouseEvent(button, gesturePath, KeyModifier::extract((QKeyEvent*)e));

}

void MouseHandler::gestureEnded(QEvent *e) {

	qint64 endTime = QDateTime::currentMSecsSinceEpoch();

	emit finishedMouseEvent(gesturePathPts.first(), gesturePathPts.last(),
							endTime-startTime, button, gesturePath,
							angleDelta, KeyModifier::extract((QKeyEvent*)e));

	detecting = false;
	angleDelta = 0;

}

void MouseHandler::gestureCancelled() {
	detecting = false;
	gesturePathPts.clear();
	gesturePath.clear();
}
