#ifndef PQCSCRIPTSMETADATA_H
#define PQCSCRIPTSMETADATA_H

#include <QObject>

class PQCScriptsMetaData : public QObject {

    Q_OBJECT

public:
    static PQCScriptsMetaData& get() {
        static PQCScriptsMetaData instance;
        return instance;
    }
    ~PQCScriptsMetaData();

    PQCScriptsMetaData(PQCScriptsMetaData const&)     = delete;
    void operator=(PQCScriptsMetaData const&) = delete;

    QString analyzeDateTimeOriginal(const QString val);
    QString analyzeExposureTime(const QString val);
    QString analyzeFlash(const QString val);
    QString analyzeSceneCaptureType(const QString val);
    QString analyzeFocalLength(const QString val);
    QString analyzeFNumber(const QString val);
    QString analyzeLightSource(const QString val);
    QString analyzeGPS(QString latRef, QString lat, QString lonRef, QString lon);
    QPointF convertGPSToDecimal(QString gpsLatRef, QString gpsLat, QString gpsLonRef, QString gpsLon);

    Q_INVOKABLE QString convertGPSToDecimalForOpenStreetMap(QString gps);

private:
    PQCScriptsMetaData();

};

#endif
