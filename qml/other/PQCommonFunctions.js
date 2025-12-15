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

// this compares two dicts where the key is a simple value and the value is a list
function areTwoDictofListsEqual(d1, d2) {

    // same object -> true
    if(d1 === d2)
        return true

    const k1 = Object.keys(d1).sort()
    const k2 = Object.keys(d2).sort()

    // different key lengths -> false
    if(k1.length !== k2.length)
        return false

    // different keys -> fals
    for(var i in k1) {
        if(k1[i] !== k2[i])
            return false
    }

    // different values -> false
    for(var j in k1) {
        const v1 = d1[k1[j]]
        const v2 = d2[k2[j]]
        if(!areTwoListsEqual(v1, v2))
            return false
    }

    // everything matched -> true
    return true

}

// This replaces the ambersand (&) with an underline html tag
function parseMenuString(txt) {
    var ret = txt
    var i = ret.indexOf("&")
    if(i > -1) {
        ret = txt.replace("&", "")
        ret = ret.slice(0, i) + "<u>" + ret[i] + "</u>" + ret.slice(i+1)
    }
    return ret
}
