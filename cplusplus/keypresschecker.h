#ifndef PQKEYPRESSCHECKER
#define PQKEYPRESSCHECKER

#include <QObject>
#include <QKeyEvent>
#include <QDateTime>

class PQKeyPressChecker : public QObject {
    Q_OBJECT

    // the actual catching of key events is done in the notify() method of PQSingleInstance
    // this class is used to communicate a key press throughout the application

public:
    static PQKeyPressChecker& get() {
        static PQKeyPressChecker instance;
        return instance;
    }

    PQKeyPressChecker(PQKeyPressChecker const&)    = delete;
    void operator=(PQKeyPressChecker const&) = delete;

private:
    PQKeyPressChecker() { }

signals:
    void receivedKeyPress(int key, int modifiers);

};

#endif // PQKEYPRESSCHECKER
