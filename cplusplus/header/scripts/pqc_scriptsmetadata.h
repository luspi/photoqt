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

    Q_INVOKABLE QString analyzeDateTimeOriginal(const QString val);
    Q_INVOKABLE QString analyzeExposureTime(const QString val);
    Q_INVOKABLE QString analyzeFlash(const QString val);
    Q_INVOKABLE QString analyzeSceneCaptureType(const QString val);
    Q_INVOKABLE QString analyzeFocalLength(const QString val);
    Q_INVOKABLE QString analyzeFNumber(const QString val);
    Q_INVOKABLE QString analyzeLightSource(const QString val);
    Q_INVOKABLE QString analyzeGPS(QString latRef, QString lat, QString lonRef, QString lon);
    Q_INVOKABLE QString convertGPSToDecimalForOpenStreetMap(QString gps);
    Q_INVOKABLE QPointF convertGPSToDecimal(QString gpsLatRef, QString gpsLat, QString gpsLonRef, QString gpsLon);

private:
    PQCScriptsMetaData();

};

#endif
