#include "touchhandler.h"

TouchHandler::TouchHandler(QObject *parent) : QObject(parent) {
	touchPath.clear();
	threshold = 50;
	amDetecting = false;
	numFingers = 0;
}

TouchHandler::~TouchHandler() { }

bool TouchHandler::handle(QEvent *e) {

	if(e->type() == QEvent::TouchBegin)
		return touchStarted((QTouchEvent*)e);
	else if((e->type() == QEvent::TouchUpdate))
		return touchUpdated((QTouchEvent*)e);
	else if(e->type() == QEvent::TouchEnd)
		return touchEnded((QTouchEvent*)e);

	return false;

}

bool TouchHandler::touchStarted(QTouchEvent *e) {

	// Reset variables
	touchPath.clear();
	touchPathPts.clear();

	amDetecting = true;
	numFingers = e->touchPoints().count();

	for(unsigned int f = 0; f < numFingers; ++f) {
		touchPathPts.append(QList<QTouchEvent::TouchPoint>());
		touchPathPts[f].append(e->touchPoints().at(f));
		touchPath.append(QStringList());
	}

	startTime = QDateTime::currentMSecsSinceEpoch();

	return true;

}

// Update to touch
bool TouchHandler::touchUpdated(QTouchEvent *e) {

	if(e->touchPoints().length() == 0)
		return false;

	if(numFingers < e->touchPoints().count())
		return touchStarted(e);

	for(unsigned int f = 0; f < e->touchPoints().count(); ++f) {

		// Get current touch points
		QTouchEvent::TouchPoint cur = e->touchPoints().at(f);

		int dx = cur.pos().x()-touchPathPts.at(f).last().pos().x();
		int dy = cur.pos().y()-touchPathPts.at(f).last().pos().y();
		double distance = std::sqrt(std::pow(dx,2)+std::pow(dy,2));

		int angle = ((std::atan2(dy,dx)/M_PI)*180);
		angle = (angle+360)%360;

		if(distance > threshold) {

			bool upd = false;

			// moved right
			if(angle <= 45 || angle > 315) {
				upd = true;
				if(touchPath.at(f).length() == 0 || touchPath.at(f).last() != "E")
					touchPath[f].append("E");
			// moved up
			} else if(angle > 45 && angle <= 135) {
				upd = true;
				if(touchPath.at(f).length() == 0 || touchPath.at(f).last() != "S")
					touchPath[f].append("S");
			// moved left
			} else if(angle > 135 && angle <= 225) {
				upd = true;
				if(touchPath.at(f).length() == 0 || touchPath.at(f).last() != "W")
					touchPath[f].append("W");
			// moved down
			} else if(angle > 225 && angle <= 315) {
				upd = true;
				if(touchPath.at(f).length() == 0 || touchPath.at(f).last() != "N")
					touchPath[f].append("N");
			}

			// Store new touch point
			if(upd)
				touchPathPts[f].append(cur);

		}

	}

	return true;

}

// A gesture has been finished
bool TouchHandler::touchEnded(QTouchEvent *) {

//		return true;
//		emit setImageInteractiveMode(true);
//		qint64 endTime = QDateTime::currentMSecsSinceEpoch();
//		emit receivedTouchEvent(touchPathPts.first().pos(), touchPathPts.last().pos(), endTime-startTime, touchPath);

	amDetecting = false;

	qDebug() << "touch ended:" << numFingers << "-" << touchPath;

	return true;
}
