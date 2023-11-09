#ifndef PQCPOPUPGEOMETRY_H
#define PQCPOPUPGEOMETRY_H

#include <QQmlPropertyMap>
#include <QRect>

class QSettings;
class QTimer;

class PQCWindowGeometry : public QQmlPropertyMap {

    Q_OBJECT

public:
    static PQCWindowGeometry& get();
    ~PQCWindowGeometry();

    PQCWindowGeometry(PQCWindowGeometry const&)        = delete;
    void operator=(PQCWindowGeometry const&) = delete;

    QSettings *settings;
    void load();

private Q_SLOTS:
    void save();
    void computeSmallSizeBehavior();

private:
    PQCWindowGeometry();

    QTimer *saveDelay;

    QVariantList allElements;

};

#endif
