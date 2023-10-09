#include <QObject>
#include <QMap>

class PQCResolutionCache : public QObject {

    Q_OBJECT

public:
    static PQCResolutionCache& get() {
        static PQCResolutionCache instance;
        return instance;
    }
    ~PQCResolutionCache();

    PQCResolutionCache(PQCResolutionCache const&)     = delete;
    void operator=(PQCResolutionCache const&) = delete;

    Q_INVOKABLE void saveResolution(QString filename, QSize res);
    QSize getResolution(QString filename);

private:
    PQCResolutionCache(QObject *parent = nullptr);

    QString getKey(QString filename);
    QMap<QString,QSize> resolution;

};
