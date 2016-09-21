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

//		var dx = endPoint.x-startPoint.x
//		var dy = endPoint.y-startPoint.y

//		if(gesture.length === 1 && numFingers === 1) {
//			if(startPoint.x > background.width-100 && gesture[0] === "W") {
//				mainmenu.show()
//				return
//			} else if(startPoint.x < 100 && gesture[0] === "E") {
//				metaData.show()
//				return
//			} else if(startPoint.y > background.height-100 && gesture[0] === "N") {
//				thumbnailBar.show()
//				return
//			}
//		}

//		if(gesture.length === 1 && numFingers === 1 && duration < 300 && thumbnailBar.currentFile != "") {
//			if(gesture[0] === "E") {
//				nextImage()
//				return
//			} else if(gesture[0] === "W") {
//				previousImage()
//				return
//			}
//		}

//		if(gesture.length === 3 && numFingers === 1 && duration < 1500) {
//			if(gesture[0] === "S" && gesture[1] === "E" && gesture[2] === "S") {
//				quitPhotoQt()
//				return
//			}
//		}

//		if(gesture.length === 2 && numFingers === 1 && duration < 750) {
//			if(gesture[0] === "S" && gesture[1] === "N") {
//				openFile()
//				return
//			}
//		}

}
