#ifndef PQCSCRIPTSCLIPBOARD_H
#define PQCSCRIPTSCLIPBOARD_H

#include <QObject>

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

private:
    PQCScriptsClipboard();

};

#endif
