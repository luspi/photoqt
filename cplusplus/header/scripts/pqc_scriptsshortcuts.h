#ifndef PQCSCRIPTSSHORTCUTS_H
#define PQCSCRIPTSSHORTCUTS_H

#include <QObject>

class PQCScriptsShortcuts : public QObject {

    Q_OBJECT

public:
    static PQCScriptsShortcuts& get() {
        static PQCScriptsShortcuts instance;
        return instance;
    }
    ~PQCScriptsShortcuts();

    PQCScriptsShortcuts(PQCScriptsShortcuts const&)     = delete;
    void operator=(PQCScriptsShortcuts const&) = delete;

private:
    PQCScriptsShortcuts();

};

#endif
