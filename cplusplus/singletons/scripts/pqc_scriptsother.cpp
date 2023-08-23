#include <scripts/pqc_scriptsother.h>
#include <QMessageBox>
#include <QDateTime>
#include <QApplication>
#include <QScreen>
#include <QDir>

PQCScriptsOther::PQCScriptsOther() {}

PQCScriptsOther::~PQCScriptsOther() {}

qint64 PQCScriptsOther::getTimestamp() {
    return QDateTime::currentMSecsSinceEpoch();
}

void PQCScriptsOther::takeScreenshots() {
    qDebug() << "";
    for(int i = 0; i < QApplication::screens().count(); ++i) {
        QScreen *screen = QApplication::screens().at(i);
        QRect r = screen->geometry();
        QPixmap pix = screen->grabWindow(0,r.x(),r.y(),r.width(),r.height());
        if(!pix.save(QDir::tempPath() + QString("/photoqt_screenshot_%1.jpg").arg(i)))
            qWarning() << "Error taking screenshot for screen #" << i;
    }
}

void PQCScriptsOther::deleteScreenshots() {
    qDebug() << "";
    int count = 0;
    while(true) {
        QFile file(QDir::tempPath() + QString("/photoqt_screenshot_%1.jpg").arg(count));
        if(file.exists())
            file.remove();
        else
            break;
    }
}
