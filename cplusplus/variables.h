#ifndef PQVARIABLES_H
#define PQVARIABLES_H

#include <QObject>

class PQVariables : public QObject {

    Q_OBJECT

public:
        static PQVariables& get() {
            static PQVariables instance;
            return instance;
        }

        PQVariables(PQVariables const&)     = delete;
        void operator=(PQVariables const&) = delete;

        Q_PROPERTY(QString cmdFilePath READ getCmdFilePath WRITE setCmdFilePath NOTIFY cmdFilePathChanged)
        QString getCmdFilePath() { return m_cmdFilePath; }
        void setCmdFilePath(QString path) {
            if(path != m_cmdFilePath) {
                m_cmdFilePath = path;
                emit cmdFilePathChanged();
            }
        }

        Q_PROPERTY(bool cmdOpen READ getCmdOpen WRITE setCmdOpen NOTIFY cmdOpenChanged)
        bool getCmdOpen() { return m_cmdOpen; }
        void setCmdOpen(bool val) {
            if(val != m_cmdOpen) {
                m_cmdOpen = val;
                emit cmdOpenChanged();
            }
        }

        Q_PROPERTY(bool cmdThumbs READ getCmdThumbs WRITE setCmdThumbs NOTIFY cmdThumbsChanged)
        bool getCmdThumbs() { return m_cmdThumbs; }
        void setCmdThumbs(bool val) {
            if(val != m_cmdThumbs) {
                m_cmdThumbs = val;
                emit cmdThumbsChanged();
            }
        }

        Q_PROPERTY(bool cmdNoThumbs READ getCmdNoThumbs WRITE setCmdNoThumbs NOTIFY cmdNoThumbsChanged)
        bool getCmdNoThumbs() { return m_cmdNoThumbs; }
        void setCmdNoThumbs(bool val) {
            if(val != m_cmdNoThumbs) {
                m_cmdNoThumbs = val;
                emit cmdNoThumbsChanged();
            }
        }

        Q_PROPERTY(QString cmdShortcutSequence READ getCmdShortcutSequence WRITE setCmdShortcutSequence NOTIFY cmdShortcutSequenceChanged)
        QString getCmdShortcutSequence() { return m_cmdShortcutSequence; }
        void setCmdShortcutSequence(QString val) {
            if(val != m_cmdShortcutSequence) {
                m_cmdShortcutSequence = val;
                emit cmdShortcutSequenceChanged();
            }
        }

        Q_PROPERTY(bool cmdDebug READ getCmdDebug WRITE setCmdDebug NOTIFY cmdDebugChanged)
        bool getCmdDebug() { return m_cmdDebug; }
        void setCmdDebug(bool val) {
            if(val != m_cmdDebug) {
                m_cmdDebug = val;
                emit cmdDebugChanged();
            }
        }

private:
        PQVariables() {}

        QString m_cmdFilePath;
        bool m_cmdOpen;
        bool m_cmdThumbs;
        bool m_cmdNoThumbs;
        QString m_cmdShortcutSequence;
        bool m_cmdDebug;

signals:
        void cmdFilePathChanged();
        void cmdOpenChanged();
        void cmdThumbsChanged();
        void cmdNoThumbsChanged();
        void cmdShortcutSequenceChanged();
        void cmdDebugChanged();

};


#endif // PQVARIABLES_H
