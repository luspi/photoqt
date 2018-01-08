
function analyseMouseGestureUpdate(xPos, yPos, before) {

    var threshold = 100

    var dx = xPos-before.x
    var dy = yPos-before.y
    var distance = Math.sqrt(Math.pow(dx,2)+Math.pow(dy,2));

    var angle = (Math.atan2(dy, dx)/Math.PI)*180
    angle = (angle+360)%360;

    if(distance > threshold) {

        if(angle <= 45 || angle > 315) {
            if(variables.shortcutsMouseGesture[variables.shortcutsMouseGesture.length-1] != "E") {
                variables.shortcutsMouseGesture.push("E")
                variables.shorcutsMouseGesturePointIntermediate = Qt.point(xPos, yPos)
            }
        } else if(angle > 45 && angle <= 135) {
            if(variables.shortcutsMouseGesture[variables.shortcutsMouseGesture.length-1] != "S") {
                variables.shortcutsMouseGesture.push("S")
                variables.shorcutsMouseGesturePointIntermediate = Qt.point(xPos, yPos)
            }
        } else if(angle > 135 && angle <= 225) {
            if(variables.shortcutsMouseGesture[variables.shortcutsMouseGesture.length-1] != "W") {
                variables.shortcutsMouseGesture.push("W")
                variables.shorcutsMouseGesturePointIntermediate = Qt.point(xPos, yPos)
            }
        } else if(angle > 225 && angle <= 315) {
            if(variables.shortcutsMouseGesture[variables.shortcutsMouseGesture.length-1] != "N") {
                variables.shortcutsMouseGesture.push("N")
                variables.shorcutsMouseGesturePointIntermediate = Qt.point(xPos, yPos)
            }
        }

    }

}

function analyseMouseEvent(startedEventAtPos, event) {

    var combostring = getModifiers(event)

    if(event.button == Qt.LeftButton)
        combostring += "Left Button"
    else if(event.button == Qt.MiddleButton)
            combostring += "Middle Button"
    else if(event.button == Qt.RightButton)
            combostring += "Right Button"

    var movement = ""
    for(var i = 0; i < variables.shortcutsMouseGesture.length; ++i)
        movement += variables.shortcutsMouseGesture[i]
    variables.shortcutsMouseGesture = []

    if(movement != "") {
        if(event.button == Qt.LeftButton && settings.leftButtonMouseClickAndMove)
            return ""
        combostring += "+" + movement
    }

    return combostring

}

function analyseWheelEvent(event) {

    var combostring = getModifiers(event)

    var angleX = event.angleDelta.x
    var angleY = event.angleDelta.y

    if(event.inverted) {
        var tmp = angleX
        angleX = angleY
        angleY = angleX
    }

    var threashold = settings.mouseWheelSensitivity*5

    if(angleX > threashold) {
        if(angleY > threashold)
            combostring += "Wheel Up Right"
        else if(angleY < -threashold)
            combostring += "Wheel Down Right"
        else
            combostring += "Wheel Right"
    } else if(angleX < -threashold) {
        if(angleY > threashold)
            combostring += "Wheel Up Left"
        else if(angleY < -threashold)
            combostring += "Wheel Down Left"
        else
            combostring += "Wheel Left"
    } else {
        if(angleY > threashold)
            combostring += "Wheel Up"
        else if(angleY < -threashold)
            combostring += "Wheel Down"
    }

    return combostring

}

function extractMovement(posStart, posEnd) {

    var threshold = settings.mouseWheelSensitivity*10

    var dx = posEnd.x-posStart.x
    var dy = posEnd.y-posStart.y

    if(dx > threshold) {

        if(dy > threshold)
            return "SE"
        else if(dy < -threshold)
            return "NE"
        else
            return "E"

    } else if(dx < -threshold) {

        if(dy > threshold)
            return "SW"
        else if(dy < -threshold)
            return "NW"
        else
            return "W"

    } else {

        if(dy > threshold)
            return "S"
        else if(dy < -threshold)
            return "N"

    }

    return ""

}

function getModifiers(event) {

    var modstring = ""

    if(event.modifiers & Qt.ControlModifier)
        modstring += "Ctrl+"
    if(event.modifiers & Qt.AltModifier)
        modstring += "Alt+"
    if(event.modifiers & Qt.ShiftModifier)
        modstring += "Shift+"
    if(event.modifiers & Qt.MetaModifier)
        modstring += "Meta+"
    if(event.modifiers & Qt.KeypadModifier)
        modstring += "Keypad+"

    return modstring

}
