#ifndef PQCTESTSCRIPTSFILESPATHS_H
#define PQCTESTSCRIPTSFILESPATHS_H

#include <QTest>

class PQCTESTScriptsFilesPaths : public QObject {

    Q_OBJECT

private Q_SLOTS:
    void cleanPath_data();
    void cleanPath();

    void win_cleanPath_data();
    void win_cleanPath();

    void getSuffix_data();
    void getSuffix();

    void getFoldersIn();

};

#endif // PQCTESTSCRIPTSFILESPATHS_H
