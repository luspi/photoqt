#ifndef PQCPOPUPGEOMETRY_H
#define PQCPOPUPGEOMETRY_H

#include <QQmlPropertyMap>
#include <QRect>

class QSettings;
class QTimer;

class PQCPopoutGeometry : public QQmlPropertyMap {

    Q_OBJECT

public:
    static PQCPopoutGeometry& get();
    ~PQCPopoutGeometry();

    PQCPopoutGeometry(PQCPopoutGeometry const&)        = delete;
    void operator=(PQCPopoutGeometry const&) = delete;

    QSettings *settings;
    void load();

private Q_SLOTS:
    void save();
    void computeSmallSizeBehavior();

private:
    PQCPopoutGeometry();

    QTimer *saveDelay;

    QVariantList allElements;

};

#endif
