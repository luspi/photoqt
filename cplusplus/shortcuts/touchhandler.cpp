#include "touchhandler.h"

TouchHandler::TouchHandler(QObject *parent) : QObject(parent) {
	touchPath.clear();
	threshold = 50;
	amDetecting = false;
	numFingers = 0;
	gestureTimeoutMs = 5000;
}

TouchHandler::~TouchHandler() { }

// This handles any touch event
bool TouchHandler::handle(QEvent *e) {

	// A new touch was started
	if(e->type() == QEvent::TouchBegin) {
		touchStarted((QTouchEvent*)e);
		return true;
	// An update to the touch has been detected
	} else if((e->type() == QEvent::TouchUpdate)) {
		touchUpdated((QTouchEvent*)e);
		return true;
	// A touch gesture was ended
	} else if(e->type() == QEvent::TouchEnd) {
		touchEnded((QTouchEvent*)e);
		return true;
	} else if(e->type() == QEvent::TouchCancel) {
		touchCancelled();
		return true;
	}

	// Event not a touch event
	return false;

}

// Start a new touch
void TouchHandler::touchStarted(QTouchEvent *e) {

	// In the middle of touc gesture -> ignore mouseevent duplicates
	amDetecting = true;

	// Reset variables
	touchPath.clear();
	touchPathPts.clear();
	numFingers = e->touchPoints().count();

	// Get initial touch points
	for(unsigned int f = 0; f < numFingers; ++f) {
		touchPathPts.append(QList<QTouchEvent::TouchPoint>());
		touchPathPts[f].append(e->touchPoints().at(f));
		touchPath.append(QStringList());
	}

	// Calculate initial center point of all touch points
	double x = 0, y = 0;
	for(unsigned int f = 0; f < numFingers; ++f) {
		x += e->touchPoints().at(f).pos().x();
		y += e->touchPoints().at(f).pos().y();
	}
	gestureCenterPointStart = QPointF(x/numFingers,y/numFingers);

	// Current time for duration of gesture
	startTime = QDateTime::currentMSecsSinceEpoch();

}

