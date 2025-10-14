/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
#include <pqc_settingscpp.h>

#include <QApplication>
#include <QSettings>
#include <QScreen>
#include <QTimer>

PQCWindowGeometry::PQCWindowGeometry() {

    settings = new QSettings(PQCConfigFiles::get().WINDOW_GEOMETRY_FILE(), QSettings::IniFormat);

    const int sw = QApplication::primaryScreen()->size().width();
    const int sh = QApplication::primaryScreen()->size().height();

    m_mainWindowGeometry = QRectF((sw-800)/2.0, (sh-600)/2.0, 800, 600);
    m_mainWindowPopoutThreshold = QSize(0, 0);
    m_mainWindowMaximized = false;
    m_mainWindowForcePopout = false;

    m_exportGeometry = QRectF((sw-800)/2.0, (sh-600)/2.0, 800, 600);
    m_exportPopoutThreshold = QSize(600, 600);
    m_exportMaximized = false;
    m_exportForcePopout = false;

    m_aboutGeometry = QRectF((sw-800)/2.0, (sh-600)/2.0, 800, 600);
    m_aboutPopoutThreshold = QSize(600, 500);
    m_aboutMaximized = false;
    m_aboutForcePopout = false;

    m_scaleGeometry = QRectF((sw-800)/2.0, (sh-600)/2.0, 800, 600);
    m_scalePopoutThreshold = QSize(600, 400);
    m_scaleMaximized = false;
    m_scaleForcePopout = false;

    m_mainmenuGeometry = QRectF((sw-400)/2.0, (sh-600)/2.0, 400, 600);
    m_mainmenuPopoutThreshold = QSize(0, 0);
    m_mainmenuMaximized = false;
    m_mainmenuForcePopout = false;

    m_metadataGeometry = QRectF((sw-400)/2.0, (sh-600)/2.0, 400, 600);
    m_metadataPopoutThreshold = QSize(0, 0);
    m_metadataMaximized = false;
    m_metadataForcePopout = false;

    m_filedialogGeometry = QRectF((sw-1024)/2.0, (sh-768)/2.0, 1024, 768);
    m_filedialogPopoutThreshold = QSize(800, 700);
    m_filedialogMaximized = false;
    m_filedialogForcePopout = false;

    m_histogramGeometry = QRectF((sw-300)/2.0, (sh-200)/2.0, 300, 200);
    m_histogramPopoutThreshold = QSize(500, 350);
    m_histogramMaximized = false;
    m_histogramForcePopout = false;

    m_mapcurrentGeometry = QRectF((sw-400)/2.0, (sh-300)/2.0, 400, 300);
    m_mapcurrentPopoutThreshold = QSize(700, 500);
    m_mapcurrentMaximized = false;
    m_mapcurrentForcePopout = false;

    m_filedeleteGeometry = QRectF((sw-800)/2.0, (sh-600)/2.0, 800, 600);
    m_filedeletePopoutThreshold = QSize(600, 400);
    m_filedeleteMaximized = false;
    m_filedeleteForcePopout = false;

    m_filerenameGeometry = QRectF((sw-800)/2.0, (sh-600)/2.0, 800, 600);
    m_filerenamePopoutThreshold = QSize(600, 400);
    m_filerenameMaximized = false;
    m_filerenameForcePopout = false;

    m_filterGeometry = QRectF((sw-600)/2.0, (sh-400)/2.0, 600, 400);
    m_filterPopoutThreshold = QSize(650, 450);
    m_filterMaximized = false;
    m_filterForcePopout = false;

    m_advancedsortGeometry = QRectF((sw-800)/2.0, (sh-600)/2.0, 800, 600);
    m_advancedsortPopoutThreshold = QSize(650, 450);
    m_advancedsortMaximized = false;
    m_advancedsortForcePopout = false;

    m_slideshowsetupGeometry = QRectF((sw-800)/2.0, (sh-600)/2.0, 800, 600);
    m_slideshowsetupPopoutThreshold = QSize(800, 650);
    m_slideshowsetupMaximized = false;
    m_slideshowsetupForcePopout = false;

    m_slideshowcontrolsGeometry = QRectF((sw-400)/2.0, (sh-200)/2.0, 400, 200);
    m_slideshowcontrolsPopoutThreshold = QSize(0, 0);
    m_slideshowcontrolsMaximized = false;
    m_slideshowcontrolsForcePopout = false;

    m_imgurGeometry = QRectF((sw-800)/2.0, (sh-600)/2.0, 800, 600);
    m_imgurPopoutThreshold = QSize(600, 400);
    m_imgurMaximized = false;
    m_imgurForcePopout = false;

    m_wallpaperGeometry = QRectF((sw-800)/2.0, (sh-600)/2.0, 800, 600);
    m_wallpaperPopoutThreshold = QSize(600, 400);
    m_wallpaperMaximized = false;
    m_wallpaperForcePopout = false;

    m_mapexplorerGeometry = QRectF((sw-1024)/2.0, (sh-768)/2.0, 1024, 768);
    m_mapexplorerPopoutThreshold = QSize(800, 700);
    m_mapexplorerMaximized = false;
    m_mapexplorerForcePopout = false;

    m_chromecastmanagerGeometry = QRectF((sw-800)/2.0, (sh-600)/2.0, 800, 600);
    m_chromecastmanagerPopoutThreshold = QSize(600, 400);
    m_chromecastmanagerMaximized = false;
    m_chromecastmanagerForcePopout = false;

    m_settingsmanagerGeometry = QRectF((sw-1000)/2.0, (sh-800)/2.0, 1000, 800);
    m_settingsmanagerPopoutThreshold = QSize(1100, 800);
    m_settingsmanagerMaximized = false;
    m_settingsmanagerForcePopout = false;

    m_cropGeometry = QRectF((sw-800)/2.0, (sh-600)/2.0, 800, 600);
    m_cropPopoutThreshold = QSize(650, 450);
    m_cropMaximized = false;
    m_cropForcePopout = false;

    m_quickactionsGeometry = QRectF(0, 0, 0, 0);
    m_quickactionsPopoutThreshold = QSize(0, 0);
    m_quickactionsMaximized = false;
    m_quickactionsForcePopout = false;

    /******************************************************************/

    // save values with delay
    saveDelay = new QTimer;
    saveDelay->setInterval(200);
    saveDelay->setSingleShot(true);
    connect(saveDelay, &QTimer::timeout, this, &PQCWindowGeometry::save);

    /******************************************************************/


    connect(this, &PQCWindowGeometry::mainWindowGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::mainWindowPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::mainWindowMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::mainWindowForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::exportGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::exportPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::exportMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::exportForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::aboutGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::aboutPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::aboutMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::aboutForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::scaleGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::scalePopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::scaleMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::scaleForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::mainmenuGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::mainmenuPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::mainmenuMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::mainmenuForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::metadataGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::metadataPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::metadataMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::metadataForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::filedialogGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::filedialogPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::filedialogMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::filedialogForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::histogramGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::histogramPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::histogramMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::histogramForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::mapcurrentGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::mapcurrentPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::mapcurrentMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::mapcurrentForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::filedeleteGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::filedeletePopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::filedeleteMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::filedeleteForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::filerenameGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::filerenamePopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::filerenameMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::filerenameForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::filterGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::filterPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::filterMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::filterForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::advancedsortGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::advancedsortPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::advancedsortMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::advancedsortForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::slideshowsetupGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::slideshowsetupPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::slideshowsetupMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::slideshowsetupForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::slideshowcontrolsGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::slideshowcontrolsPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::slideshowcontrolsMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::slideshowcontrolsForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::imgurGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::imgurPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::imgurMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::imgurForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::wallpaperGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::wallpaperPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::wallpaperMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::wallpaperForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::mapexplorerGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::mapexplorerPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::mapexplorerMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::mapexplorerForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::chromecastmanagerGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::chromecastmanagerPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::chromecastmanagerMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::chromecastmanagerForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::settingsmanagerGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::settingsmanagerPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::settingsmanagerMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::settingsmanagerForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::cropGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::cropPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::cropMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::cropForcePopoutChanged, this, [=]() { saveDelay->start(); });

    connect(this, &PQCWindowGeometry::quickactionsGeometryChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::quickactionsPopoutThresholdChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::quickactionsMaximizedChanged, this, [=]() { saveDelay->start(); });
    connect(this, &PQCWindowGeometry::quickactionsForcePopoutChanged, this, [=]() { saveDelay->start(); });

    /******************************************************************/

    // load data from file
    load();

}

