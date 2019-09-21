#include "windowgeometry.h"
#include <QtDebug>

PQWindowGeometry::PQWindowGeometry(QObject *parent) : QObject(parent) {

    m_mainWindowMaximized = true;
    m_mainWindowGeometry = QRect(0,0,1024,768);

    m_fileDialogWindowMaximized = true;
    m_fileDialogWindowGeometry = QRect(0,0,800,600);

    m_mainMenuWindowMaximized = false;
    QRect ref = QGuiApplication::screens().at(0)->geometry();
    m_mainMenuWindowGeometry = QRect(ref.width()-400, 0, 400, 700);

    m_metaDataWindowMaximized = false;
    m_metaDataWindowGeometry = QRect(0, 0, 400, 700);

    m_histogramWindowMaximized = false;
    m_histogramWindowGeometry = QRect(100, 100, 300, 200);

    m_slideshowWindowMaximized = true;
    m_slideshowWindowGeometry = QRect(0, 0, 800, 600);

    m_slideshowControlsWindowMaximized = true;
    m_slideshowControlsWindowGeometry = QRect(0, 0, 200, 200);

    settings = new QSettings(ConfigFiles::WINDOW_GEOMETRY_FILE(), QSettings::IniFormat);

    readGeometries();

}

void PQWindowGeometry::readGeometries() {

    if(settings->allKeys().contains("mainWindowGeometry"))
        m_mainWindowGeometry = settings->value("mainWindowGeometry").toRect();
    if(settings->allKeys().contains("mainWindowMaximized"))
        m_mainWindowMaximized = settings->value("mainWindowMaximized").toBool();

    if(settings->allKeys().contains("fileDialogWindowGeometry"))
        m_fileDialogWindowGeometry = settings->value("fileDialogWindowGeometry").toRect();
    if(settings->allKeys().contains("fileDialogWindowMaximized"))
        m_fileDialogWindowMaximized = settings->value("fileDialogWindowMaximized").toBool();

    if(settings->allKeys().contains("mainMenuWindowGeometry"))
        m_mainMenuWindowGeometry = settings->value("mainMenuWindowGeometry").toRect();
    if(settings->allKeys().contains("mainMenuWindowMaximized"))
        m_mainMenuWindowMaximized = settings->value("mainMenuWindowMaximized").toBool();

    if(settings->allKeys().contains("metaDataWindowGeometry"))
        m_metaDataWindowGeometry = settings->value("metaDataWindowGeometry").toRect();
    if(settings->allKeys().contains("metaDataWindowMaximized"))
        m_metaDataWindowMaximized = settings->value("metaDataWindowMaximized").toBool();

    if(settings->allKeys().contains("histogramWindowGeometry"))
        m_histogramWindowGeometry = settings->value("histogramWindowGeometry").toRect();
    if(settings->allKeys().contains("histogramWindowMaximized"))
        m_histogramWindowMaximized = settings->value("histogramWindowMaximized").toBool();

    if(settings->allKeys().contains("slideshowWindowGeometry"))
        m_slideshowWindowGeometry = settings->value("slideshowWindowGeometry").toRect();
    if(settings->allKeys().contains("slideshowWindowMaximized"))
        m_slideshowWindowMaximized = settings->value("slideshowWindowMaximized").toBool();

    if(settings->allKeys().contains("slideshowControlsWindowGeometry"))
        m_slideshowControlsWindowGeometry = settings->value("slideshowControlsWindowGeometry").toRect();
    if(settings->allKeys().contains("slideshowControlsWindowMaximized"))
        m_slideshowControlsWindowMaximized = settings->value("slideshowControlsWindowMaximized").toBool();

}

void PQWindowGeometry::saveGeometries() {

    settings->setValue("mainWindowGeometry", m_mainWindowGeometry);
    settings->setValue("mainWindowMaximized", m_mainWindowMaximized);

    settings->setValue("fileDialogWindowGeometry", m_fileDialogWindowGeometry);;
    settings->setValue("fileDialogWindowMaximized", m_fileDialogWindowMaximized);

    settings->setValue("mainMenuWindowGeometry", m_mainMenuWindowGeometry);;
    settings->setValue("mainMenuWindowMaximized", m_mainMenuWindowMaximized);

    settings->setValue("metaDataWindowGeometry", m_metaDataWindowGeometry);;
    settings->setValue("metaDataWindowMaximized", m_metaDataWindowMaximized);

    settings->setValue("histogramWindowGeometry", m_histogramWindowGeometry);;
    settings->setValue("histogramWindowMaximized", m_histogramWindowMaximized);

    settings->setValue("slideshowWindowGeometry", m_slideshowWindowGeometry);;
    settings->setValue("slideshowWindowMaximized", m_slideshowWindowMaximized);

    settings->setValue("slideshowControlsWindowGeometry", m_slideshowControlsWindowGeometry);
    settings->setValue("slideshowControlsWindowMaximized", m_slideshowControlsWindowMaximized);

}
