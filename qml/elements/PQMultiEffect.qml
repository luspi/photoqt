import QtQuick
import QtQuick.Effects

// this needs to be a subelement like this as the MultiEffect is only available starting in Qt 6.4
// having this in its own file allows us to use a conditional Loader whenever we want to use it

MultiEffect {
    anchors.fill: source
}
