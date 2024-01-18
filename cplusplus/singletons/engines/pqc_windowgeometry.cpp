/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include <pqc_windowgeometry.h>
#include <pqc_configfiles.h>
#include <pqc_settings.h>

#include <QApplication>
#include <QSettings>
#include <QScreen>
#include <QTimer>

PQCWindowGeometry::PQCWindowGeometry() {

    settings = new QSettings(PQCConfigFiles::WINDOW_GEOMETRY_FILE(), QSettings::IniFormat);

    /*********************************************************/
    // list all elements and default and threshold sizes

    allElements.append(QVariant(QVariantList() << "mainWindow"  // name
                                               << 800 << 600    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "export"      // name
                                               << 800 << 600    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "about"       // name
                                               << 800 << 600    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "scale"       // name
                                               << 800 << 600    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "mainmenu"    // name
                                               << 400 << 600    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "metadata"    // name
                                               << 400 << 600    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "filedialog"  // name
                                               << 1024 << 768   // default size
                                               << 800 << 700)); // popout threshold;

    allElements.append(QVariant(QVariantList() << "histogram"   // name
                                               << 300 << 200    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "mapcurrent"  // name
                                               << 400 << 300    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "filedelete"  // name
                                               << 800 << 600    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "filerename"  // name
                                               << 800 << 600    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "filter"      // name
                                               << 800 << 600    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "advancedsort"// name
                                               << 800 << 600    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "slideshowsetup"// name
                                               << 800 << 600    // default size
                                               << 800 << 650)); // popout threshold;

    allElements.append(QVariant(QVariantList() << "slideshowcontrols"// name
                                               << 400 << 200    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "imgur"       // name
                                               << 800 << 600    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "wallpaper"   // name
                                               << 800 << 600    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "mapexplorer" // name
                                               << 1024 << 768    // default size
                                               << 800 << 700));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "chromecastmanager"// name
                                               << 800 << 600    // default size
                                               << 0 << 0));     // popout threshold;

    allElements.append(QVariant(QVariantList() << "settingsmanager"// name
                                               << 1000 << 800    // default size
                                               << 1100 << 800)); // popout threshold;

    // save values with delay
    saveDelay = new QTimer;
    saveDelay->setInterval(200);
    saveDelay->setSingleShot(true);
    connect(this, &QQmlPropertyMap::valueChanged, this, [=]() { saveDelay->start(); });
    connect(saveDelay, &QTimer::timeout, this, &PQCWindowGeometry::save);

    // load data from file
    load();

}

PQCWindowGeometry &PQCWindowGeometry::get() {
    static PQCWindowGeometry instance;
    return instance;
}

PQCWindowGeometry::~PQCWindowGeometry() {
    delete settings;
    delete saveDelay;
}

void PQCWindowGeometry::load() {

    const int sw = QApplication::primaryScreen()->size().width();
    const int sh = QApplication::primaryScreen()->size().height();

    for(const auto &e : allElements) {

        const QVariantList cur = e.toList();

        const QString key = cur[0].toString();
        const int w = cur[1].toInt();
        const int h = cur[2].toInt();

        const QString k1 = key+"Geometry";
        const QString k2 = key+"Maximized";
        const QString k3 = key+"ForcePopout";

        if(settings->allKeys().contains(k1))
            this->insert(k1, settings->value(k1).toRect());
        else
            this->insert(k1, QRect((sw-w)/2.0, (sh-h)/2.0, w, h));

        if(settings->allKeys().contains(k2))
            this->insert(k2, settings->value(k2).toBool());
        else
            this->insert(k2, false);

        this->insert(k3, false);

    }

}

void PQCWindowGeometry::save() {

    computeSmallSizeBehavior();

    for(const auto &e : allElements) {
        const QString key = e.toList()[0].toString();
        const QString k1 = key+"Geometry";
        const QString k2 = key+"Maximized";
        settings->setValue(k1, this->value(k1).toRect());   // some rect show up as QRectF here and mess with the how the value is written to file
        settings->setValue(k2, this->value(k2));
    }

}

void PQCWindowGeometry::computeSmallSizeBehavior() {

    // store current window size
    const int w = this->value("mainWindowGeometry").toRect().width();
    const int h = this->value("mainWindowGeometry").toRect().height();
    // store setting
    bool dontForce = !PQCSettings::get()["interfacePopoutWhenWindowIsSmall"].toBool();

    for(const auto &e : allElements) {

        const QVariantList cur = e.toList();

        const QString key = cur[0].toString();
        const int tw = cur[3].toInt();
        const int th = cur[4].toInt();

        this->insert(key+"ForcePopout", (!dontForce && (h<th || w < tw)));

    }

}
