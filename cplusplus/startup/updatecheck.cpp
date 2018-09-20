#include "startupcheck.h"

int StartupCheck::UpdateCheck::checkForUpdateInstall(::Settings *settings) {

    bool debug = (qgetenv("PHOTOQT_DEBUG") == "yes");

    if(debug) LOG << CURDATE << "StartupCheck::UpdateCheck" << NL;

    if(settings->getVersionInTextFile() == "") {
        if(debug) LOG << CURDATE << "PhotoQt newly installed!" << NL;
        settings->setVersion(VERSION);
        return 2;
    }

    if(debug) LOG << CURDATE << "Checking if first run of new version" << NL;

    // If it doesn't contain current version (some previous version)
    if(settings->getVersion() != settings->getVersionInTextFile()) {

        if(debug) LOG << CURDATE << "PhotoQt updated" << NL;

        settings->setVersion(VERSION);

        return 1;

    }

    return 0;

}
