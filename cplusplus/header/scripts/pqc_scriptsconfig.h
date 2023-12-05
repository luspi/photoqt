#ifndef PQCSCRIPTS_H
#define PQCSCRIPTS_H

#include <QObject>
#include <QTranslator>
#include <QQmlEngine>

class PQCScriptsConfig : public QObject {

    Q_OBJECT

public:
    static PQCScriptsConfig& get() {
        static PQCScriptsConfig instance;
        return instance;
    }
    ~PQCScriptsConfig();

    PQCScriptsConfig(PQCScriptsConfig const&)     = delete;
    void operator=(PQCScriptsConfig const&) = delete;

    Q_INVOKABLE static QString getConfigInfo(bool formatHTML = false);
    Q_INVOKABLE static bool exportConfigTo(QString path);
    Q_INVOKABLE static bool importConfigFrom(QString path, bool reloadData = true);
    Q_INVOKABLE QString getLastLoadedImage();
    Q_INVOKABLE void setLastLoadedImage(QString path);
    Q_INVOKABLE void deleteLastLoadedImage();
    Q_INVOKABLE bool amIOnWindows();
    Q_INVOKABLE bool isChromecastEnabled();
    Q_INVOKABLE bool isLocationSupportEnabled();
    Q_INVOKABLE bool isGraphicsMagickSupportEnabled();
    Q_INVOKABLE bool isImageMagickSupportEnabled();
    Q_INVOKABLE bool isPugixmlSupportEnabled();
    Q_INVOKABLE bool isLibRawSupportEnabled();
    Q_INVOKABLE bool isDevILSupportEnabled();
    Q_INVOKABLE bool isFreeImageSupportEnabled();
    Q_INVOKABLE bool isPopplerSupportEnabled();
    Q_INVOKABLE bool isQtAtLeast6_4();
    Q_INVOKABLE bool isMPVSupportEnabled();
    Q_INVOKABLE bool isVideoQtSupportEnabled();
    Q_INVOKABLE QString getVersion();
    Q_INVOKABLE bool isBetaVersion();
    Q_INVOKABLE QStringList getAvailableTranslations();
    Q_INVOKABLE void updateTranslation();

private:
    PQCScriptsConfig();

    QTranslator *trans;
    QString currentTranslation;

};

#endif
