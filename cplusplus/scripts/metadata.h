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
            emit validFileChanged();
        }
    }

    Q_PROPERTY(QString fileSize READ getFileSize WRITE setFileSize NOTIFY fileSizeChanged)
    QString getFileSize() { return m_fileSize; }
    void setFileSize(QString val) {
        if(m_fileSize != val) {
            m_fileSize = val;
            emit fileSizeChanged();
        }
    }

    Q_PROPERTY(QString dimensions READ getDimensions WRITE setDimensions NOTIFY dimensionsChanged)
    QString getDimensions() { return m_dimensions; }
    void setDimensions(QString val) {
        if(m_dimensions != val) {
            m_dimensions = val;
            emit dimensionsChanged();
        }
    }

    Q_PROPERTY(QString exifImageMake READ getExifImageMake WRITE setExifImageMake NOTIFY exifImageMakeChanged)
    QString getExifImageMake() { return m_exifImageMake; }
    void setExifImageMake(QString val) {
        if(m_exifImageMake != val) {
            m_exifImageMake = val;
            emit exifImageMakeChanged();
        }
    }

    Q_PROPERTY(QString exifImageModel READ getExifImageModel WRITE setExifImageModel NOTIFY exifImageModelChanged)
    QString getExifImageModel() { return m_exifImageModel; }
    void setExifImageModel(QString val) {
        if(m_exifImageModel != val) {
            m_exifImageModel = val;
            emit exifImageModelChanged();
        }
    }

    Q_PROPERTY(QString exifImageSoftware READ getExifImageSoftware WRITE setExifImageSoftware NOTIFY exifImageSoftwareChanged)
    QString getExifImageSoftware() { return m_exifImageSoftware; }
    void setExifImageSoftware(QString val) {
        if(m_exifImageSoftware != val) {
            m_exifImageSoftware = val;
            emit exifImageSoftwareChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoDateTimeOriginal READ getExifPhotoDateTimeOriginal WRITE setExifPhotoDateTimeOriginal NOTIFY exifPhotoDateTimeOriginalChanged)
    QString getExifPhotoDateTimeOriginal() { return m_exifPhotoDateTimeOriginal; }
    void setExifPhotoDateTimeOriginal(QString val) {
        if(m_exifPhotoDateTimeOriginal != val) {
            m_exifPhotoDateTimeOriginal = val;
            emit exifPhotoDateTimeOriginalChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoExposureTime READ getExifPhotoExposureTime WRITE setExifPhotoExposureTime NOTIFY exifPhotoExposureTimeChanged)
    QString getExifPhotoExposureTime() { return m_exifPhotoExposureTime; }
    void setExifPhotoExposureTime(QString val) {
        if(m_exifPhotoExposureTime != val) {
            m_exifPhotoExposureTime = val;
            emit exifPhotoExposureTimeChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoFlash READ getExifPhotoFlash WRITE setExifPhotoFlash NOTIFY exifPhotoFlashChanged)
    QString getExifPhotoFlash() { return m_exifPhotoFlash; }
    void setExifPhotoFlash(QString val) {
        if(m_exifPhotoFlash != val) {
            m_exifPhotoFlash = val;
            emit exifPhotoFlashChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoISOSpeedRatings READ getExifPhotoISOSpeedRatings WRITE setExifPhotoISOSpeedRatings NOTIFY exifPhotoISOSpeedRatingsChanged)
    QString getExifPhotoISOSpeedRatings() { return m_exifPhotoISOSpeedRatings; }
    void setExifPhotoISOSpeedRatings(QString val) {
        if(m_exifPhotoISOSpeedRatings != val) {
            m_exifPhotoISOSpeedRatings = val;
            emit exifPhotoISOSpeedRatingsChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoSceneCaptureType READ getExifPhotoSceneCaptureType WRITE setExifPhotoSceneCaptureType NOTIFY exifPhotoSceneCaptureTypeChanged)
    QString getExifPhotoSceneCaptureType() { return m_exifPhotoSceneCaptureType; }
    void setExifPhotoSceneCaptureType(QString val) {
        if(m_exifPhotoSceneCaptureType != val) {
            m_exifPhotoSceneCaptureType = val;
            emit exifPhotoSceneCaptureTypeChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoFocalLength READ getExifPhotoFocalLength WRITE setExifPhotoFocalLength NOTIFY exifPhotoFocalLengthChanged)
    QString getExifPhotoFocalLength() { return m_exifPhotoFocalLength; }
    void setExifPhotoFocalLength(QString val) {
        if(m_exifPhotoFocalLength != val) {
            m_exifPhotoFocalLength = val;
            emit exifPhotoFocalLengthChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoFNumber READ getExifPhotoFNumber WRITE setExifPhotoFNumber NOTIFY exifPhotoFNumberChanged)
    QString getExifPhotoFNumber() { return m_exifPhotoFNumber; }
    void setExifPhotoFNumber(QString val) {
        if(m_exifPhotoFNumber != val) {
            m_exifPhotoFNumber = val;
            emit exifPhotoFNumberChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoLightSource READ getExifPhotoLightSource WRITE setExifPhotoLightSource NOTIFY exifPhotoLightSourceChanged)
    QString getExifPhotoLightSource() { return m_exifPhotoLightSource; }
    void setExifPhotoLightSource(QString val) {
        if(m_exifPhotoLightSource != val) {
            m_exifPhotoLightSource = val;
            emit exifPhotoLightSourceChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoPixelXDimension READ getExifPhotoPixelXDimension WRITE setExifPhotoPixelXDimension NOTIFY exifPhotoPixelXDimensionChanged)
    QString getExifPhotoPixelXDimension() { return m_exifPhotoPixelXDimension; }
    void setExifPhotoPixelXDimension(QString val) {
        if(m_exifPhotoPixelXDimension != val) {
            m_exifPhotoPixelXDimension = val;
            emit exifPhotoPixelXDimensionChanged();
        }
    }

    Q_PROPERTY(QString exifPhotoPixelYDimension READ getExifPhotoPixelYDimension WRITE setExifPhotoPixelYDimension NOTIFY exifPhotoPixelYDimensionChanged)
    QString getExifPhotoPixelYDimension() { return m_exifPhotoPixelYDimension; }
    void setExifPhotoPixelYDimension(QString val) {
        if(m_exifPhotoPixelYDimension != val) {
            m_exifPhotoPixelYDimension = val;
            emit exifPhotoPixelYDimensionChanged();
        }
    }

    Q_PROPERTY(QString exifGPS READ getExifGPS WRITE setExifGPS NOTIFY exifGPSChanged)
    QString getExifGPS() { return m_exifGPS; }
    void setExifGPS(QString val) {
        if(m_exifGPS != val) {
            m_exifGPS = val;
            emit exifGPSChanged();
        }
    }

    Q_PROPERTY(QString iptcApplication2Keywords READ getIptcApplication2Keywords WRITE setIptcApplication2Keywords NOTIFY iptcApplication2KeywordsChanged)
    QString getIptcApplication2Keywords() { return m_iptcApplication2Keywords; }
    void setIptcApplication2Keywords(QString val) {
        if(m_iptcApplication2Keywords != val) {
            m_iptcApplication2Keywords = val;
            emit iptcApplication2KeywordsChanged();
        }
    }

    Q_PROPERTY(QString iptcLocation READ getIptcLocation WRITE setIptcLocation NOTIFY iptcLocationChanged)
    QString getIptcLocation() { return m_iptcLocation; }
    void setIptcLocation(QString val) {
        if(m_iptcLocation != val) {
            m_iptcLocation = val;
            emit iptcLocationChanged();
        }
    }

    Q_PROPERTY(QString iptcApplication2Copyright READ getIptcApplication2Copyright WRITE setIptcApplication2Copyright NOTIFY iptcApplication2CopyrightChanged)
    QString getIptcApplication2Copyright() { return m_iptcApplication2Copyright; }
    void setIptcApplication2Copyright(QString val) {
        if(m_iptcApplication2Copyright != val) {
            m_iptcApplication2Copyright = val;
            emit iptcApplication2CopyrightChanged();
        }
    }

private:
    bool    m_validFile;
    QString m_fileSize;
    QString m_dimensions;

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

signals:
    void validFileChanged();
    void fileSizeChanged();
    void dimensionsChanged();
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