PQCWindowGeometry::~PQCWindowGeometry() {
    delete settings;
    delete saveDelay;
}

void PQCWindowGeometry::load() {

    const QStringList keys = settings->allKeys();

    for(const QString &key : keys) {

        if(key == "aboutGeometry")
            m_aboutGeometry = settings->value(key).toRect();
        else if(key == "aboutMaximized")
            m_aboutMaximized = settings->value(key).toBool();

        else if(key == "advancedsortGeometry")
            m_advancedsortGeometry = settings->value(key).toRect();
        else if(key == "advancedsortMaximized")
            m_advancedsortMaximized = settings->value(key).toBool();

        else if(key == "chromecastmanagerGeometry")
            m_chromecastmanagerGeometry = settings->value(key).toRect();
        else if(key == "chromecastmanagerMaximized")
            m_chromecastmanagerMaximized = settings->value(key).toBool();

        else if(key == "cropGeometry")
            m_cropGeometry = settings->value(key).toRect();
        else if(key == "cropMaximized")
            m_cropMaximized = settings->value(key).toBool();

        else if(key == "exportGeometry")
            m_exportGeometry = settings->value(key).toRect();
        else if(key == "exportMaximized")
            m_exportMaximized = settings->value(key).toBool();

        else if(key == "filedeleteGeometry")
            m_filedeleteGeometry = settings->value(key).toRect();
        else if(key == "filedeleteMaximized")
            m_filedeleteMaximized = settings->value(key).toBool();

        else if(key == "filedialogGeometry")
            m_filedialogGeometry = settings->value(key).toRect();
        else if(key == "filedialogMaximized")
            m_filedialogMaximized = settings->value(key).toBool();

        else if(key == "filerenameGeometry")
            m_filerenameGeometry = settings->value(key).toRect();
        else if(key == "filerenameMaximized")
            m_filerenameMaximized = settings->value(key).toBool();

        else if(key == "filterGeometry")
            m_filterGeometry = settings->value(key).toRect();
        else if(key == "filterMaximized")
            m_filterMaximized = settings->value(key).toBool();

        else if(key == "histogramGeometry")
            m_histogramGeometry = settings->value(key).toRect();
        else if(key == "histogramMaximized")
            m_histogramMaximized = settings->value(key).toBool();

        else if(key == "imgurGeometry")
            m_imgurGeometry = settings->value(key).toRect();
        else if(key == "imgurMaximized")
            m_imgurMaximized = settings->value(key).toBool();

        else if(key == "mainWindowGeometry")
            m_mainWindowGeometry = settings->value(key).toRect();
        else if(key == "mainWindowMaximized")
            m_mainWindowMaximized = settings->value(key).toBool();

        else if(key == "mainmenuGeometry")
            m_mainmenuGeometry = settings->value(key).toRect();
        else if(key == "mainmenuMaximized")
            m_mainmenuMaximized = settings->value(key).toBool();

        else if(key == "mapcurrentGeometry")
            m_mapcurrentGeometry = settings->value(key).toRect();
        else if(key == "mapcurrentMaximized")
            m_mapcurrentMaximized = settings->value(key).toBool();

        else if(key == "mapexplorerGeometry")
            m_mapexplorerGeometry = settings->value(key).toRect();
        else if(key == "mapexplorerMaximized")
            m_mapexplorerMaximized = settings->value(key).toBool();

        else if(key == "metadataGeometry")
            m_metadataGeometry = settings->value(key).toRect();
        else if(key == "metadataMaximized")
            m_metadataMaximized = settings->value(key).toBool();

        else if(key == "quickactionsGeometry")
            m_quickactionsGeometry = settings->value(key).toRect();
        else if(key == "quickactionsMaximized")
            m_quickactionsMaximized = settings->value(key).toBool();

        else if(key == "scaleGeometry")
            m_scaleGeometry = settings->value(key).toRect();
        else if(key == "scaleMaximized")
            m_scaleMaximized = settings->value(key).toBool();

        else if(key == "settingsmanagerGeometry")
            m_settingsmanagerGeometry = settings->value(key).toRect();
        else if(key == "settingsmanagerMaximized")
            m_settingsmanagerMaximized = settings->value(key).toBool();

        else if(key == "slideshowcontrolsGeometry")
            m_slideshowcontrolsGeometry = settings->value(key).toRect();
        else if(key == "slideshowcontrolsMaximized")
            m_slideshowcontrolsMaximized = settings->value(key).toBool();

        else if(key == "slideshowsetupGeometry")
            m_slideshowsetupGeometry = settings->value(key).toRect();
        else if(key == "slideshowsetupMaximized")
            m_slideshowsetupMaximized = settings->value(key).toBool();

        else if(key == "wallpaperGeometry")
            m_wallpaperGeometry = settings->value(key).toRect();
        else if(key == "wallpaperMaximized")
            m_wallpaperMaximized = settings->value(key).toBool();


    }

}

