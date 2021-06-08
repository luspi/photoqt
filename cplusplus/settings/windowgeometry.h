/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

#ifndef PQWINDOWGEOMETRY_H
#define PQWINDOWGEOMETRY_H

#include <QObject>
#include <QRect>
#include <QSettings>
#include <QApplication>
#include <QScreen>
#include "../logger.h"
#include "../scripts/handlingexternal.h"

class PQWindowGeometry : public QObject {

    Q_OBJECT

public:
    explicit PQWindowGeometry(QObject *parent = 0);
    ~PQWindowGeometry();

    Q_PROPERTY(QRect mainWindowGeometry READ getMainWindowGeometry WRITE setMainWindowGeometry NOTIFY mainWindowGeometryChanged)
    const QRect getMainWindowGeometry() { return m_mainWindowGeometry; }
    void setMainWindowGeometry(QRect rect) {
        if(rect != m_mainWindowGeometry) {
            m_mainWindowGeometry = rect;
            emit mainWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool mainWindowMaximized READ getMainWindowMaximized WRITE setMainWindowMaximized NOTIFY mainWindowMaximizedChanged)
    bool getMainWindowMaximized() { return m_mainWindowMaximized; }
    void setMainWindowMaximized(bool maximized) {
        if(maximized != m_mainWindowMaximized) {
            m_mainWindowMaximized = maximized;
            emit mainWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect fileDialogWindowGeometry READ getFileDialogWindowGeometry WRITE setFileDialogWindowGeometry NOTIFY fileDialogWindowGeometryChanged)
    QRect getFileDialogWindowGeometry() { return m_fileDialogWindowGeometry; }
    void setFileDialogWindowGeometry(QRect rect) {
        if(rect != m_fileDialogWindowGeometry) {
            m_fileDialogWindowGeometry = rect;
            emit fileDialogWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool fileDialogWindowMaximized READ getFileDialogWindowMaximized WRITE setFileDialogWindowMaximized NOTIFY fileDialogWindowMaximizedChanged)
    bool getFileDialogWindowMaximized() { return m_fileDialogWindowMaximized; }
    void setFileDialogWindowMaximized(bool maximized) {
        if(maximized != m_fileDialogWindowMaximized) {
            m_fileDialogWindowMaximized = maximized;
            emit fileDialogWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect mainMenuWindowGeometry READ getMainMenuWindowGeometry WRITE setMainMenuWindowGeometry NOTIFY mainMenuWindowGeometryChanged)
    QRect getMainMenuWindowGeometry() { return m_mainMenuWindowGeometry; }
    void setMainMenuWindowGeometry(QRect rect) {
        if(rect != m_mainMenuWindowGeometry) {
            m_mainMenuWindowGeometry = rect;
            emit mainMenuWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool mainMenuWindowMaximized READ getMainMenuWindowMaximized WRITE setMainMenuWindowMaximized NOTIFY mainMenuWindowMaximizedChanged)
    bool getMainMenuWindowMaximized() { return m_mainMenuWindowMaximized; }
    void setMainMenuWindowMaximized(bool maximized) {
        if(maximized != m_mainMenuWindowMaximized) {
            m_mainMenuWindowMaximized = maximized;
            emit mainMenuWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect metaDataWindowGeometry READ getMetaDataWindowGeometry WRITE setMetaDataWindowGeometry NOTIFY metaDataWindowGeometryChanged)
    QRect getMetaDataWindowGeometry() { return m_metaDataWindowGeometry; }
    void setMetaDataWindowGeometry(QRect rect) {
        if(rect != m_metaDataWindowGeometry) {
            m_metaDataWindowGeometry = rect;
            emit metaDataWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool metaDataWindowMaximized READ getMetaDataWindowMaximized WRITE setMetaDataWindowMaximized NOTIFY metaDataWindowMaximizedChanged)
    bool getMetaDataWindowMaximized() { return m_metaDataWindowMaximized; }
    void setMetaDataWindowMaximized(bool maximized) {
        if(maximized != m_metaDataWindowMaximized) {
            m_metaDataWindowMaximized = maximized;
            emit metaDataWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect histogramWindowGeometry READ getHistogramWindowGeometry WRITE setHistogramWindowGeometry NOTIFY histogramWindowGeometryChanged)
    QRect getHistogramWindowGeometry() { return m_histogramWindowGeometry; }
    void setHistogramWindowGeometry(QRect rect) {
        if(rect != m_histogramWindowGeometry) {
            m_histogramWindowGeometry = rect;
            emit histogramWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool histogramWindowMaximized READ getHistogramWindowMaximized WRITE setHistogramWindowMaximized NOTIFY histogramWindowMaximizedChanged)
    bool getHistogramWindowMaximized() { return m_histogramWindowMaximized; }
    void setHistogramWindowMaximized(bool maximized) {
        if(maximized != m_histogramWindowMaximized) {
            m_histogramWindowMaximized = maximized;
            emit histogramWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect slideshowWindowGeometry READ getSlideshowWindowGeometry WRITE setSlideshowWindowGeometry NOTIFY slideshowWindowGeometryChanged)
    QRect getSlideshowWindowGeometry() { return m_slideshowWindowGeometry; }
    void setSlideshowWindowGeometry(QRect rect) {
        if(rect != m_slideshowWindowGeometry) {
            m_slideshowWindowGeometry = rect;
            emit slideshowWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool slideshowWindowMaximized READ getSlideshowWindowMaximized WRITE setSlideshowWindowMaximized NOTIFY slideshowWindowMaximizedChanged)
    bool getSlideshowWindowMaximized() { return m_slideshowWindowMaximized; }
    void setSlideshowWindowMaximized(bool maximized) {
        if(maximized != m_slideshowWindowMaximized) {
            m_slideshowWindowMaximized = maximized;
            emit slideshowWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect slideshowControlsWindowGeometry READ getSlideshowControlsWindowGeometry WRITE setSlideshowControlsWindowGeometry NOTIFY slideshowControlsWindowGeometryChanged)
    QRect getSlideshowControlsWindowGeometry() { return m_slideshowControlsWindowGeometry; }
    void setSlideshowControlsWindowGeometry(QRect rect) {
        if(rect != m_slideshowControlsWindowGeometry) {
            m_slideshowControlsWindowGeometry = rect;
            emit slideshowControlsWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool slideshowControlsWindowMaximized READ getSlideshowControlsWindowMaximized WRITE setSlideshowControlsWindowMaximized NOTIFY slideshowControlsWindowMaximizedChanged)
    bool getSlideshowControlsWindowMaximized() { return m_slideshowControlsWindowMaximized; }
    void setSlideshowControlsWindowMaximized(bool maximized) {
        if(maximized != m_slideshowControlsWindowMaximized) {
            m_slideshowControlsWindowMaximized = maximized;
            emit slideshowControlsWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect fileRenameWindowGeometry READ getFileRenameWindowGeometry WRITE setFileRenameWindowGeometry NOTIFY fileRenameWindowGeometryChanged)
    QRect getFileRenameWindowGeometry() { return m_fileRenameWindowGeometry; }
    void setFileRenameWindowGeometry(QRect rect) {
        if(rect != m_fileRenameWindowGeometry) {
            m_fileRenameWindowGeometry = rect;
            emit fileRenameWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool fileRenameWindowMaximized READ getFileRenameWindowMaximized WRITE setFileRenameWindowMaximized NOTIFY fileRenameWindowMaximizedChanged)
    bool getFileRenameWindowMaximized() { return m_fileRenameWindowMaximized; }
    void setFileRenameWindowMaximized(bool maximized) {
        if(maximized != m_fileRenameWindowMaximized) {
            m_fileRenameWindowMaximized = maximized;
            emit fileRenameWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect fileDeleteWindowGeometry READ getFileDeleteWindowGeometry WRITE setFileDeleteWindowGeometry NOTIFY fileDeleteWindowGeometryChanged)
    QRect getFileDeleteWindowGeometry() { return m_fileDeleteWindowGeometry; }
    void setFileDeleteWindowGeometry(QRect rect) {
        if(rect != m_fileDeleteWindowGeometry) {
            m_fileDeleteWindowGeometry = rect;
            emit fileDeleteWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool fileDeleteWindowMaximized READ getFileDeleteWindowMaximized WRITE setFileDeleteWindowMaximized NOTIFY fileDeleteWindowMaximizedChanged)
    bool getFileDeleteWindowMaximized() { return m_fileDeleteWindowMaximized; }
    void setFileDeleteWindowMaximized(bool maximized) {
        if(maximized != m_fileDeleteWindowMaximized) {
            m_fileDeleteWindowMaximized = maximized;
            emit fileDeleteWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect scaleWindowGeometry READ getScaleWindowGeometry WRITE setScaleWindowGeometry NOTIFY scaleWindowGeometryChanged)
    QRect getScaleWindowGeometry() { return m_scaleWindowGeometry; }
    void setScaleWindowGeometry(QRect rect) {
        if(rect != m_scaleWindowGeometry) {
            m_scaleWindowGeometry = rect;
            emit scaleWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool scaleWindowMaximized READ getScaleWindowMaximized WRITE setScaleWindowMaximized NOTIFY scaleWindowMaximizedChanged)
    bool getScaleWindowMaximized() { return m_scaleWindowMaximized; }
    void setScaleWindowMaximized(bool maximized) {
        if(maximized != m_scaleWindowMaximized) {
            m_scaleWindowMaximized = maximized;
            emit scaleWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect aboutWindowGeometry READ getAboutWindowGeometry WRITE setAboutWindowGeometry NOTIFY aboutWindowGeometryChanged)
    QRect getAboutWindowGeometry() { return m_aboutWindowGeometry; }
    void setAboutWindowGeometry(QRect rect) {
        if(rect != m_aboutWindowGeometry) {
            m_aboutWindowGeometry = rect;
            emit aboutWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool aboutWindowMaximized READ getAboutWindowMaximized WRITE setAboutWindowMaximized NOTIFY aboutWindowMaximizedChanged)
    bool getAboutWindowMaximized() { return m_aboutWindowMaximized; }
    void setAboutWindowMaximized(bool maximized) {
        if(maximized != m_aboutWindowMaximized) {
            m_aboutWindowMaximized = maximized;
            emit aboutWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect imgurWindowGeometry READ getImgurWindowGeometry WRITE setImgurWindowGeometry NOTIFY imgurWindowGeometryChanged)
    QRect getImgurWindowGeometry() { return m_imgurWindowGeometry; }
    void setImgurWindowGeometry(QRect rect) {
        if(rect != m_imgurWindowGeometry) {
            m_imgurWindowGeometry = rect;
            emit imgurWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool imgurWindowMaximized READ getImgurWindowMaximized WRITE setImgurWindowMaximized NOTIFY imgurWindowMaximizedChanged)
    bool getImgurWindowMaximized() { return m_imgurWindowMaximized; }
    void setImgurWindowMaximized(bool maximized) {
        if(maximized != m_imgurWindowMaximized) {
            m_imgurWindowMaximized = maximized;
            emit imgurWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect wallpaperWindowGeometry READ getWallpaperWindowGeometry WRITE setWallpaperWindowGeometry NOTIFY wallpaperWindowGeometryChanged)
    QRect getWallpaperWindowGeometry() { return m_wallpaperWindowGeometry; }
    void setWallpaperWindowGeometry(QRect rect) {
        if(rect != m_wallpaperWindowGeometry) {
            m_wallpaperWindowGeometry = rect;
            emit wallpaperWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool wallpaperWindowMaximized READ getWallpaperWindowMaximized WRITE setWallpaperWindowMaximized NOTIFY wallpaperWindowMaximizedChanged)
    bool getWallpaperWindowMaximized() { return m_wallpaperWindowMaximized; }
    void setWallpaperWindowMaximized(bool maximized) {
        if(maximized != m_wallpaperWindowMaximized) {
            m_wallpaperWindowMaximized = maximized;
            emit wallpaperWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect filterWindowGeometry READ getFilterWindowGeometry WRITE setFilterWindowGeometry NOTIFY filterWindowGeometryChanged)
    QRect getFilterWindowGeometry() { return m_filterWindowGeometry; }
    void setFilterWindowGeometry(QRect rect) {
        if(rect != m_filterWindowGeometry) {
            m_filterWindowGeometry = rect;
            emit filterWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool filterWindowMaximized READ getFilterWindowMaximized WRITE setFilterWindowMaximized NOTIFY filterWindowMaximizedChanged)
    bool getFilterWindowMaximized() { return m_filterWindowMaximized; }
    void setFilterWindowMaximized(bool maximized) {
        if(maximized != m_filterWindowMaximized) {
            m_filterWindowMaximized = maximized;
            emit filterWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect settingsManagerWindowGeometry READ getSettingsManagerWindowGeometry WRITE setSettingsManagerWindowGeometry NOTIFY settingsManagerWindowGeometryChanged)
    QRect getSettingsManagerWindowGeometry() { return m_settingsManagerWindowGeometry; }
    void setSettingsManagerWindowGeometry(QRect rect) {
        if(rect != m_settingsManagerWindowGeometry) {
            m_settingsManagerWindowGeometry = rect;
            emit settingsManagerWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool settingsManagerWindowMaximized READ getSettingsManagerWindowMaximized WRITE setSettingsManagerWindowMaximized NOTIFY settingsManagerWindowMaximizedChanged)
    bool getSettingsManagerWindowMaximized() { return m_settingsManagerWindowMaximized; }
    void setSettingsManagerWindowMaximized(bool maximized) {
        if(maximized != m_settingsManagerWindowMaximized) {
            m_settingsManagerWindowMaximized = maximized;
            emit settingsManagerWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect fileSaveAsWindowGeometry READ getFileSaveAsWindowGeometry WRITE setFileSaveAsWindowGeometry NOTIFY fileSaveAsWindowGeometryChanged)
    QRect getFileSaveAsWindowGeometry() { return m_fileSaveAsWindowGeometry; }
    void setFileSaveAsWindowGeometry(QRect rect) {
        if(rect != m_fileSaveAsWindowGeometry) {
            m_fileSaveAsWindowGeometry = rect;
            emit fileSaveAsWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool fileSaveAsWindowMaximized READ getFileSaveAsWindowMaximized WRITE setFileSaveAsWindowMaximized NOTIFY fileSaveAsWindowMaximizedChanged)
    bool getFileSaveAsWindowMaximized() { return m_fileSaveAsWindowMaximized; }
    void setFileSaveAsWindowMaximized(bool maximized) {
        if(maximized != m_fileSaveAsWindowMaximized) {
            m_fileSaveAsWindowMaximized = maximized;
            emit fileSaveAsWindowMaximizedChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect unavailableWindowGeometry READ getUnavailableWindowGeometry WRITE setUnavailableWindowGeometry NOTIFY unavailableWindowGeometryChanged)
    QRect getUnavailableWindowGeometry() { return m_unavailableWindowGeometry; }
    void setUnavailableWindowGeometry(QRect rect) {
        if(rect != m_unavailableWindowGeometry) {
            m_unavailableWindowGeometry = rect;
            emit unavailableWindowGeometryChanged();
            saveGeometries();
        }
    }

    Q_PROPERTY(bool unavailableWindowMaximized READ getUnavailableWindowMaximized WRITE setUnavailableWindowMaximized NOTIFY unavailableWindowMaximizedChanged)
    bool getUnavailableWindowMaximized() { return m_unavailableWindowMaximized; }
    void setUnavailableWindowMaximized(bool maximized) {
        if(maximized != m_unavailableWindowMaximized) {
            m_unavailableWindowMaximized = maximized;
            emit unavailableWindowMaximizedChanged();
            saveGeometries();
        }
    }

private:
    QRect m_mainWindowGeometry;
    bool m_mainWindowMaximized;

    QRect m_fileDialogWindowGeometry;
    bool m_fileDialogWindowMaximized;

    QRect m_mainMenuWindowGeometry;
    bool m_mainMenuWindowMaximized;

    QRect m_metaDataWindowGeometry;
    bool m_metaDataWindowMaximized;

    QRect m_histogramWindowGeometry;
    bool m_histogramWindowMaximized;

    QRect m_slideshowWindowGeometry;
    bool m_slideshowWindowMaximized;

    QRect m_slideshowControlsWindowGeometry;
    bool m_slideshowControlsWindowMaximized;

    QRect m_fileRenameWindowGeometry;
    bool  m_fileRenameWindowMaximized;

    QRect m_fileDeleteWindowGeometry;
    bool  m_fileDeleteWindowMaximized;

    QRect m_scaleWindowGeometry;
    bool  m_scaleWindowMaximized;

    QRect m_aboutWindowGeometry;
    bool  m_aboutWindowMaximized;

    QRect m_imgurWindowGeometry;
    bool  m_imgurWindowMaximized;

    QRect m_wallpaperWindowGeometry;
    bool  m_wallpaperWindowMaximized;

    QRect m_filterWindowGeometry;
    bool  m_filterWindowMaximized;

    QRect m_settingsManagerWindowGeometry;
    bool  m_settingsManagerWindowMaximized;

    QRect m_fileSaveAsWindowGeometry;
    bool  m_fileSaveAsWindowMaximized;

    QRect m_unavailableWindowGeometry;
    bool  m_unavailableWindowMaximized;

    QSettings *settings;
    PQHandlingExternal handlingExternal;

    void saveGeometries();

private slots:
    void readGeometries();

signals:
    void mainWindowGeometryChanged();
    void mainWindowMaximizedChanged();
    void fileDialogWindowGeometryChanged();
    void fileDialogWindowMaximizedChanged();
    void mainMenuWindowGeometryChanged();
    void mainMenuWindowMaximizedChanged();
    void metaDataWindowGeometryChanged();
    void metaDataWindowMaximizedChanged();
    void histogramWindowGeometryChanged();
    void histogramWindowMaximizedChanged();
    void slideshowWindowGeometryChanged();
    void slideshowWindowMaximizedChanged();
    void slideshowControlsWindowGeometryChanged();
    void slideshowControlsWindowMaximizedChanged();
    void fileRenameWindowGeometryChanged();
    void fileRenameWindowMaximizedChanged();
    void fileDeleteWindowGeometryChanged();
    void fileDeleteWindowMaximizedChanged();
    void scaleWindowGeometryChanged();
    void scaleWindowMaximizedChanged();
    void aboutWindowGeometryChanged();
    void aboutWindowMaximizedChanged();
    void imgurWindowGeometryChanged();
    void imgurWindowMaximizedChanged();
    void wallpaperWindowGeometryChanged();
    void wallpaperWindowMaximizedChanged();
    void filterWindowGeometryChanged();
    void filterWindowMaximizedChanged();
    void settingsManagerWindowGeometryChanged();
    void settingsManagerWindowMaximizedChanged();
    void fileSaveAsWindowGeometryChanged();
    void fileSaveAsWindowMaximizedChanged();
    void unavailableWindowGeometryChanged();
    void unavailableWindowMaximizedChanged();

};

#endif // PQWINDOWGEOMETRY_H
