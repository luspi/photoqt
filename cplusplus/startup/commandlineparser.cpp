#include "commandlineparser.h"

PQCommandLineParser::PQCommandLineParser(QObject *parent) : QObject(parent) {

    parser.setApplicationDescription(QGuiApplication::translate("commandlineparser", "Image Viewer"));

    parser.addPositionalArgument("[filename]", QGuiApplication::translate("commandlineparser", "Image file to open."));

    parser.addHelpOption();
    parser.addVersionOption();

    parser.addOptions({
            {{"o", "open"}, QGuiApplication::translate("commandlineparser", "Make PhotoQt ask for a new file.")},
            {{"s", "show"}, QGuiApplication::translate("commandlineparser", "Shows PhotoQt from system tray.")},
            {"hide", QGuiApplication::translate("commandlineparser", "Hides PhotoQt to system tray.")},
            {{"t", "toggle"}, QGuiApplication::translate("commandlineparser", "Show/Hide PhotoQt.")},
            {"thumbs", QGuiApplication::translate("commandlineparser", "Enable thumbnails.")},
            {"no-thumbs", QGuiApplication::translate("commandlineparser", "Disable thumbnails.")},
            {"start-in-tray", QGuiApplication::translate("commandlineparser", "Start PhotoQt hidden to the system tray.")},
            {"standalone", QGuiApplication::translate("commandlineparser", "Open standalone PhotoQt, allows for multiple instances but without remote interaction.")},
            {"debug", QGuiApplication::translate("commandlineparser", "Switch on debug messages.")},
            {"no-debug", QGuiApplication::translate("commandlineparser", "Switch off debug messages.")},
            {"export", QGuiApplication::translate("commandlineparser", "Export configuration to given filename."), "filename"},
            {"import", QGuiApplication::translate("commandlineparser", "Import configuration from given filename."), "filename"}
                      });

}

PQCommandLineResult PQCommandLineParser::parse(QGuiApplication &app) {

    parser.process(app);

    return PQCOmmandLineNothing;

}
