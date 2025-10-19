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
#pragma once

#include <QQmlPropertyMap>
#include <QRectF>
#include <QQmlEngine>

class QSettings;
class QTimer;

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton CANNOT be used from C++.
//            It can ONLY be used from QML.
//
/*************************************************************/
/*************************************************************/

class PQCWindowGeometry : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCWindowGeometry();
    ~PQCWindowGeometry();

    // main window
    Q_PROPERTY(QRectF mainWindowGeometry MEMBER m_mainWindowGeometry NOTIFY mainWindowGeometryChanged)
    Q_PROPERTY(QSize mainWindowPopoutThreshold MEMBER m_mainWindowPopoutThreshold NOTIFY mainWindowPopoutThresholdChanged)
    Q_PROPERTY(bool mainWindowMaximized MEMBER m_mainWindowMaximized NOTIFY mainWindowMaximizedChanged)
    Q_PROPERTY(bool mainWindowForcePopout MEMBER m_mainWindowForcePopout NOTIFY mainWindowForcePopoutChanged)

    // export
    Q_PROPERTY(QRectF exportGeometry MEMBER m_exportGeometry NOTIFY exportGeometryChanged)
    Q_PROPERTY(QSize exportPopoutThreshold MEMBER m_exportPopoutThreshold NOTIFY exportPopoutThresholdChanged)
    Q_PROPERTY(bool exportMaximized MEMBER m_exportMaximized NOTIFY exportMaximizedChanged)
    Q_PROPERTY(bool exportForcePopout MEMBER m_exportForcePopout NOTIFY exportForcePopoutChanged)

    // about
    Q_PROPERTY(QRectF aboutGeometry MEMBER m_aboutGeometry NOTIFY aboutGeometryChanged)
    Q_PROPERTY(QSize aboutPopoutThreshold MEMBER m_aboutPopoutThreshold NOTIFY aboutPopoutThresholdChanged)
    Q_PROPERTY(bool aboutMaximized MEMBER m_aboutMaximized NOTIFY aboutMaximizedChanged)
    Q_PROPERTY(bool aboutForcePopout MEMBER m_aboutForcePopout NOTIFY aboutForcePopoutChanged)

    // scale
    Q_PROPERTY(QRectF scaleGeometry MEMBER m_scaleGeometry NOTIFY scaleGeometryChanged)
    Q_PROPERTY(QSize scalePopoutThreshold MEMBER m_scalePopoutThreshold NOTIFY scalePopoutThresholdChanged)
    Q_PROPERTY(bool scaleMaximized MEMBER m_scaleMaximized NOTIFY scaleMaximizedChanged)
    Q_PROPERTY(bool scaleForcePopout MEMBER m_scaleForcePopout NOTIFY scaleForcePopoutChanged)

    // main menu
    Q_PROPERTY(QRectF mainmenuGeometry MEMBER m_mainmenuGeometry NOTIFY mainmenuGeometryChanged)
    Q_PROPERTY(QSize mainmenuPopoutThreshold MEMBER m_mainmenuPopoutThreshold NOTIFY mainmenuPopoutThresholdChanged)
    Q_PROPERTY(bool mainmenuMaximized MEMBER m_mainmenuMaximized NOTIFY mainmenuMaximizedChanged)
    Q_PROPERTY(bool mainmenuForcePopout MEMBER m_mainmenuForcePopout NOTIFY mainmenuForcePopoutChanged)

    // meta data
    Q_PROPERTY(QRectF metadataGeometry MEMBER m_metadataGeometry NOTIFY metadataGeometryChanged)
    Q_PROPERTY(QSize metadataPopoutThreshold MEMBER m_metadataPopoutThreshold NOTIFY metadataPopoutThresholdChanged)
    Q_PROPERTY(bool metadataMaximized MEMBER m_metadataMaximized NOTIFY metadataMaximizedChanged)
    Q_PROPERTY(bool metadataForcePopout MEMBER m_metadataForcePopout NOTIFY metadataForcePopoutChanged)

    // file dialog
    Q_PROPERTY(QRectF filedialogGeometry MEMBER m_filedialogGeometry NOTIFY filedialogGeometryChanged)
    Q_PROPERTY(QSize filedialogPopoutThreshold MEMBER m_filedialogPopoutThreshold NOTIFY filedialogPopoutThresholdChanged)
    Q_PROPERTY(bool filedialogMaximized MEMBER m_filedialogMaximized NOTIFY filedialogMaximizedChanged)
    Q_PROPERTY(bool filedialogForcePopout MEMBER m_filedialogForcePopout NOTIFY filedialogForcePopoutChanged)

    // histogram
    Q_PROPERTY(QRectF HistogramGeometry MEMBER m_histogramGeometry NOTIFY histogramGeometryChanged)
    Q_PROPERTY(QSize HistogramPopoutThreshold MEMBER m_histogramPopoutThreshold NOTIFY histogramPopoutThresholdChanged)
    Q_PROPERTY(bool HistogramMaximized MEMBER m_histogramMaximized NOTIFY histogramMaximizedChanged)
    Q_PROPERTY(bool HistogramForcePopout MEMBER m_histogramForcePopout NOTIFY histogramForcePopoutChanged)

    // map current
    Q_PROPERTY(QRectF mapcurrentGeometry MEMBER m_mapcurrentGeometry NOTIFY mapcurrentGeometryChanged)
    Q_PROPERTY(QSize mapcurrentPopoutThreshold MEMBER m_mapcurrentPopoutThreshold NOTIFY mapcurrentPopoutThresholdChanged)
    Q_PROPERTY(bool mapcurrentMaximized MEMBER m_mapcurrentMaximized NOTIFY mapcurrentMaximizedChanged)
    Q_PROPERTY(bool mapcurrentForcePopout MEMBER m_mapcurrentForcePopout NOTIFY mapcurrentForcePopoutChanged)

    // file delete
    Q_PROPERTY(QRectF filedeleteGeometry MEMBER m_filedeleteGeometry NOTIFY filedeleteGeometryChanged)
    Q_PROPERTY(QSize filedeletePopoutThreshold MEMBER m_filedeletePopoutThreshold NOTIFY filedeletePopoutThresholdChanged)
    Q_PROPERTY(bool filedeleteMaximized MEMBER m_filedeleteMaximized NOTIFY filedeleteMaximizedChanged)
    Q_PROPERTY(bool filedeleteForcePopout MEMBER m_filedeleteForcePopout NOTIFY filedeleteForcePopoutChanged)

    // file rename
    Q_PROPERTY(QRectF filerenameGeometry MEMBER m_filerenameGeometry NOTIFY filerenameGeometryChanged)
    Q_PROPERTY(QSize filerenamePopoutThreshold MEMBER m_filerenamePopoutThreshold NOTIFY filerenamePopoutThresholdChanged)
    Q_PROPERTY(bool filerenameMaximized MEMBER m_filerenameMaximized NOTIFY filerenameMaximizedChanged)
    Q_PROPERTY(bool filerenameForcePopout MEMBER m_filerenameForcePopout NOTIFY filerenameForcePopoutChanged)

    // filter
    Q_PROPERTY(QRectF filterGeometry MEMBER m_filterGeometry NOTIFY filterGeometryChanged)
    Q_PROPERTY(QSize filterPopoutThreshold MEMBER m_filterPopoutThreshold NOTIFY filterPopoutThresholdChanged)
    Q_PROPERTY(bool filterMaximized MEMBER m_filterMaximized NOTIFY filterMaximizedChanged)
    Q_PROPERTY(bool filterForcePopout MEMBER m_filterForcePopout NOTIFY filterForcePopoutChanged)

    // advanced sort
    Q_PROPERTY(QRectF advancedsortGeometry MEMBER m_advancedsortGeometry NOTIFY advancedsortGeometryChanged)
    Q_PROPERTY(QSize advancedsortPopoutThreshold MEMBER m_advancedsortPopoutThreshold NOTIFY advancedsortPopoutThresholdChanged)
    Q_PROPERTY(bool advancedsortMaximized MEMBER m_advancedsortMaximized NOTIFY advancedsortMaximizedChanged)
    Q_PROPERTY(bool advancedsortForcePopout MEMBER m_advancedsortForcePopout NOTIFY advancedsortForcePopoutChanged)

    // slideshow setup
    Q_PROPERTY(QRectF slideshowsetupGeometry MEMBER m_slideshowsetupGeometry NOTIFY slideshowsetupGeometryChanged)
    Q_PROPERTY(QSize slideshowsetupPopoutThreshold MEMBER m_slideshowsetupPopoutThreshold NOTIFY slideshowsetupPopoutThresholdChanged)
    Q_PROPERTY(bool slideshowsetupMaximized MEMBER m_slideshowsetupMaximized NOTIFY slideshowsetupMaximizedChanged)
    Q_PROPERTY(bool slideshowsetupForcePopout MEMBER m_slideshowsetupForcePopout NOTIFY slideshowsetupForcePopoutChanged)

    // slideshow controls
    Q_PROPERTY(QRectF slideshowcontrolsGeometry MEMBER m_slideshowcontrolsGeometry NOTIFY slideshowcontrolsGeometryChanged)
    Q_PROPERTY(QSize slideshowcontrolsPopoutThreshold MEMBER m_slideshowcontrolsPopoutThreshold NOTIFY slideshowcontrolsPopoutThresholdChanged)
    Q_PROPERTY(bool slideshowcontrolsMaximized MEMBER m_slideshowcontrolsMaximized NOTIFY slideshowcontrolsMaximizedChanged)
    Q_PROPERTY(bool slideshowcontrolsForcePopout MEMBER m_slideshowcontrolsForcePopout NOTIFY slideshowcontrolsForcePopoutChanged)

    // imgur
    Q_PROPERTY(QRectF imgurGeometry MEMBER m_imgurGeometry NOTIFY imgurGeometryChanged)
    Q_PROPERTY(QSize imgurPopoutThreshold MEMBER m_imgurPopoutThreshold NOTIFY imgurPopoutThresholdChanged)
    Q_PROPERTY(bool imgurMaximized MEMBER m_imgurMaximized NOTIFY imgurMaximizedChanged)
    Q_PROPERTY(bool imgurForcePopout MEMBER m_imgurForcePopout NOTIFY imgurForcePopoutChanged)

    // wallpaper
    Q_PROPERTY(QRectF wallpaperGeometry MEMBER m_wallpaperGeometry NOTIFY wallpaperGeometryChanged)
    Q_PROPERTY(QSize wallpaperPopoutThreshold MEMBER m_wallpaperPopoutThreshold NOTIFY wallpaperPopoutThresholdChanged)
    Q_PROPERTY(bool wallpaperMaximized MEMBER m_wallpaperMaximized NOTIFY wallpaperMaximizedChanged)
    Q_PROPERTY(bool wallpaperForcePopout MEMBER m_wallpaperForcePopout NOTIFY wallpaperForcePopoutChanged)

    // mapexplorer
    Q_PROPERTY(QRectF mapexplorerGeometry MEMBER m_mapexplorerGeometry NOTIFY mapexplorerGeometryChanged)
    Q_PROPERTY(QSize mapexplorerPopoutThreshold MEMBER m_mapexplorerPopoutThreshold NOTIFY mapexplorerPopoutThresholdChanged)
    Q_PROPERTY(bool mapexplorerMaximized MEMBER m_mapexplorerMaximized NOTIFY mapexplorerMaximizedChanged)
    Q_PROPERTY(bool mapexplorerForcePopout MEMBER m_mapexplorerForcePopout NOTIFY mapexplorerForcePopoutChanged)

    // chromecastmanager
    Q_PROPERTY(QRectF chromecastmanagerGeometry MEMBER m_chromecastmanagerGeometry NOTIFY chromecastmanagerGeometryChanged)
    Q_PROPERTY(QSize chromecastmanagerPopoutThreshold MEMBER m_chromecastmanagerPopoutThreshold NOTIFY chromecastmanagerPopoutThresholdChanged)
    Q_PROPERTY(bool chromecastmanagerMaximized MEMBER m_chromecastmanagerMaximized NOTIFY chromecastmanagerMaximizedChanged)
    Q_PROPERTY(bool chromecastmanagerForcePopout MEMBER m_chromecastmanagerForcePopout NOTIFY chromecastmanagerForcePopoutChanged)

    // imgur
    Q_PROPERTY(QRectF settingsmanagerGeometry MEMBER m_settingsmanagerGeometry NOTIFY settingsmanagerGeometryChanged)
    Q_PROPERTY(QSize settingsmanagerPopoutThreshold MEMBER m_settingsmanagerPopoutThreshold NOTIFY settingsmanagerPopoutThresholdChanged)
    Q_PROPERTY(bool settingsmanagerMaximized MEMBER m_settingsmanagerMaximized NOTIFY settingsmanagerMaximizedChanged)
    Q_PROPERTY(bool settingsmanagerForcePopout MEMBER m_settingsmanagerForcePopout NOTIFY settingsmanagerForcePopoutChanged)

    // crop
    Q_PROPERTY(QRectF cropGeometry MEMBER m_cropGeometry NOTIFY cropGeometryChanged)
    Q_PROPERTY(QSize cropPopoutThreshold MEMBER m_cropPopoutThreshold NOTIFY cropPopoutThresholdChanged)
    Q_PROPERTY(bool cropMaximized MEMBER m_cropMaximized NOTIFY cropMaximizedChanged)
    Q_PROPERTY(bool cropForcePopout MEMBER m_cropForcePopout NOTIFY cropForcePopoutChanged)

    // quickactions
    Q_PROPERTY(QRectF quickactionsGeometry MEMBER m_quickactionsGeometry NOTIFY quickactionsGeometryChanged)
    Q_PROPERTY(QSize quickactionsPopoutThreshold MEMBER m_quickactionsPopoutThreshold NOTIFY quickactionsPopoutThresholdChanged)
    Q_PROPERTY(bool quickactionsMaximized MEMBER m_quickactionsMaximized NOTIFY quickactionsMaximizedChanged)
    Q_PROPERTY(bool quickactionsForcePopout MEMBER m_quickactionsForcePopout NOTIFY quickactionsForcePopoutChanged)

    QSettings *settings;
    void load();

