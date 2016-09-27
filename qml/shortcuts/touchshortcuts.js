function gotUpdatedTouchGesture(startPoint, endPoint, type, numFingers, duration, path) {

	console.log("***********************************")
	console.log("RECEIVED UPDATED TOUCH EVENT")
	console.log("start point:",startPoint)
	console.log("end point:",endPoint)
	console.log("type:",type)
	console.log("# fingers:", numFingers)
	console.log("duration:",duration)
	console.log("gesture path:",path)
	console.log("***********************************")
	console.log()

	settingsmanager.updateTouchGesture(numFingers, type, path)

}

function gotFinishedTouchGesture(startPoint, endPoint, type, numFingers, duration, path) {

	console.log("***********************************")
	console.log("RECEIVED FINISHED TOUCH EVENT")
	console.log("start point:",startPoint)
	console.log("end point:",endPoint)
	console.log("type:",type)
	console.log("# fingers:", numFingers)
	console.log("duration:",duration)
	console.log("gesture path:",path)
	console.log("***********************************")
	console.log()

	settingsmanager.finishedTouchGesture(numFingers, type, path)

}