// Update to touch
void TouchHandler::touchUpdated(QTouchEvent *e) {

	// If not touch points are present, something went wrong, so we do nothing
	if(e->touchPoints().length() == 0)
		return;

	// If the number of fingers has increased, we restart the gesture detection
	// (that is likely to happen when putting multiple fingers onto the display)
	if(numFingers < e->touchPoints().count())
		return touchStarted(e);
	// If the number of fingers has decreased, that likely means the gesture is about to end and we ignore anything that follows
	else if(numFingers > e->touchPoints().count())
		return;

	// If the current gesture has been updated, we pass on an event to the interface
	bool signalUpdateToTouchGesture = false;

	// If the fingers have been moved at least the threshold distance, we record that as during a pinch this will also signal an update
	bool movedAtLeastThresholdDistance = false;

	// Loop over all touch points
	for(unsigned int f = 0; f < e->touchPoints().count(); ++f) {

		// Get current touch points
		QTouchEvent::TouchPoint cur = e->touchPoints().at(f);

		// Calculate the distance moved since last touch point
		int dx = cur.pos().x()-touchPathPts.at(f).last().pos().x();
		int dy = cur.pos().y()-touchPathPts.at(f).last().pos().y();
		double distance = std::sqrt(std::pow(dx,2)+std::pow(dy,2));

		// Get the angle of the current resulting touch direction
		int angle = ((std::atan2(dy,dx)/M_PI)*180);
		angle = (angle+360)%360;

		// If fingers were moved far enough
		if(distance > threshold) {

			// moved right
			if(angle <= 45 || angle > 315) {
				if(touchPath.at(f).length() == 0 || touchPath.at(f).last() != "E") {
					touchPath[f].append("E");
					signalUpdateToTouchGesture = true;
				}
			// moved up
			} else if(angle > 45 && angle <= 135) {
				if(touchPath.at(f).length() == 0 || touchPath.at(f).last() != "S") {
					touchPath[f].append("S");
					signalUpdateToTouchGesture = true;
				}
			// moved left
			} else if(angle > 135 && angle <= 225) {
				if(touchPath.at(f).length() == 0 || touchPath.at(f).last() != "W") {
					touchPath[f].append("W");
					signalUpdateToTouchGesture = true;
				}
			// moved down
			} else if(angle > 225 && angle <= 315) {
				if(touchPath.at(f).length() == 0 || touchPath.at(f).last() != "N") {
					touchPath[f].append("N");
					signalUpdateToTouchGesture = true;
				}
			}

			movedAtLeastThresholdDistance = true;

			// Store new touch point
			touchPathPts[f].append(cur);

		}

	}

	// Analyse the gesture up to now
	QVariantList analysed = analyseGestureUpToNow();

	if(signalUpdateToTouchGesture
			|| (analysed.at(0).toString().startsWith("pinch") && movedAtLeastThresholdDistance)
			|| (analysed.at(0).toString() == "swipe" && analysed.at(1).toString().length() == 1 && movedAtLeastThresholdDistance)) {

		// current time to calculate duration of gesture so far
		qint64 curTime = QDateTime::currentMSecsSinceEpoch();

		// Emit the right signal values
		if(analysed.at(0).toString() == "tap")
			emit updatedTouchEvent(gestureCenterPointStart, gestureCenterPointEnd, "tap", numFingers, curTime-startTime, QStringList());
		else if(analysed.at(0).toString() == "swipe")
			emit updatedTouchEvent(gestureCenterPointStart, gestureCenterPointEnd, "swipe", numFingers, curTime-startTime, analysed.at(1).toStringList());
		else if(analysed.at(0).toString().startsWith("pinch"))
			emit updatedTouchEvent(gestureCenterPointStart, gestureCenterPointEnd, analysed.at(0).toString(), analysed.at(1).toInt(), curTime-startTime, QStringList());

	}

}

// A gesture has been finished
void TouchHandler::touchEnded(QTouchEvent *) {

	amDetecting = false;
	emit setImageInteractiveMode(true);

	// current time to calculate duration of gesture
	qint64 endTime = QDateTime::currentMSecsSinceEpoch();

	// If the touch took too long -> do nothing
	if(endTime-startTime > gestureTimeoutMs)
		return;

	// Analyse the final gesture
	QVariantList analysed = analyseGestureUpToNow();

	// Emit the right signal values
	if(analysed.at(0).toString() == "tap")
		emit receivedTouchEvent(gestureCenterPointStart, gestureCenterPointEnd, "tap", numFingers, endTime-startTime, QStringList());
	else if(analysed.at(0).toString() == "swipe")
		emit receivedTouchEvent(gestureCenterPointStart, gestureCenterPointEnd, "swipe", numFingers, endTime-startTime, analysed.at(1).toStringList());
	else if(analysed.at(0).toString().startsWith("pinch"))
		emit receivedTouchEvent(gestureCenterPointStart, gestureCenterPointEnd, analysed.at(0).toString(), analysed.at(1).toInt(), endTime-startTime, QStringList());

}

// Whenever a touch has been cancelled (seperate QEvent type)
void TouchHandler::touchCancelled() {

	// Reset all variables...

	amDetecting = false;

	touchPath.clear();
	touchPathPts.clear();
	numFingers = 0;

	gestureCenterPointStart = QPointF();
	gestureCenterPointEnd = QPointF();

}