private Q_SLOTS:
    void save();
    void computeSmallSizeBehavior();

private:
    QTimer *saveDelay;

    QRectF m_mainWindowGeometry;
    QSize m_mainWindowPopoutThreshold;
    bool m_mainWindowMaximized;
    bool m_mainWindowForcePopout;

    QRectF m_exportGeometry;
    QSize m_exportPopoutThreshold;
    bool m_exportMaximized;
    bool m_exportForcePopout;

    QRectF m_aboutGeometry;
    QSize m_aboutPopoutThreshold;
    bool m_aboutMaximized;
    bool m_aboutForcePopout;

    QRectF m_scaleGeometry;
    QSize m_scalePopoutThreshold;
    bool m_scaleMaximized;
    bool m_scaleForcePopout;

    QRectF m_mainmenuGeometry;
    QSize m_mainmenuPopoutThreshold;
    bool m_mainmenuMaximized;
    bool m_mainmenuForcePopout;

    QRectF m_metadataGeometry;
    QSize m_metadataPopoutThreshold;
    bool m_metadataMaximized;
    bool m_metadataForcePopout;

    QRectF m_filedialogGeometry;
    QSize m_filedialogPopoutThreshold;
    bool m_filedialogMaximized;
    bool m_filedialogForcePopout;

    QRectF m_histogramGeometry;
    QSize m_histogramPopoutThreshold;
    bool m_histogramMaximized;
    bool m_histogramForcePopout;

    QRectF m_mapcurrentGeometry;
    QSize m_mapcurrentPopoutThreshold;
    bool m_mapcurrentMaximized;
    bool m_mapcurrentForcePopout;

    QRectF m_filedeleteGeometry;
    QSize m_filedeletePopoutThreshold;
    bool m_filedeleteMaximized;
    bool m_filedeleteForcePopout;

    QRectF m_filerenameGeometry;
    QSize m_filerenamePopoutThreshold;
    bool m_filerenameMaximized;
    bool m_filerenameForcePopout;

    QRectF m_filterGeometry;
    QSize m_filterPopoutThreshold;
    bool m_filterMaximized;
    bool m_filterForcePopout;

    QRectF m_advancedsortGeometry;
    QSize m_advancedsortPopoutThreshold;
    bool m_advancedsortMaximized;
    bool m_advancedsortForcePopout;

    QRectF m_slideshowsetupGeometry;
    QSize m_slideshowsetupPopoutThreshold;
    bool m_slideshowsetupMaximized;
    bool m_slideshowsetupForcePopout;

    QRectF m_slideshowcontrolsGeometry;
    QSize m_slideshowcontrolsPopoutThreshold;
    bool m_slideshowcontrolsMaximized;
    bool m_slideshowcontrolsForcePopout;

    QRectF m_imgurGeometry;
    QSize m_imgurPopoutThreshold;
    bool m_imgurMaximized;
    bool m_imgurForcePopout;

    QRectF m_wallpaperGeometry;
    QSize m_wallpaperPopoutThreshold;
    bool m_wallpaperMaximized;
    bool m_wallpaperForcePopout;

    QRectF m_mapexplorerGeometry;
    QSize m_mapexplorerPopoutThreshold;
    bool m_mapexplorerMaximized;
    bool m_mapexplorerForcePopout;

    QRectF m_chromecastmanagerGeometry;
    QSize m_chromecastmanagerPopoutThreshold;
    bool m_chromecastmanagerMaximized;
    bool m_chromecastmanagerForcePopout;

    QRectF m_settingsmanagerGeometry;
    QSize m_settingsmanagerPopoutThreshold;
    bool m_settingsmanagerMaximized;
    bool m_settingsmanagerForcePopout;

    QRectF m_cropGeometry;
    QSize m_cropPopoutThreshold;
    bool m_cropMaximized;
    bool m_cropForcePopout;

    QRectF m_quickactionsGeometry;
    QSize m_quickactionsPopoutThreshold;
    bool m_quickactionsMaximized;
    bool m_quickactionsForcePopout;

