#include <QObject>
#include <QKeyEvent>
#include <QDateTime>

class PQKeyPressChecker : public QObject {
    Q_OBJECT

public:
    static PQKeyPressChecker& get() {
        static PQKeyPressChecker instance;
        return instance;
    }

    PQKeyPressChecker(PQKeyPressChecker const&)    = delete;
    void operator=(PQKeyPressChecker const&) = delete;

protected:
    bool eventFilter(QObject *obj, QEvent *event) override {
        qint64 cur = QDateTime::currentMSecsSinceEpoch();
        if(event->type() == QEvent::KeyPress && cur-lastcheck > 25) {
            QKeyEvent *keyEvent = static_cast<QKeyEvent *>(event);
            lastcheck = cur;
            emit receivedKeyPress(keyEvent->key(), keyEvent->modifiers());
        }
        return QObject::eventFilter(obj, event);
    }

private:
    PQKeyPressChecker() { lastcheck = 0; }
    qint64 lastcheck;

signals:
    void receivedKeyPress(int key, int modifiers);

};
