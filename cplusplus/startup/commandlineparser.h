#ifndef PQCOMMANDLINEPARSER_H
#define PQCOMMANDLINEPARSER_H

#include <QObject>
#include <QCommandLineParser>
#include <QGuiApplication>

enum PQCommandLineResult {
    PQCOmmandLineNothing,
    PQCommandLineOpen,
    PQCommandLineShow,
    PQCommandLineHide,
    PQCommandLineToggle,
    PQCommandLineThumbs,
    PQCommandLineNoThumbs,
    PQCommandLineTray,
    PQCommandLineStandalone,
    PQCommandLineDebug,
    PQCommandLineExport,
    PQCommandLineImport
};

class PQCommandLineParser : public QObject {

    Q_OBJECT

public:
    explicit PQCommandLineParser(QObject *parent = nullptr);

    PQCommandLineResult parse(QGuiApplication &app);

private:
    QCommandLineParser parser;


};


#endif // PQCOMMANDLINEPARSER_H
