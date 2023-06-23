#ifndef PQCSCRIPTSCRYPT_H
#define PQCSCRIPTSCRYPT_H

#include <QObject>

class PQCScriptsCrypt : public QObject {

    Q_OBJECT

public:
    static PQCScriptsCrypt& get() {
        static PQCScriptsCrypt instance;
        return instance;
    }
    ~PQCScriptsCrypt();

    PQCScriptsCrypt(PQCScriptsCrypt const&)     = delete;
    void operator=(PQCScriptsCrypt const&) = delete;

private:
    PQCScriptsCrypt();

};

#endif