// This function evaluates the current state of the gesture and returns a QVariantList out of the following five possibilities:
// 1) ["tap"]
// 2) ["swipe", path]
// 3) ["pinchIN", pinchNumFingers]
// 4) ["pinchOUT", pinchNumFingers]
// 5) ["???"]
// This function DOES NOT return any global variables (obviously)!
QVariantList TouchHandler::analyseGestureUpToNow() {

	// Calculate final center point of all touch points
	double x = 0, y = 0;
	for(unsigned int f = 0; f < numFingers; ++f) {
		x += touchPathPts[f].last().pos().x();
		y += touchPathPts[f].last().pos().y();
	}
	gestureCenterPointEnd = QPointF(x/numFingers,y/numFingers);

	// Figure the max/min of points for all fingers combined
	int maxlength = 0;
	int minlength = std::numeric_limits<int>::max();
	for(unsigned int f = 0; f < numFingers; ++f) {
		maxlength = qMax(maxlength,touchPath[f].count());
		minlength = qMin(minlength, touchPath[f].count());
	}

	// if fingers haven't been moved -> TAP
	if(maxlength == 0)
		return QVariantList() << "tap";

	// If fingers have been moved -> further processing
	else if(minlength > 0) {

		// first check if all fingers were moved along the same path
		bool allAlongSamePath = true;
		QStringList combinedPath;

		// analyse to retrieve combined path
		for(unsigned int i = 0; i < minlength; ++i) {
			bool same = true;
			QString cur = touchPath[0][i];
			for(unsigned int f = 0; f < numFingers; ++f) {
				if(touchPath[f][i] != cur)
					same = false;
			}
			if(same)
				combinedPath.append(cur);
			// if there's a difference -> stop and move on
			else {
				allAlongSamePath = false;
				break;
			}

		}

		// Confirmed: All along the same path
		if(allAlongSamePath)

			return QVariantList() << "swipe" << combinedPath;

		// Check for 2/3/4 fingers pinch
		else {

			// How many fingers are in use -> This does not reflect the actual nunmber of fingers used, but the number of directions in which the fingers have been drawn
			unsigned int pinchNumFingers = 0;

			// At least one of the fingers has exactly one touchpoint (most likely all of them have)
			if(minlength == 1) {

				// detect number of directions
				bool north = false;
				bool east = false;
				bool south = false;
				bool west = false;

				// Check which directions are in use
				for(unsigned int i = 0; i < numFingers; ++i) {
					if(touchPath[i][0] == "N")
						north = true;
					else if(touchPath[i][0] == "E")
						east = true;
					else if(touchPath[i][0] == "S")
						south = true;
					else if(touchPath[i][0] == "W")
						west = true;
				}

				// Check which direction is MISSING
				QStringList zeroDirections;
				if(!north) zeroDirections.append("N");
				if(!east) zeroDirections.append("E");
				if(!south) zeroDirections.append("S");
				if(!west) zeroDirections.append("W");

				// A pinch can happen with 2, 3, or 4 directions
				if(zeroDirections.count() == 2 &&
						((zeroDirections.contains("N") && zeroDirections.contains("S"))
						 || (zeroDirections.contains("E") && zeroDirections.contains("W"))))
					pinchNumFingers = 2;
				else if(zeroDirections.count() == 1)
					pinchNumFingers = 3;
				else if(zeroDirections.count() == 0)
					pinchNumFingers = 4;

				// If a valid pinch was detected
				if(pinchNumFingers != 0) {

					// Get dx and dy between initial and final touch point -> used to detect in or out pinch
					double initialX = fabs(touchPathPts[0][0].pos().x()-touchPathPts[1][0].pos().x());
					double endX = fabs(touchPathPts[0][1].pos().x()-touchPathPts[1][1].pos().x());
					double initialY = fabs(touchPathPts[0][0].pos().y()-touchPathPts[1][0].pos().y());
					double endY = fabs(touchPathPts[0][1].pos().y()-touchPathPts[1][1].pos().y());

					// Use above dx/dy to detect pinch directions
					QString type;
					if((north && south && initialY-endY < 0) || (west && east && initialX-endX < 0))
						type = "pinchOUT";
					else if((north && south && initialY-endY >= 0) || (west && east && initialX-endX >= 0))
						type = "pinchIN";

					// Yay, we successfully detected a pinch touch event!!
					return QVariantList() << type << pinchNumFingers;

				}

			}

		}

	}

	// Unable to understand touch event... What on earth did the user do??
	return QVariantList() << "???";

}
