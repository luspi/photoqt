#include <pqc_popoutgeometry.h>
#include <pqc_configfiles.h>
#include <pqc_settings.h>

#include <QApplication>
#include <QSettings>
#include <QScreen>
#include <QTimer>

PQCPopoutGeometry::PQCPopoutGeometry() {

    settings = new QSettings(PQCConfigFiles::WINDOW_GEOMETRY_FILE(), QSettings::IniFormat);

    /*********************************************************/
    // list all elements and default and threshold sizes

    allElements.append(QVariant(QVariantList() << "export"      // name
                                               << 800 << 600    // default size
                                               << 800 << 800)); // popout threshold);

    allElements.append(QVariant(QVariantList() << "mainmenu"    // name
                                               << 400 << 600    // default size
                                               << 0 << 0));     // popout threshold);

    allElements.append(QVariant(QVariantList() << "metadata"    // name
                                               << 400 << 600    // default size
                                               << 0 << 0));     // popout threshold);

    // save values with delay
    saveDelay = new QTimer;
    saveDelay->setInterval(200);
    saveDelay->setSingleShot(true);
    connect(this, &QQmlPropertyMap::valueChanged, this, [=]() { saveDelay->start(); });
    connect(saveDelay, &QTimer::timeout, this, &PQCPopoutGeometry::save);

    // load data from file
    load();

}

PQCPopoutGeometry &PQCPopoutGeometry::get() {
    static PQCPopoutGeometry instance;
    return instance;
}

PQCPopoutGeometry::~PQCPopoutGeometry() {
    delete settings;
    delete saveDelay;
}

void PQCPopoutGeometry::load() {

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

void PQCPopoutGeometry::save() {

    computeSmallSizeBehavior();

    for(const auto &e : allElements) {
        const QString key = e.toList()[0].toString();
        const QString k1 = key+"Geometry";
        const QString k2 = key+"Maximized";
        settings->setValue(k1, this->value(k1));
        settings->setValue(k2, this->value(k2));
    }

}

void PQCPopoutGeometry::computeSmallSizeBehavior() {

    // store current window size
    const int w = this->value("windowWidth").toInt();
    const int h = this->value("windowHeight").toInt();
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
