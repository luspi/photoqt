/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

#include <QObject>
#include <QtDebug>
#include <QQmlEngine>

class QTimer;

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton CANNOT be used from C++.
//            It can ONLY be used from QML.
//
/*************************************************************/
/*************************************************************/

class PQCMetaData : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCMetaData(QObject *parent = 0);

    Q_PROPERTY(bool validFile READ getValidFile WRITE setValidFile NOTIFY validFileChanged)
    bool getValidFile() { return m_validFile; }
    void setValidFile(bool val) {
        if(m_validFile != val) {
            m_validFile = val;
            Q_EMIT validFileChanged();
        }
    }

    Q_PROPERTY(qint64 fileSize READ getFileSize WRITE setFileSize NOTIFY fileSizeChanged)
    qint64 getFileSize() { return m_fileSize; }
    void setFileSize(qint64 val) {
        if(m_fileSize != val) {
            m_fileSize = val;
            Q_EMIT fileSizeChanged();
        }
    }

    Q_PROPERTY(QString exifMake READ getExifMake WRITE setExifMake NOTIFY exifMakeChanged)
    QString getExifMake() { return m_exifMake; }
    void setExifMake(QString val) {
        if(m_exifMake != val) {
            m_exifMake = val;
            Q_EMIT exifMakeChanged();
        }
    }

    Q_PROPERTY(QString exifModel READ getExifModel WRITE setExifModel NOTIFY exifModelChanged)
    QString getExifModel() { return m_exifModel; }
    void setExifModel(QString val) {
        if(m_exifModel != val) {
            m_exifModel = val;
            Q_EMIT exifModelChanged();
        }
    }

    Q_PROPERTY(QString exifSoftware READ getExifSoftware WRITE setExifSoftware NOTIFY exifSoftwareChanged)
    QString getExifSoftware() { return m_exifSoftware; }
    void setExifSoftware(QString val) {
        if(m_exifSoftware != val) {
            m_exifSoftware = val;
            Q_EMIT exifSoftwareChanged();
        }
    }

    Q_PROPERTY(QString exifDateTimeOriginal READ getExifDateTimeOriginal WRITE setExifDateTimeOriginal NOTIFY exifDateTimeOriginalChanged)
    QString getExifDateTimeOriginal() { return m_exifDateTimeOriginal; }
    void setExifDateTimeOriginal(QString val) {
        if(m_exifDateTimeOriginal != val) {
            m_exifDateTimeOriginal = val;
            Q_EMIT exifDateTimeOriginalChanged();
        }
    }

    Q_PROPERTY(QString exifExposureTime READ getExifExposureTime WRITE setExifExposureTime NOTIFY exifExposureTimeChanged)
    QString getExifExposureTime() { return m_exifExposureTime; }
    void setExifExposureTime(QString val) {
        if(m_exifExposureTime != val) {
            m_exifExposureTime = val;
            Q_EMIT exifExposureTimeChanged();
        }
    }

    Q_PROPERTY(QString exifFlash READ getExifFlash WRITE setExifFlash NOTIFY exifFlashChanged)
    QString getExifFlash() { return m_exifFlash; }
    void setExifFlash(QString val) {
        if(m_exifFlash != val) {
            m_exifFlash = val;
            Q_EMIT exifFlashChanged();
        }
    }

    Q_PROPERTY(QString exifISOSpeedRatings READ getExifISOSpeedRatings WRITE setExifISOSpeedRatings NOTIFY exifISOSpeedRatingsChanged)
    QString getExifISOSpeedRatings() { return m_exifISOSpeedRatings; }
    void setExifISOSpeedRatings(QString val) {
        if(m_exifISOSpeedRatings != val) {
            m_exifISOSpeedRatings = val;
            Q_EMIT exifISOSpeedRatingsChanged();
        }
    }

    Q_PROPERTY(QString exifSceneCaptureType READ getExifSceneCaptureType WRITE setExifSceneCaptureType NOTIFY exifSceneCaptureTypeChanged)
    QString getExifSceneCaptureType() { return m_exifSceneCaptureType; }
    void setExifSceneCaptureType(QString val) {
        if(m_exifSceneCaptureType != val) {
            m_exifSceneCaptureType = val;
            Q_EMIT exifSceneCaptureTypeChanged();
        }
    }

    Q_PROPERTY(QString exifFocalLength READ getExifFocalLength WRITE setExifFocalLength NOTIFY exifFocalLengthChanged)
    QString getExifFocalLength() { return m_exifFocalLength; }
    void setExifFocalLength(QString val) {
        if(m_exifFocalLength != val) {
            m_exifFocalLength = val;
            Q_EMIT exifFocalLengthChanged();
        }
    }

    Q_PROPERTY(QString exifFNumber READ getExifFNumber WRITE setExifFNumber NOTIFY exifFNumberChanged)
    QString getExifFNumber() { return m_exifFNumber; }
    void setExifFNumber(QString val) {
        if(m_exifFNumber != val) {
            m_exifFNumber = val;
            Q_EMIT exifFNumberChanged();
        }
    }

    Q_PROPERTY(QString exifLightSource READ getExifLightSource WRITE setExifLightSource NOTIFY exifLightSourceChanged)
    QString getExifLightSource() { return m_exifLightSource; }
    void setExifLightSource(QString val) {
        if(m_exifLightSource != val) {
            m_exifLightSource = val;
            Q_EMIT exifLightSourceChanged();
        }
    }

    Q_PROPERTY(QString exifPixelXDimension READ getExifPixelXDimension WRITE setExifPixelXDimension NOTIFY exifPixelXDimensionChanged)
    QString getExifPixelXDimension() { return m_exifPixelXDimension; }
    void setExifPixelXDimension(QString val) {
        if(m_exifPixelXDimension != val) {
            m_exifPixelXDimension = val;
            Q_EMIT exifPixelXDimensionChanged();
        }
    }

    Q_PROPERTY(QString exifPixelYDimension READ getExifPixelYDimension WRITE setExifPixelYDimension NOTIFY exifPixelYDimensionChanged)
    QString getExifPixelYDimension() { return m_exifPixelYDimension; }
    void setExifPixelYDimension(QString val) {
        if(m_exifPixelYDimension != val) {
            m_exifPixelYDimension = val;
            Q_EMIT exifPixelYDimensionChanged();
        }
    }

    Q_PROPERTY(QString exifGPS READ getExifGPS WRITE setExifGPS NOTIFY exifGPSChanged)
    QString getExifGPS() { return m_exifGPS; }
    void setExifGPS(QString val) {
        if(m_exifGPS != val) {
            m_exifGPS = val;
            Q_EMIT exifGPSChanged();
        }
    }

    Q_PROPERTY(QString iptcKeywords READ getIptcKeywords WRITE setIptcKeywords NOTIFY iptcKeywordsChanged)
    QString getIptcKeywords() { return m_iptcKeywords; }
    void setIptcKeywords(QString val) {
        if(m_iptcKeywords != val) {
            m_iptcKeywords = val;
            Q_EMIT iptcKeywordsChanged();
        }
    }

    Q_PROPERTY(QString iptcLocation READ getIptcLocation WRITE setIptcLocation NOTIFY iptcLocationChanged)
    QString getIptcLocation() { return m_iptcLocation; }
    void setIptcLocation(QString val) {
        if(m_iptcLocation != val) {
            m_iptcLocation = val;
            Q_EMIT iptcLocationChanged();
        }
    }

    Q_PROPERTY(QString iptcCopyright READ getIptcCopyright WRITE setIptcCopyright NOTIFY iptcCopyrightChanged)
    QString getIptcCopyright() { return m_iptcCopyright; }
    void setIptcCopyright(QString val) {
        if(m_iptcCopyright != val) {
            m_iptcCopyright = val;
            Q_EMIT iptcCopyrightChanged();
        }
    }

