#ifndef PQCSCRIPTSCHROMECAST_H
#define PQCSCRIPTSCHROMECAST_H

#include <QObject>

class PQCLocalHttpServer;
class QProcess;

class PQCScriptsChromeCast : public QObject {

    Q_OBJECT

public:
    static PQCScriptsChromeCast& get() {
        static PQCScriptsChromeCast instance;
        return instance;
    }
    ~PQCScriptsChromeCast();

    PQCScriptsChromeCast(PQCScriptsChromeCast const&)     = delete;
    void operator=(PQCScriptsChromeCast const&) = delete;

    Q_PROPERTY(QVariantList availableDevices READ getAvailableDevices WRITE setAvailableDevices NOTIFY availableDevicesChanged)
    void setAvailableDevices(QVariantList val);
    QVariantList getAvailableDevices();

    Q_PROPERTY(QString curDeviceName READ getCurDeviceName WRITE setCurDeviceName NOTIFY curDeviceNameChanged)
    void setCurDeviceName(QString val);
    QString getCurDeviceName();

    Q_PROPERTY(bool inDiscovery READ getInDiscovery WRITE setInDiscovery NOTIFY inDiscoveryChanged)
    int getInDiscovery();
    void setInDiscovery(bool val);

    Q_PROPERTY(bool connected READ getConnected WRITE setConnected NOTIFY connectedChanged)
    int getConnected();
    void setConnected(bool val);

    Q_INVOKABLE bool startDiscovery();
    Q_INVOKABLE bool connectToDevice(int deviceId);
    Q_INVOKABLE bool castImage(QString filename);
    Q_INVOKABLE bool disconnect();

private:
    PQCScriptsChromeCast();

    QProcess *procDiscovery;
    QProcess *procCast;
    QProcess *procDisconnect;

    QVariantList m_availableDevices;
    int m_selectedDevice;
    bool m_inDiscovery;
    bool m_connected;

    QString m_curDeviceName;

    PQCLocalHttpServer *server;
    int serverPort;
    QString localIP;

private Q_SLOTS:
    void readDiscoveryOutput();

Q_SIGNALS:
    void availableDevicesChanged();
    void selectedDeviceChanged();
    void inDiscoveryChanged();
    void connectedChanged();
    void curDeviceNameChanged();

};

#endif