Q_SIGNALS:

    void mainWindowGeometryChanged();
    void mainWindowPopoutThresholdChanged();
    void mainWindowMaximizedChanged();
    void mainWindowForcePopoutChanged();

    void exportGeometryChanged();
    void exportPopoutThresholdChanged();
    void exportMaximizedChanged();
    void exportForcePopoutChanged();

    void aboutGeometryChanged();
    void aboutPopoutThresholdChanged();
    void aboutMaximizedChanged();
    void aboutForcePopoutChanged();

    void scaleGeometryChanged();
    void scalePopoutThresholdChanged();
    void scaleMaximizedChanged();
    void scaleForcePopoutChanged();

    void mainmenuGeometryChanged();
    void mainmenuPopoutThresholdChanged();
    void mainmenuMaximizedChanged();
    void mainmenuForcePopoutChanged();

    void metadataGeometryChanged();
    void metadataPopoutThresholdChanged();
    void metadataMaximizedChanged();
    void metadataForcePopoutChanged();

    void filedialogGeometryChanged();
    void filedialogPopoutThresholdChanged();
    void filedialogMaximizedChanged();
    void filedialogForcePopoutChanged();

    void histogramGeometryChanged();
    void histogramPopoutThresholdChanged();
    void histogramMaximizedChanged();
    void histogramForcePopoutChanged();

    void mapcurrentGeometryChanged();
    void mapcurrentPopoutThresholdChanged();
    void mapcurrentMaximizedChanged();
    void mapcurrentForcePopoutChanged();

    void filedeleteGeometryChanged();
    void filedeletePopoutThresholdChanged();
    void filedeleteMaximizedChanged();
    void filedeleteForcePopoutChanged();

    void filerenameGeometryChanged();
    void filerenamePopoutThresholdChanged();
    void filerenameMaximizedChanged();
    void filerenameForcePopoutChanged();

    void filterGeometryChanged();
    void filterPopoutThresholdChanged();
    void filterMaximizedChanged();
    void filterForcePopoutChanged();

    void advancedsortGeometryChanged();
    void advancedsortPopoutThresholdChanged();
    void advancedsortMaximizedChanged();
    void advancedsortForcePopoutChanged();

    void slideshowsetupGeometryChanged();
    void slideshowsetupPopoutThresholdChanged();
    void slideshowsetupMaximizedChanged();
    void slideshowsetupForcePopoutChanged();

    void slideshowcontrolsGeometryChanged();
    void slideshowcontrolsPopoutThresholdChanged();
    void slideshowcontrolsMaximizedChanged();
    void slideshowcontrolsForcePopoutChanged();

    void imgurGeometryChanged();
    void imgurPopoutThresholdChanged();
    void imgurMaximizedChanged();
    void imgurForcePopoutChanged();

    void wallpaperGeometryChanged();
    void wallpaperPopoutThresholdChanged();
    void wallpaperMaximizedChanged();
    void wallpaperForcePopoutChanged();

    void mapexplorerGeometryChanged();
    void mapexplorerPopoutThresholdChanged();
    void mapexplorerMaximizedChanged();
    void mapexplorerForcePopoutChanged();

    void chromecastmanagerGeometryChanged();
    void chromecastmanagerPopoutThresholdChanged();
    void chromecastmanagerMaximizedChanged();
    void chromecastmanagerForcePopoutChanged();

    void settingsmanagerGeometryChanged();
    void settingsmanagerPopoutThresholdChanged();
    void settingsmanagerMaximizedChanged();
    void settingsmanagerForcePopoutChanged();

    void cropGeometryChanged();
    void cropPopoutThresholdChanged();
    void cropMaximizedChanged();
    void cropForcePopoutChanged();

    void quickactionsGeometryChanged();
    void quickactionsPopoutThresholdChanged();
    void quickactionsMaximizedChanged();
    void quickactionsForcePopoutChanged();

};
