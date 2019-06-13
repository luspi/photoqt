#include "windowgeometry.h"
#include <QtDebug>

PQWindowGeometry::PQWindowGeometry(QObject *parent) : QObject(parent) {

    m_mainWindowMaximized = false;
    m_mainWindowGeometry = QRect();

    settings = new QSettings(ConfigFiles::WINDOW_GEOMETRY_FILE(), QSettings::IniFormat);

    readGeometries();

}

void PQWindowGeometry::readGeometries() {

    m_mainWindowGeometry = settings->value("mainWindowGeometry").toRect();
    m_mainWindowMaximized = settings->value("mainWindowMaximized").toBool();

    m_fileDialogWindowGeometry = settings->value("fileDialogWindowGeometry").toRect();
    m_fileDialogWindowMaximized = settings->value("fileDialogWindowMaximized").toBool();

}

void PQWindowGeometry::saveGeometries() {

    settings->setValue("mainWindowGeometry", m_mainWindowGeometry);
    settings->setValue("mainWindowMaximized", m_mainWindowMaximized);

    settings->setValue("fileDialogWindowGeometry", m_fileDialogWindowGeometry);;
    settings->setValue("fileDialogWindowMaximized", m_fileDialogWindowMaximized);

}
