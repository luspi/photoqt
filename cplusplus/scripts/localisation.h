#ifndef LOCALISATION_H
#define LOCALISATION_H

#include <QObject>
#include <QTranslator>
#include <QApplication>
#include <QFile>

class Localisation : public QObject {

    Q_OBJECT

public:
    Localisation(QObject *parent = 0) : QObject(parent) {
        trans = new QTranslator;
    }
    ~Localisation() {
        delete trans;
    }

    Q_INVOKABLE void setLanguage(QString code) {

        if(!trans->isEmpty())
            qApp->removeTranslator(trans);

        if(QFile(":/photoqt_" + code + ".qm").exists()) {
            trans->load(":/photoqt_" + code);
            qApp->installTranslator(trans);
            emit languageChanged();
            return;
        }

        if(code.contains("_")) {
            code = code.split("_").at(0);
            if(QFile(":/photoqt_" + code + ".qm").exists()) {
                trans->load(":/photoqt_" + code);
                qApp->installTranslator(trans);
                emit languageChanged();
                return;
            }
        }

        // Store translation in settings file
        trans->load(":/photoqt_en.qm");
        qApp->installTranslator(trans);
        emit languageChanged();

    }

    Q_PROPERTY(QString pty READ getPty NOTIFY languageChanged)
    QString getPty() {
        return "";
    }

private:
    QTranslator *trans;

signals:
    void languageChanged();

};

#endif // LOCALISATION_H
