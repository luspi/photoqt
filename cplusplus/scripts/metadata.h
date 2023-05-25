/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#ifndef PQMETADATA_H
#define PQMETADATA_H

#include <QObject>
#include <QFileInfo>
#include <QImageReader>
#include "../logger.h"
#ifdef EXIV2
#include <exiv2/exiv2.hpp>
#endif

class PQMetaData : public QObject {

    Q_OBJECT

public:
    PQMetaData(QObject *parent = 0);

    Q_INVOKABLE void updateMetadata(QString path);

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

    Q_PROPERTY(QString exifImageMake READ getExifImageMake WRITE setExifImageMake NOTIFY exifImageMakeChanged)
    QString getExifImageMake() { return m_exifImageMake; }
    void setExifImageMake(QString val) {
        if(m_exifImageMake != val) {
            m_exifImageMake = val;
            Q_EMIT exifImageMakeChanged();
        }
    }

    Q_PROPERTY(QString exifImageModel READ getExifImageModel WRITE setExifImageModel NOTIFY exifImageModelChanged)
    QString getExifImageModel() { return m_exifImageModel; }
    void setExifImageModel(QString val) {
        if(m_exifImageModel != val) {
            m_exifImageModel = val;
            Q_EMIT exifImageModelChanged();
        }
    }

