#ifndef PQCOMMANDLINEPARSER_H
#define PQCOMMANDLINEPARSER_H

#include <QObject>
#include <QCommandLineParser>
#include <QGuiApplication>

enum PQCommandLineResult {
    PQCOmmandLineNothing = 0,
    PQCommandLineFile = 1,
    PQCommandLineOpen = 2,
    PQCommandLineShow = 4,
    PQCommandLineHide = 8,
    PQCommandLineToggle = 16,
    PQCommandLineThumbs = 32,
    PQCommandLineNoThumbs = 64,
    PQCommandLineTray = 128,
    PQCommandLineStandalone = 256,
    PQCommandLineDebug = 512,
    PQCommandLineNoDebug = 1024,
    PQCommandLineExport = 2048,
    PQCommandLineImport = 4096,
    PQShortcutSequence = 8192
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
            {{"s", "show"}, QGuiApplication::translate("commandlineparser", "Shows PhotoQt from system tray.")},
            {"hide", QGuiApplication::translate("commandlineparser", "Hides PhotoQt to system tray.")},
            {{"t", "toggle"}, QGuiApplication::translate("commandlineparser", "Show/Hide PhotoQt.")},
            {"thumbs", QGuiApplication::translate("commandlineparser", "Enable thumbnails.")},
            {"no-thumbs", QGuiApplication::translate("commandlineparser", "Disable thumbnails.")},
            {"start-in-tray", QGuiApplication::translate("commandlineparser", "Start PhotoQt hidden to the system tray.")},
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

        if(isSet("s") || isSet("show"))
            ret = ret|PQCommandLineShow;

        if(isSet("hide"))
            ret = ret|PQCommandLineHide;

        if(isSet("t") || isSet("toggle"))
            ret = ret|PQCommandLineToggle;

        if(isSet("thumbs"))
            ret = ret|PQCommandLineThumbs;

        if(isSet("no-thumbs"))
            ret = ret|PQCommandLineNoThumbs;

        if(isSet("start-in-tray"))
            ret = ret|PQCommandLineTray;

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
