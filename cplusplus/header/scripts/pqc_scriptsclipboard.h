#ifndef PQCSCRIPTSCLIPBOARD_H
#define PQCSCRIPTSCLIPBOARD_H

#include <QObject>

class QClipboard;

class PQCScriptsClipboard : public QObject {

    Q_OBJECT

public:
    static PQCScriptsClipboard& get() {
        static PQCScriptsClipboard instance;
        return instance;
    }
    ~PQCScriptsClipboard();

    PQCScriptsClipboard(PQCScriptsClipboard const&)     = delete;
    void operator=(PQCScriptsClipboard const&) = delete;

    Q_INVOKABLE bool areFilesInClipboard();
    Q_INVOKABLE void copyFilesToClipboard(QStringList files);
    Q_INVOKABLE QStringList getListOfFilesInClipboard();

private:
    PQCScriptsClipboard();

    QClipboard *clipboard;

Q_SIGNALS:
    void clipboardUpdated();

};

#endif