    Q_PROPERTY(QString exifImageSoftware READ getExifImageSoftware WRITE setExifImageSoftware NOTIFY exifImageSoftwareChanged)
    QString getExifImageSoftware() { return m_exifImageSoftware; }
    void setExifImageSoftware(QString val) {
        if(m_exifImageSoftware != val) {
            m_exifImageSoftware = val;
            Q_EMIT exifImageSoftwareChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoDateTimeOriginal READ getExifPhotoDateTimeOriginal WRITE setExifPhotoDateTimeOriginal NOTIFY exifPhotoDateTimeOriginalChanged)
    QString getExifPhotoDateTimeOriginal() { return m_exifPhotoDateTimeOriginal; }
    void setExifPhotoDateTimeOriginal(QString val) {
        if(m_exifPhotoDateTimeOriginal != val) {
            m_exifPhotoDateTimeOriginal = val;
            Q_EMIT exifPhotoDateTimeOriginalChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoExposureTime READ getExifPhotoExposureTime WRITE setExifPhotoExposureTime NOTIFY exifPhotoExposureTimeChanged)
    QString getExifPhotoExposureTime() { return m_exifPhotoExposureTime; }
    void setExifPhotoExposureTime(QString val) {
        if(m_exifPhotoExposureTime != val) {
            m_exifPhotoExposureTime = val;
            Q_EMIT exifPhotoExposureTimeChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoFlash READ getExifPhotoFlash WRITE setExifPhotoFlash NOTIFY exifPhotoFlashChanged)
    QString getExifPhotoFlash() { return m_exifPhotoFlash; }
    void setExifPhotoFlash(QString val) {
        if(m_exifPhotoFlash != val) {
            m_exifPhotoFlash = val;
            Q_EMIT exifPhotoFlashChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoISOSpeedRatings READ getExifPhotoISOSpeedRatings WRITE setExifPhotoISOSpeedRatings NOTIFY exifPhotoISOSpeedRatingsChanged)
    QString getExifPhotoISOSpeedRatings() { return m_exifPhotoISOSpeedRatings; }
    void setExifPhotoISOSpeedRatings(QString val) {
        if(m_exifPhotoISOSpeedRatings != val) {
            m_exifPhotoISOSpeedRatings = val;
            Q_EMIT exifPhotoISOSpeedRatingsChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoSceneCaptureType READ getExifPhotoSceneCaptureType WRITE setExifPhotoSceneCaptureType NOTIFY exifPhotoSceneCaptureTypeChanged)
    QString getExifPhotoSceneCaptureType() { return m_exifPhotoSceneCaptureType; }
    void setExifPhotoSceneCaptureType(QString val) {
        if(m_exifPhotoSceneCaptureType != val) {
            m_exifPhotoSceneCaptureType = val;
            Q_EMIT exifPhotoSceneCaptureTypeChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoFocalLength READ getExifPhotoFocalLength WRITE setExifPhotoFocalLength NOTIFY exifPhotoFocalLengthChanged)
    QString getExifPhotoFocalLength() { return m_exifPhotoFocalLength; }
    void setExifPhotoFocalLength(QString val) {
        if(m_exifPhotoFocalLength != val) {
            m_exifPhotoFocalLength = val;
            Q_EMIT exifPhotoFocalLengthChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoFNumber READ getExifPhotoFNumber WRITE setExifPhotoFNumber NOTIFY exifPhotoFNumberChanged)
    QString getExifPhotoFNumber() { return m_exifPhotoFNumber; }
    void setExifPhotoFNumber(QString val) {
        if(m_exifPhotoFNumber != val) {
            m_exifPhotoFNumber = val;
            Q_EMIT exifPhotoFNumberChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoLightSource READ getExifPhotoLightSource WRITE setExifPhotoLightSource NOTIFY exifPhotoLightSourceChanged)
    QString getExifPhotoLightSource() { return m_exifPhotoLightSource; }
    void setExifPhotoLightSource(QString val) {
        if(m_exifPhotoLightSource != val) {
            m_exifPhotoLightSource = val;
            Q_EMIT exifPhotoLightSourceChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoPixelXDimension READ getExifPhotoPixelXDimension WRITE setExifPhotoPixelXDimension NOTIFY exifPhotoPixelXDimensionChanged)
    QString getExifPhotoPixelXDimension() { return m_exifPhotoPixelXDimension; }
    void setExifPhotoPixelXDimension(QString val) {
        if(m_exifPhotoPixelXDimension != val) {
            m_exifPhotoPixelXDimension = val;
            Q_EMIT exifPhotoPixelXDimensionChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoPixelYDimension READ getExifPhotoPixelYDimension WRITE setExifPhotoPixelYDimension NOTIFY exifPhotoPixelYDimensionChanged)
    QString getExifPhotoPixelYDimension() { return m_exifPhotoPixelYDimension; }
    void setExifPhotoPixelYDimension(QString val) {
        if(m_exifPhotoPixelYDimension != val) {
            m_exifPhotoPixelYDimension = val;
            Q_EMIT exifPhotoPixelYDimensionChanged();
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

    Q_PROPERTY(QString iptcApplication2Keywords READ getIptcApplication2Keywords WRITE setIptcApplication2Keywords NOTIFY iptcApplication2KeywordsChanged)
    QString getIptcApplication2Keywords() { return m_iptcApplication2Keywords; }
    void setIptcApplication2Keywords(QString val) {
        if(m_iptcApplication2Keywords != val) {
            m_iptcApplication2Keywords = val;
            Q_EMIT iptcApplication2KeywordsChanged();
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

    Q_PROPERTY(QString iptcApplication2Copyright READ getIptcApplication2Copyright WRITE setIptcApplication2Copyright NOTIFY iptcApplication2CopyrightChanged)
    QString getIptcApplication2Copyright() { return m_iptcApplication2Copyright; }
    void setIptcApplication2Copyright(QString val) {
        if(m_iptcApplication2Copyright != val) {
            m_iptcApplication2Copyright = val;
            Q_EMIT iptcApplication2CopyrightChanged();
        }
    }

    Q_INVOKABLE QPointF getGPSDataOnly(QString fname);

private:

    void setEmptyExivData();

    bool    m_validFile;
    qint64  m_fileSize;

    QString m_exifImageMake;
    QString m_exifImageModel;
    QString m_exifImageSoftware;

    QString m_exifPhotoDateTimeOriginal;
    QString m_exifPhotoExposureTime;
    QString m_exifPhotoFlash;
    QString m_exifPhotoISOSpeedRatings;
    QString m_exifPhotoSceneCaptureType;
    QString m_exifPhotoFocalLength;
    QString m_exifPhotoFNumber;
    QString m_exifPhotoLightSource;
    QString m_exifPhotoPixelXDimension;
    QString m_exifPhotoPixelYDimension;

    QString m_exifGPS;

    QString m_iptcApplication2Keywords;
    QString m_iptcLocation;
    QString m_iptcApplication2Copyright;

    QString analyzeDateTimeOriginal(const QString val);
    QString analyzeExposureTime(const QString val);
    QString analyzeFlash(const QString val);
    QString analyzeSceneCaptureType(const QString val);
    QString analyzeFocalLength(const QString val);
    QString analyzeFNumber(const QString val);
    QString analyzeLightSource(const QString val);
    QString analyzeGPS(QString latRef, QString lat, QString lonRef, QString lon);
    QPointF convertGPSToDecimal(QString gpsLatRef, QString gpsLat, QString gpsLonRef, QString gpsLon);

Q_SIGNALS:
    void validFileChanged();
    void fileSizeChanged();
    void exifImageMakeChanged();
    void exifImageModelChanged();
    void exifImageSoftwareChanged();
    void exifPhotoDateTimeOriginalChanged();
    void exifPhotoExposureTimeChanged();
    void exifPhotoFlashChanged();
    void exifPhotoISOSpeedRatingsChanged();
    void exifPhotoSceneCaptureTypeChanged();
    void exifPhotoFocalLengthChanged();
    void exifPhotoFNumberChanged();
    void exifPhotoLightSourceChanged();
    void exifPhotoPixelXDimensionChanged();
    void exifPhotoPixelYDimensionChanged();
    void exifGPSChanged();
    void iptcApplication2KeywordsChanged();
    void iptcLocationChanged();
    void iptcApplication2CopyrightChanged();

};


#endif // PQMETADATA_H
