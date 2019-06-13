#ifndef PQWINDOWGEOMETRY_H
#define PQWINDOWGEOMETRY_H

#include <QObject>
#include <QRect>
#include <QSettings>
#include "../logger.h"

class PQWindowGeometry : public QObject {

    Q_OBJECT

public:
    explicit PQWindowGeometry(QObject *parent = 0);

    Q_PROPERTY(QRect mainWindowGeometry READ getMainWindowGeometry WRITE setMainWindowGeometry)
    const QRect getMainWindowGeometry() { return m_mainWindowGeometry; }
    void setMainWindowGeometry(QRect rect) {
        if(rect != m_mainWindowGeometry) {
            m_mainWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool mainWindowMaximized READ getMainWindowMaximized WRITE setMainWindowMaximized)
    bool getMainWindowMaximized() { return m_mainWindowMaximized; }
    void setMainWindowMaximized(bool maximized) {
        if(maximized != m_mainWindowMaximized) {
            m_mainWindowMaximized = maximized;
            saveGeometries();
        }
    }

    Q_PROPERTY(QRect fileDialogWindowGeometry READ getFileDialogWindowGeometry WRITE setFileDialogWindowGeometry)
    QRect getFileDialogWindowGeometry() { return m_fileDialogWindowGeometry; }
    void setFileDialogWindowGeometry(QRect rect) {
        if(rect != m_fileDialogWindowGeometry) {
            m_fileDialogWindowGeometry = rect;
            saveGeometries();
        }
    }

    Q_PROPERTY(bool fileDialogWindowMaximized READ getFileDialogWindowMaximized WRITE setFileDialogWindowMaximized)
    bool getFileDialogWindowMaximized() { return m_fileDialogWindowMaximized; }
    void setFileDialogWindowMaximized(bool maximized) {
        if(maximized != m_fileDialogWindowMaximized) {
            m_fileDialogWindowMaximized = maximized;
            saveGeometries();
        }
    }

private:
    QRect m_mainWindowGeometry;
    bool m_mainWindowMaximized;

    QRect m_fileDialogWindowGeometry;
    bool m_fileDialogWindowMaximized;

    QSettings *settings;

    void saveGeometries();

private slots:
    void readGeometries();

};

#endif // PQWINDOWGEOMETRY_H
