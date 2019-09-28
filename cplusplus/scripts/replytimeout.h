#ifndef PQREPLYTIMEOUT_H
#define PQREPLYTIMEOUT_H

#include <QObject>
#include <QTimerEvent>

class PQReplyTimeout : public QObject {
    Q_OBJECT
    QBasicTimer m_timer;
public:
    PQReplyTimeout(QNetworkReply* reply, const int timeout) : QObject(reply) {
        Q_ASSERT(reply);
        if (reply && reply->isRunning())
            m_timer.start(timeout, this);
    }
    static void set(QNetworkReply* reply, const int timeout) {
        new PQReplyTimeout(reply, timeout);
    }
protected:
    void timerEvent(QTimerEvent * ev) {
        if (!m_timer.isActive() || ev->timerId() != m_timer.timerId())
            return;
        auto reply = static_cast<QNetworkReply*>(parent());
        if (reply->isRunning())
            reply->close();
        m_timer.stop();
    }
};

#endif // PQREPLYTIMEOUT_H
