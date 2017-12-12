#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QObject>
#include <QQmlApplicationEngine>
#include <QQmlProperty>
#include <iostream>

#include "variables.h"

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

    void setEngine(QQmlApplicationEngine *engine);

    void registerQmlTypes();
    void addImageProvider();

private:
    QQmlApplicationEngine *engine;
    QObject *object;
    Variables *variables;

private slots:
    void qmlVerboseMessage(QString loc, QString msg);

};



#endif // MAINWINDOW_H
