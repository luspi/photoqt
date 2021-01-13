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
#include <QGuiApplication>
#include <QScreen>
#include "../logger.h"

class PQWindowGeometry : public QObject {

    Q_OBJECT

public:
    explicit PQWindowGeometry(QObject *parent = 0);

    Q_PROPERTY(QRect mainWindowGeometry READ getMainWindowGeometry WRITE setMainWindowGeometry)
    const QRect getMainWindowGeometry() { return m_mainWindowGeometry; }
    void setMainWindowGeometry(QRect rect) {
        if(rect != m_mainWindowGeometry) {
            m_mainWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool mainWindowMaximized READ getMainWindowMaximized WRITE setMainWindowMaximized)
    bool getMainWindowMaximized() { return m_mainWindowMaximized; }
    void setMainWindowMaximized(bool maximized) {
        if(maximized != m_mainWindowMaximized) {
            m_mainWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect fileDialogWindowGeometry READ getFileDialogWindowGeometry WRITE setFileDialogWindowGeometry)
    QRect getFileDialogWindowGeometry() { return m_fileDialogWindowGeometry; }
    void setFileDialogWindowGeometry(QRect rect) {
        if(rect != m_fileDialogWindowGeometry) {
            m_fileDialogWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool fileDialogWindowMaximized READ getFileDialogWindowMaximized WRITE setFileDialogWindowMaximized)
    bool getFileDialogWindowMaximized() { return m_fileDialogWindowMaximized; }
    void setFileDialogWindowMaximized(bool maximized) {
        if(maximized != m_fileDialogWindowMaximized) {
            m_fileDialogWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect mainMenuWindowGeometry READ getMainMenuWindowGeometry WRITE setMainMenuWindowGeometry)
    QRect getMainMenuWindowGeometry() { return m_mainMenuWindowGeometry; }
    void setMainMenuWindowGeometry(QRect rect) {
        if(rect != m_mainMenuWindowGeometry) {
            m_mainMenuWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool mainMenuWindowMaximized READ getMainMenuWindowMaximized WRITE setMainMenuWindowMaximized)
    bool getMainMenuWindowMaximized() { return m_mainMenuWindowMaximized; }
    void setMainMenuWindowMaximized(bool maximized) {
        if(maximized != m_mainMenuWindowMaximized) {
            m_mainMenuWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect metaDataWindowGeometry READ getMetaDataWindowGeometry WRITE setMetaDataWindowGeometry)
    QRect getMetaDataWindowGeometry() { return m_metaDataWindowGeometry; }
    void setMetaDataWindowGeometry(QRect rect) {
        if(rect != m_metaDataWindowGeometry) {
            m_metaDataWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool metaDataWindowMaximized READ getMetaDataWindowMaximized WRITE setMetaDataWindowMaximized)
    bool getMetaDataWindowMaximized() { return m_metaDataWindowMaximized; }
    void setMetaDataWindowMaximized(bool maximized) {
        if(maximized != m_metaDataWindowMaximized) {
            m_metaDataWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect histogramWindowGeometry READ getHistogramWindowGeometry WRITE setHistogramWindowGeometry)
    QRect getHistogramWindowGeometry() { return m_histogramWindowGeometry; }
    void setHistogramWindowGeometry(QRect rect) {
        if(rect != m_histogramWindowGeometry) {
            m_histogramWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool histogramWindowMaximized READ getHistogramWindowMaximized WRITE setHistogramWindowMaximized)
    bool getHistogramWindowMaximized() { return m_histogramWindowMaximized; }
    void setHistogramWindowMaximized(bool maximized) {
        if(maximized != m_histogramWindowMaximized) {
            m_histogramWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect slideshowWindowGeometry READ getSlideshowWindowGeometry WRITE setSlideshowWindowGeometry)
    QRect getSlideshowWindowGeometry() { return m_slideshowWindowGeometry; }
    void setSlideshowWindowGeometry(QRect rect) {
        if(rect != m_slideshowWindowGeometry) {
            m_slideshowWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool slideshowWindowMaximized READ getSlideshowWindowMaximized WRITE setSlideshowWindowMaximized)
    bool getSlideshowWindowMaximized() { return m_slideshowWindowMaximized; }
    void setSlideshowWindowMaximized(bool maximized) {
        if(maximized != m_slideshowWindowMaximized) {
            m_slideshowWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect slideshowControlsWindowGeometry READ getSlideshowControlsWindowGeometry WRITE setSlideshowControlsWindowGeometry)
    QRect getSlideshowControlsWindowGeometry() { return m_slideshowControlsWindowGeometry; }
    void setSlideshowControlsWindowGeometry(QRect rect) {
        if(rect != m_slideshowControlsWindowGeometry) {
            m_slideshowControlsWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool slideshowControlsWindowMaximized READ getSlideshowControlsWindowMaximized WRITE setSlideshowControlsWindowMaximized)
    bool getSlideshowControlsWindowMaximized() { return m_slideshowControlsWindowMaximized; }
    void setSlideshowControlsWindowMaximized(bool maximized) {
        if(maximized != m_slideshowControlsWindowMaximized) {
            m_slideshowControlsWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect fileRenameWindowGeometry READ getFileRenameWindowGeometry WRITE setFileRenameWindowGeometry)
    QRect getFileRenameWindowGeometry() { return m_fileRenameWindowGeometry; }
    void setFileRenameWindowGeometry(QRect rect) {
        if(rect != m_fileRenameWindowGeometry) {
            m_fileRenameWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool fileRenameWindowMaximized READ getFileRenameWindowMaximized WRITE setFileRenameWindowMaximized)
    bool getFileRenameWindowMaximized() { return m_fileRenameWindowMaximized; }
    void setFileRenameWindowMaximized(bool maximized) {
        if(maximized != m_fileRenameWindowMaximized) {
            m_fileRenameWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect fileDeleteWindowGeometry READ getFileDeleteWindowGeometry WRITE setFileDeleteWindowGeometry)
    QRect getFileDeleteWindowGeometry() { return m_fileDeleteWindowGeometry; }
    void setFileDeleteWindowGeometry(QRect rect) {
        if(rect != m_fileDeleteWindowGeometry) {
            m_fileDeleteWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool fileDeleteWindowMaximized READ getFileDeleteWindowMaximized WRITE setFileDeleteWindowMaximized)
    bool getFileDeleteWindowMaximized() { return m_fileDeleteWindowMaximized; }
    void setFileDeleteWindowMaximized(bool maximized) {
        if(maximized != m_fileDeleteWindowMaximized) {
            m_fileDeleteWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect scaleWindowGeometry READ getScaleWindowGeometry WRITE setScaleWindowGeometry)
    QRect getScaleWindowGeometry() { return m_scaleWindowGeometry; }
    void setScaleWindowGeometry(QRect rect) {
        if(rect != m_scaleWindowGeometry) {
            m_scaleWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool scaleWindowMaximized READ getScaleWindowMaximized WRITE setScaleWindowMaximized)
    bool getScaleWindowMaximized() { return m_scaleWindowMaximized; }
    void setScaleWindowMaximized(bool maximized) {
        if(maximized != m_scaleWindowMaximized) {
            m_scaleWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect aboutWindowGeometry READ getAboutWindowGeometry WRITE setAboutWindowGeometry)
    QRect getAboutWindowGeometry() { return m_aboutWindowGeometry; }
    void setAboutWindowGeometry(QRect rect) {
        if(rect != m_aboutWindowGeometry) {
            m_aboutWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool aboutWindowMaximized READ getAboutWindowMaximized WRITE setAboutWindowMaximized)
    bool getAboutWindowMaximized() { return m_aboutWindowMaximized; }
    void setAboutWindowMaximized(bool maximized) {
        if(maximized != m_aboutWindowMaximized) {
            m_aboutWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect imgurWindowGeometry READ getImgurWindowGeometry WRITE setImgurWindowGeometry)
    QRect getImgurWindowGeometry() { return m_imgurWindowGeometry; }
    void setImgurWindowGeometry(QRect rect) {
        if(rect != m_imgurWindowGeometry) {
            m_imgurWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool imgurWindowMaximized READ getImgurWindowMaximized WRITE setImgurWindowMaximized)
    bool getImgurWindowMaximized() { return m_imgurWindowMaximized; }
    void setImgurWindowMaximized(bool maximized) {
        if(maximized != m_imgurWindowMaximized) {
            m_imgurWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect wallpaperWindowGeometry READ getWallpaperWindowGeometry WRITE setWallpaperWindowGeometry)
    QRect getWallpaperWindowGeometry() { return m_wallpaperWindowGeometry; }
    void setWallpaperWindowGeometry(QRect rect) {
        if(rect != m_wallpaperWindowGeometry) {
            m_wallpaperWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool wallpaperWindowMaximized READ getWallpaperWindowMaximized WRITE setWallpaperWindowMaximized)
    bool getWallpaperWindowMaximized() { return m_wallpaperWindowMaximized; }
    void setWallpaperWindowMaximized(bool maximized) {
        if(maximized != m_wallpaperWindowMaximized) {
            m_wallpaperWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect filterWindowGeometry READ getFilterWindowGeometry WRITE setFilterWindowGeometry)
    QRect getFilterWindowGeometry() { return m_filterWindowGeometry; }
    void setFilterWindowGeometry(QRect rect) {
        if(rect != m_filterWindowGeometry) {
            m_filterWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool filterWindowMaximized READ getFilterWindowMaximized WRITE setFilterWindowMaximized)
    bool getFilterWindowMaximized() { return m_filterWindowMaximized; }
    void setFilterWindowMaximized(bool maximized) {
        if(maximized != m_filterWindowMaximized) {
            m_filterWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect settingsManagerWindowGeometry READ getSettingsManagerWindowGeometry WRITE setSettingsManagerWindowGeometry)
    QRect getSettingsManagerWindowGeometry() { return m_settingsManagerWindowGeometry; }
    void setSettingsManagerWindowGeometry(QRect rect) {
        if(rect != m_settingsManagerWindowGeometry) {
            m_settingsManagerWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool settingsManagerWindowMaximized READ getSettingsManagerWindowMaximized WRITE setSettingsManagerWindowMaximized)
    bool getSettingsManagerWindowMaximized() { return m_settingsManagerWindowMaximized; }
    void setSettingsManagerWindowMaximized(bool maximized) {
        if(maximized != m_settingsManagerWindowMaximized) {
            m_settingsManagerWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect fileSaveAsWindowGeometry READ getFileSaveAsWindowGeometry WRITE setFileSaveAsWindowGeometry)
    QRect getFileSaveAsWindowGeometry() { return m_fileSaveAsWindowGeometry; }
    void setFileSaveAsWindowGeometry(QRect rect) {
        if(rect != m_fileSaveAsWindowGeometry) {
            m_fileSaveAsWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool fileSaveAsWindowMaximized READ getFileSaveAsWindowMaximized WRITE setFileSaveAsWindowMaximized)
    bool getFileSaveAsWindowMaximized() { return m_fileSaveAsWindowMaximized; }
    void setFileSaveAsWindowMaximized(bool maximized) {
        if(maximized != m_fileSaveAsWindowMaximized) {
            m_fileSaveAsWindowMaximized = maximized;
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

    QSettings *settings;

    void saveGeometries();

private slots:
    void readGeometries();

};

#endif // PQWINDOWGEOMETRY_H
