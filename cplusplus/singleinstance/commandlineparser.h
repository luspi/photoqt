#ifndef PQCOMMANDLINEPARSER_H
#define PQCOMMANDLINEPARSER_H

#include <QObject>
#include <QCommandLineParser>
#include <QGuiApplication>

enum PQCommandLineResult {
    PQCOmmandLineNothing = 0,
    PQCommandLineFile = 1,
    PQCommandLineOpen = 2,
    PQCommandLineThumbs = 4,
    PQCommandLineNoThumbs = 8,
    PQCommandLineStandalone = 16,
    PQCommandLineDebug = 32,
    PQCommandLineNoDebug = 64,
    PQCommandLineExport = 128,
    PQCommandLineImport = 256,
    PQShortcutSequence = 512
};
inline PQCommandLineResult operator|(PQCommandLineResult a, PQCommandLineResult b) {
    return static_cast<PQCommandLineResult>(static_cast<int>(a) | static_cast<int>(b));
}

class PQCommandLineParser : public QObject, public QCommandLineParser {

    Q_OBJECT

public:
    explicit PQCommandLineParser(QGuiApplication &app, QObject *parent = nullptr) : QObject(parent), QCommandLineParser() {

        setApplicationDescription(QGuiApplication::translate("commandlineparser", "Image Viewer"));

        addPositionalArgument("[filename]", QGuiApplication::translate("commandlineparser", "Image file to open."));

        addHelpOption();
        addVersionOption();

        addOptions({
            {{"o", "open"}, QGuiApplication::translate("commandlineparser", "Make PhotoQt ask for a new file.")},
            {"thumbs", QGuiApplication::translate("commandlineparser", "Enable thumbnails.")},
            {"no-thumbs", QGuiApplication::translate("commandlineparser", "Disable thumbnails.")},
            {"standalone", QGuiApplication::translate("commandlineparser", "Open standalone PhotoQt, allows for multiple instances but without remote interaction.")},
            {"send-shortcut", QGuiApplication::translate("commandlineparser", "Simulate a shortcut sequence"), "shortcut"},
            {"debug", QGuiApplication::translate("commandlineparser", "Switch on debug messages.")},
            {"no-debug", QGuiApplication::translate("commandlineparser", "Switch off debug messages.")},
            {"export", QGuiApplication::translate("commandlineparser", "Export configuration to given filename."), "filename"},
            {"import", QGuiApplication::translate("commandlineparser", "Import configuration from given filename."), "filename"}
        });

        process(app);

    }

    PQCommandLineResult getResult() {

        PQCommandLineResult ret = PQCOmmandLineNothing;

        if(positionalArguments().length() > 0) {
            ret = ret|PQCommandLineFile;
            filename = positionalArguments().at(0);
        }

        if(isSet("o") || isSet("open"))
            ret = ret|PQCommandLineOpen;

        if(isSet("thumbs"))
            ret = ret|PQCommandLineThumbs;

        if(isSet("no-thumbs"))
            ret = ret|PQCommandLineNoThumbs;

        if(isSet("standalone"))
            ret = ret|PQCommandLineStandalone;

        shortcutSequence = value("send-shortcut");
        if(shortcutSequence != "")
            ret = ret|PQShortcutSequence;

        if(isSet("debug"))
            ret = ret|PQCommandLineDebug;

        if(isSet("no-debug"))
            ret = ret|PQCommandLineNoDebug;

        exportFileName = value("export");
        if(exportFileName != "")
            ret = ret|PQCommandLineExport;

        importFileName = value("import");
        if(importFileName != "")
            ret = ret|PQCommandLineImport;

        return ret;

    }

    QString exportFileName;
    QString importFileName;
    QString filename;
    QString shortcutSequence;

};


#endif // PQCOMMANDLINEPARSER_H
