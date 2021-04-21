#ifndef IMAGEWATCHER_H
#define IMAGEWATCHER_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QFileInfo>
#include <thread>

// this class is used by each individual image element to check for changes to the image

class PQImageWatcher : public QObject {

    Q_OBJECT

public:
    PQImageWatcher(QObject *parent = nullptr);
    ~PQImageWatcher();

    Q_PROPERTY(QString imagePath READ getImagePath WRITE setImagePath)
    QString getImagePath() { return m_imagePath; }
    void setImagePath(QString val) {
        if(m_imagePath != val) {
            m_imagePath = val;
            watcher->addPath(m_imagePath);
        }
    }

private:
    QString m_imagePath;
    QFileSystemWatcher *watcher;

private slots:
    void imageChangedSLOT();

signals:
    void imageChanged();
    void imageDeleted();

};



#endif // IMAGEWATCHER_H