private:
    QTimer *loadDelay;

    void setEmptyData();

    bool    m_validFile;
    qint64  m_fileSize;

    QString m_exifMake;
    QString m_exifModel;
    QString m_exifSoftware;

    QString m_exifDateTimeOriginal;
    QString m_exifExposureTime;
    QString m_exifFlash;
    QString m_exifISOSpeedRatings;
    QString m_exifSceneCaptureType;
    QString m_exifFocalLength;
    QString m_exifFNumber;
    QString m_exifLightSource;
    QString m_exifPixelXDimension;
    QString m_exifPixelYDimension;

    QString m_exifGPS;

    QString m_iptcKeywords;
    QString m_iptcLocation;
    QString m_iptcCopyright;

private Q_SLOTS:
    void updateMetadata();

Q_SIGNALS:
    void validFileChanged();
    void fileSizeChanged();
    void exifMakeChanged();
    void exifModelChanged();
    void exifSoftwareChanged();
    void exifDateTimeOriginalChanged();
    void exifExposureTimeChanged();
    void exifFlashChanged();
    void exifISOSpeedRatingsChanged();
    void exifSceneCaptureTypeChanged();
    void exifFocalLengthChanged();
    void exifFNumberChanged();
    void exifLightSourceChanged();
    void exifPixelXDimensionChanged();
    void exifPixelYDimensionChanged();
    void exifGPSChanged();
    void iptcKeywordsChanged();
    void iptcLocationChanged();
    void iptcCopyrightChanged();

};
