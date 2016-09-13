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

	qDebug() << "touch started";

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

	qDebug() << "touch updated";

	for(unsigned int f = 0; f < e->touchPoints().count(); ++f) {

		// Get current touch points
		QTouchEvent::TouchPoint cur = e->touchPoints().at(f);

		int dx = cur.pos().x()-touchPathPts.at(f).last().pos().x();
		int dy = cur.pos().y()-touchPathPts.at(f).last().pos().y();

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
			if(touchPath.at(f).length() == 0 || touchPath.at(f).last() != "E")
				touchPath[f].append("E");
		}
		if(detectedLeft) {
			upd = true;
			if(touchPath.at(f).length() == 0 || touchPath.at(f).last() != "W")
				touchPath[f].append("W");
		}
		if(detectedDown) {
			upd = true;
			if(touchPath.at(f).length() == 0 || touchPath.at(f).last() != "S")
				touchPath[f].append("S");
		}
		if(detectedUp) {
			upd = true;
			if(touchPath.at(f).length() == 0 || touchPath.at(f).last() != "N")
				touchPath[f].append("N");
		}

		// Store new touch point
		if(upd)
			touchPathPts[f].append(cur);

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
