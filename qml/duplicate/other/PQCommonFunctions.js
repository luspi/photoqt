.pragma library

// do not make this function typed, it will break
function areTwoListsEqual(l1, l2) {

    if(l1.length !== l2.length)
        return false

    for(var i = 0; i < l1.length; ++i) {

        if(l1[i].length !== l2[i].length)
            return false

        for(var j = 0; j < l1[i].length; ++j) {
            if(l1[i][j] !== l2[i][j])
                return false
        }
    }

    return true
}
