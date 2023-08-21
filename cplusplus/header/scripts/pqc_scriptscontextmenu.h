#ifndef PQCSCRIPTSCONTEXTMENU_H
#define PQCSCRIPTSCONTEXTMENU_H

#include <QSqlDatabase>
#include <QObject>

class PQCScriptsContextMenu : public QObject {

    Q_OBJECT

public:
    static PQCScriptsContextMenu& get() {
        static PQCScriptsContextMenu instance;
        return instance;
    }
    ~PQCScriptsContextMenu();

    PQCScriptsContextMenu(PQCScriptsContextMenu const&)     = delete;
    void operator=(PQCScriptsContextMenu const&) = delete;

    Q_INVOKABLE QVariantList getEntries();

private:
    PQCScriptsContextMenu();

    QSqlDatabase db;

};

#endif
