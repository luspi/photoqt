function analyseMouseGestureUpdate(current, before) {

    var threshold = 50

    var dx = current.x-before.x
    var dy = current.y-before.y
    var distance = Math.sqrt(Math.pow(dx,2)+Math.pow(dy,2));

    var angle = (Math.atan2(dy, dx)/Math.PI)*180
    angle = (angle+360)%360;

    if(distance > threshold) {
        if(angle <= 45 || angle > 315)
            return "E"
        else if(angle > 45 && angle <= 135)
            return "S"
        else if(angle > 135 && angle <= 225)
            return "W"
        else if(angle > 225 && angle <= 315)
            return "N"
    }

    return ""

}
