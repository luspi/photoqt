import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import "../elements"
import "../loadfiles.js" as LoadFile

Item {

    id: imgur_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: opacity!=0

    property bool anonymous: false
    property string accountname: ""

    Item {
        id: dummyitem
        width: 0
        height: 0
    }

    ShaderEffectSource {
        id: effectSource
        sourceItem: PQSettings.imgurPopoutElement ? dummyitem : imageitem
        anchors.fill: parent
        sourceRect: Qt.rect(parent.x,parent.y,parent.width,parent.height)
    }

    FastBlur {
        id: blur
        anchors.fill: effectSource
        source: effectSource
        radius: 32
    }

    Rectangle {

        anchors.fill: parent
        color: "#cc000000"

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            enabled: !PQSettings.imgurPopoutElement
            onClicked:
                abortUpload()
        }

        Item {

            id: insidecont

            x: ((parent.width-width)/2)
            y: ((parent.height-height)/2)
            width: parent.width
            height: childrenRect.height

            clip: true

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            Column {

                spacing: 10

                Text {
                    x: (insidecont.width-width)/2
                    color: "white"
                    font.pointSize: 20
                    font.bold: true
                    visible: !report.visible
                    text: em.pty+qsTranslate("imgur", "Upload to imgur.com")
                }

                Text {
                    x: (insidecont.width-width)/2
                    color: "white"
                    font.pointSize: 15
                    font.bold: true
                    font.italic: true
                    visible: !report.visible
                    //: Used as in 'Upload image as anonymous user'
                    text: anonymous ? em.pty+qsTranslate("imgur", "anonymous") : accountname
                }

                Item {
                    width: 1
                    height: 10
                }

                Item {

                    width: childrenRect.width
                    height: childrenRect.height
                    x: (insidecont.width-width)/2

                    PQProgress {

                        id: progress
                        anchors.centerIn: report

                        visible: !report.visible && !error.visible && !nointernet.visible

                        onProgressChanged:
                                opacity = (progress.progress == 100) ? 0 : 1

                    }

                    Text {
                        anchors.centerIn: report
                        opacity: 1-progress.opacity
                        visible: !report.visible && !error.visible && !nointernet.visible
                        color: "white"
                        font.pointSize: 12
                        text: em.pty+qsTranslate("imgur", "Obtaining image url...")
                    }

                    Text {
                        id: longtime
                        anchors.top: progress.bottom
                        opacity: 1-progress.opacity
                        visible: !report.visible && !error.visible && !nointernet.visible
                        color: "red"
                        horizontalAlignment: Text.AlignHCenter
                        font.pointSize: 12
                        text: em.pty+qsTranslate("imgur", "This seems to take a long time...") + "<br>" +
                              em.pty+qsTranslate("imgur", "There might be a problem with your internet connection or the imgur.com servers.")
                    }

                    Text {
                        id: error
                        property int code: 0
                        anchors.centerIn: report
                        visible: false
                        color: "red"
                        horizontalAlignment: Text.AlignHCenter
                        font.pointSize: 12
                        text: em.pty+qsTranslate("imgur", "An Error occured while uploading image!") + "<br>" +
                              em.pty+qsTranslate("imgur", "Error code:") + " " + code
                    }

                    Text {
                        id: nointernet
                        property int code: 0
                        anchors.centerIn: report
                        visible: false
                        color: "red"
                        horizontalAlignment: Text.AlignHCenter
                        font.pointSize: 12
                        text: em.pty+qsTranslate("imgur", "You do not seem to be connected to the internet...") + "<br>" +
                              em.pty+qsTranslate("imgur", "Unable to upload!")
                    }

                    Item {
                        id: report
                        x: (longtime.width-width)/2
                        property string accessurl: "http://imgur.com/........"
                        property string deleteurl: "http://imgur.com/........"
                        visible: true

                        width: childrenRect.width
                        height: childrenRect.height

                        Column {

                            spacing: 10

                            width: childrenRect.width
                            height: childrenRect.height

                            Text {
                                color: "white"
                                text: em.pty+qsTranslate("imgur", "Access Image")
                                font.pointSize: 15
                                font.bold: true
                            }

                            Text {
                                color: "white"
                                text: report.accessurl
                                font.pointSize: 15
                                PQMouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    tooltip: em.pty+qsTranslate("imgur", "Click to open in browser")
                                    onClicked:
                                        Qt.openUrlExternally(parent.text)
                                }
                            }

                            PQButton {
                                text: em.pty+qsTranslate("imgur", "Copy to clipboard")
                                onClicked:
                                    handlingGeneral.copyTextToClipboard(report.accessurl)
                            }

                            Item {
                                width: 1
                                height: 10
                            }

                            Text {
                                color: "white"
                                text: em.pty+qsTranslate("imgur", "Delete Image")
                                font.pointSize: 15
                                font.bold: true
                            }

                            Text {
                                color: "white"
                                text: report.deleteurl
                                font.pointSize: 15
                                PQMouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    tooltip: em.pty+qsTranslate("imgur", "Click to open in browser")
                                    onClicked:
                                        Qt.openUrlExternally(parent.text)
                                }
                            }

                            PQButton {
                                text: em.pty+qsTranslate("imgur", "Copy to clipboard")
                                onClicked:
                                    handlingGeneral.copyTextToClipboard(report.deleteurl)
                            }

                        }

                    }

                }

                Item {
                    width: 1
                    height: 10
                }

                PQButton {

                    x: (insidecont.width-width)/2
                    text: report.visible ? genericStringClose : genericStringCancel
                    onClicked:
                        abortUpload()
                }

            }

        }

        Connections {
            target: handlingShareImgur
            onImgurUploadProgress: {
                progress.progress = perc*100
                error.visible = false
                report.visible = false
                nointernet.visible = false
            }
            onFinished: {
                error.visible = false
                nointernet.visible = false
                report.visible = true
            }
            onImgurUploadError: {
                error.code = err
                error.visible = true
                report.visible = false
                nointernet.visible = false
            }
            onImgurImageUrl: {
                report.accessurl = url
            }

            onImgurDeleteHash: {
                report.deleteurl = "http://imgur.com/delete/" + url
            }

        }

        Connections {
            target: loader
            onImgurPassOn: {
                if(what == "show" || what == "show_anonym") {

                    if(variables.indexOfCurrentImage == -1)
                        return

                    anonymous = (what == "show_anonym")
                    progress.progress = 0
                    longtime.visible = false
                    error.visible = false
                    nointernet.visible = false
                    report.visible = false

                    if(!handlingGeneral.checkIfConnectedToInternet())
                        nointernet.visible = true

                    handlingShareImgur.authorizeHandlePin("68713a8441")

                    opacity = 1
                    variables.visibleItem = "imgur"

                    if(!anonymous) {
                        var ret = handlingShareImgur.authAccount()
                        if(ret !== 0) {
                            abortUpload()
                            return
                        }
                        accountname = handlingShareImgur.getAccountUsername()
                        handlingShareImgur.upload(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                    } else {
                        accountname = ""
                        handlingShareImgur.anonymousUpload(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                    }

                } else if(what == "hide") {
                    abortUpload()
                } else if(what == "keyevent") {
                    if(param[0] == Qt.Key_Escape)
                        abortUpload()
                }
            }
        }



        Shortcut {
            sequence: "Esc"
            enabled: PQSettings.imgurPopoutElement
            onActivated: abortUpload()
        }

    }

    function abortUpload() {
        handlingShareImgur.abort()
        opacity = 0
        variables.visibleItem = ""
    }

}