void PQCWindowGeometry::save() {

    settings->setValue("aboutGeometry", m_aboutGeometry);
    settings->setValue("aboutMaximized", m_aboutMaximized);

    settings->setValue("advancedsortGeometry", m_advancedsortGeometry);
    settings->setValue("advancedsortMaximized", m_advancedsortMaximized);

    settings->setValue("chromecastmanagerGeometry", m_chromecastmanagerGeometry);
    settings->setValue("chromecastmanagerMaximized", m_chromecastmanagerMaximized);

    settings->setValue("cropGeometry", m_cropGeometry);
    settings->setValue("cropMaximized", m_cropMaximized);

    settings->setValue("exportGeometry", m_exportGeometry);
    settings->setValue("exportMaximized", m_exportMaximized);

    settings->setValue("filedeleteGeometry", m_filedeleteGeometry);
    settings->setValue("filedeleteMaximized", m_filedeleteMaximized);

    settings->setValue("filedialogGeometry", m_filedialogGeometry);
    settings->setValue("filedialogMaximized", m_filedialogMaximized);

    settings->setValue("filerenameGeometry", m_filerenameGeometry);
    settings->setValue("filerenameMaximized", m_filerenameMaximized);

    settings->setValue("filterGeometry", m_filterGeometry);
    settings->setValue("filterMaximized", m_filterMaximized);

    settings->setValue("histogramGeometry", m_histogramGeometry);
    settings->setValue("histogramMaximized", m_histogramMaximized);

    settings->setValue("imgurGeometry", m_imgurGeometry);
    settings->setValue("imgurMaximized", m_imgurMaximized);

    settings->setValue("mainWindowGeometry", m_mainWindowGeometry);
    settings->setValue("mainWindowMaximized", m_mainWindowMaximized);

    settings->setValue("mainmenuGeometry", m_mainmenuGeometry);
    settings->setValue("mainmenuMaximized", m_mainmenuMaximized);

    settings->setValue("mapcurrentGeometry", m_mapcurrentGeometry);
    settings->setValue("mapcurrentMaximized", m_mapcurrentMaximized);

    settings->setValue("mapexplorerGeometry", m_mapexplorerGeometry);
    settings->setValue("mapexplorerMaximized", m_mapexplorerMaximized);

    settings->setValue("metadataGeometry", m_metadataGeometry);
    settings->setValue("metadataMaximized", m_metadataMaximized);

    settings->setValue("quickactionsGeometry", m_quickactionsGeometry);
    settings->setValue("quickactionsMaximized", m_quickactionsMaximized);

    settings->setValue("scaleGeometry", m_scaleGeometry);
    settings->setValue("scaleMaximized", m_scaleMaximized);

    settings->setValue("settingsmanagerGeometry", m_settingsmanagerGeometry);
    settings->setValue("settingsmanagerMaximized", m_settingsmanagerMaximized);

    settings->setValue("slideshowcontrolsGeometry", m_slideshowcontrolsGeometry);
    settings->setValue("slideshowcontrolsMaximized", m_slideshowcontrolsMaximized);

    settings->setValue("slideshowsetupGeometry", m_slideshowsetupGeometry);
    settings->setValue("slideshowsetupMaximized", m_slideshowsetupMaximized);

    settings->setValue("wallpaperGeometry", m_wallpaperGeometry);
    settings->setValue("wallpaperMaximized", m_wallpaperMaximized);

    computeSmallSizeBehavior();

}

