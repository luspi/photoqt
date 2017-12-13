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

#include "startup/exportimport.h"
#include "startup/fileformats.h"
#include "startup/localisation.h"
#include "startup/migration.h"
#include "startup/screenshots.h"
#include "startup/startintray.h"
#include "startup/thumbnails.h"
#include "startup/updatecheck.h"

class MainHandler : public QObject {

    Q_OBJECT

public:

    MainHandler(bool verbose, QObject *parent = 0);

    void setEngine(QQmlApplicationEngine *engine);

    int performSomeStartupChecks();
    void loadTranslation();
    void registerQmlTypes();
    void addImageProvider();

public slots:
    void remoteAction(QString cmd);

private:
    QQmlApplicationEngine *engine;
    QObject *object;
    Variables *variables;
    Settings *permanentSettings;
    QTranslator trans;

private slots:
    void qmlVerboseMessage(QString loc, QString msg);

};



#endif // MAINWINDOW_H
