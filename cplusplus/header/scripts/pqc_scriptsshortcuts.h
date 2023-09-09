#ifndef PQCSCRIPTSSHORTCUTS_H
#define PQCSCRIPTSSHORTCUTS_H

#include <QObject>
#include <QMap>

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

    Q_INVOKABLE void executeExternal(QString exe, QString args, QString currentfile);
    Q_INVOKABLE QString translateShortcut(QString combo);

private:
    PQCScriptsShortcuts();

    QString getTranslation(QString key);

    QMap<QString,QString> keyStrings;
    QMap<QString,QString> mouseStrings;

};

#endif