void PQCWindowGeometry::computeSmallSizeBehavior() {

    // store current window size
    const int w = m_mainWindowGeometry.width();
    const int h = m_mainWindowGeometry.height();
    // store setting
    bool dontForce = !PQCSettingsCPP::get().getInterfacePopoutWhenWindowIsSmall();

    {
        const int tw = m_mainWindowGeometry.width();
        const int th = m_mainWindowGeometry.height();
        m_mainWindowForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_exportGeometry.width();
        const int th = m_exportGeometry.height();
        m_exportForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_aboutGeometry.width();
        const int th = m_aboutGeometry.height();
        m_aboutForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_scaleGeometry.width();
        const int th = m_scaleGeometry.height();
        m_scaleForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_mainmenuGeometry.width();
        const int th = m_mainmenuGeometry.height();
        m_mainmenuForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_metadataGeometry.width();
        const int th = m_metadataGeometry.height();
        m_metadataForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_filedialogGeometry.width();
        const int th = m_filedialogGeometry.height();
        m_filedialogForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_histogramGeometry.width();
        const int th = m_histogramGeometry.height();
        m_histogramForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_mapcurrentGeometry.width();
        const int th = m_mapcurrentGeometry.height();
        m_mapcurrentForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_filedeleteGeometry.width();
        const int th = m_filedeleteGeometry.height();
        m_filedeleteForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_filerenameGeometry.width();
        const int th = m_filerenameGeometry.height();
        m_filerenameForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_filterGeometry.width();
        const int th = m_filterGeometry.height();
        m_filterForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_advancedsortGeometry.width();
        const int th = m_advancedsortGeometry.height();
        m_advancedsortForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_slideshowsetupGeometry.width();
        const int th = m_slideshowsetupGeometry.height();
        m_slideshowsetupForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_slideshowcontrolsGeometry.width();
        const int th = m_slideshowcontrolsGeometry.height();
        m_slideshowcontrolsForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_imgurGeometry.width();
        const int th = m_imgurGeometry.height();
        m_imgurForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_wallpaperGeometry.width();
        const int th = m_wallpaperGeometry.height();
        m_wallpaperForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_mapexplorerGeometry.width();
        const int th = m_mapexplorerGeometry.height();
        m_mapexplorerForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_chromecastmanagerGeometry.width();
        const int th = m_chromecastmanagerGeometry.height();
        m_chromecastmanagerForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_settingsmanagerGeometry.width();
        const int th = m_settingsmanagerGeometry.height();
        m_settingsmanagerForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_cropGeometry.width();
        const int th = m_cropGeometry.height();
        m_cropForcePopout = (!dontForce && (h<th || w < tw));
    }{
        const int tw = m_quickactionsGeometry.width();
        const int th = m_quickactionsGeometry.height();
        m_quickactionsForcePopout = (!dontForce && (h<th || w < tw));
    }

}
