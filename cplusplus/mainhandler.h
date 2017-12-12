#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QObject>
#include <QQmlApplicationEngine>
#include <iostream>

#include "settings/colour.h"
#include "settings/fileformats.h"
#include "settings/settings.h"
#include "scripts/getanddostuff.h"
#include "scripts/getmetadata.h"
#include "scripts/shareonline/imgur.h"
#include "tooltip/tooltip.h"
#include "scripts/imagewatch.h"
#include "clipboard/clipboard.h"

#include "imageprovider/imageproviderempty.h"
#include "imageprovider/imageproviderfull.h"
#include "imageprovider/imageproviderhistogram.h"
#include "imageprovider/imageprovidericon.h"
#include "imageprovider/imageproviderthumbnail.h"

class MainHandler : public QObject {

    Q_OBJECT

public:
    MainHandler(QObject *parent = 0);
    void setEngine(QQmlApplicationEngine *engine) { this->engine = engine; }
    void registerQmlTypes();
    void addImageProvider();

private:
    QQmlApplicationEngine *engine;

};



#endif // MAINWINDOW_H
