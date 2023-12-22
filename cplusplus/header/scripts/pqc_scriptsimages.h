#ifndef PQCSCRIPTSIMAGES_H
#define PQCSCRIPTSIMAGES_H

#include <QObject>
#include <QMap>

class PQCScriptsImages : public QObject {

    Q_OBJECT

public:
    static PQCScriptsImages& get() {
        static PQCScriptsImages instance;
        return instance;
    }
    ~PQCScriptsImages();

    PQCScriptsImages(PQCScriptsImages const&)     = delete;
    void operator=(PQCScriptsImages const&) = delete;

    Q_INVOKABLE QSize getCurrentImageResolution(QString filename);
    Q_INVOKABLE bool isItAnimated(QString filename);
    Q_INVOKABLE QString getIconPathFromTheme(QString binary);
    Q_INVOKABLE QString loadImageAndConvertToBase64(QString filename);
    Q_INVOKABLE QStringList listArchiveContent(QString path);
    Q_INVOKABLE QString convertSecondsToPosition(int t);
    Q_INVOKABLE void loadHistogramData(QString filepath, int index);
    void _loadHistogramData(QString filepath, int index);

    Q_INVOKABLE bool isPDFDocument(QString path);
    Q_INVOKABLE bool isArchive(QString path);
    Q_INVOKABLE int getNumberDocumentPages(QString path);
    Q_INVOKABLE int isMotionPhoto(QString path);

    Q_INVOKABLE QString extractMotionPhoto(QString path);

    Q_INVOKABLE bool supportsTransparency(QString path);
    void setSupportsTransparency(QString path, bool alpha);

private:
    PQCScriptsImages();

    QMap<QString,QVariantList> histogramCache;

    QMap<QString, bool> alphaChannels;

Q_SIGNALS:
    void histogramDataLoaded(QVariantList data, int index);
    void histogramDataLoadedFailed(int index);

};

#endif
