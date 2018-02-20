/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#ifndef COMMANDLINEPARSER_H
#define COMMANDLINEPARSER_H

#include <QCoreApplication>
#include <iomanip>
#include "../logger.h"

// A custom command line parser
// Looks very much like QCommandLineParser, but allows grouping entries
class CommandLineParser : public QObject {

    Q_OBJECT

public:

    explicit CommandLineParser(QCoreApplication *app) : QObject() {

        // This will hold the maximum width of the options to align everything nicely
        maxEntriesWidth = 0;

        // These 4 options should always be the first four!
        validOptions << "h" << "help" << "v" << "version";

        // First category
        QString cat = "Interaction with PhotoQt";
        addOption(cat, {"o", "open"}, "Make PhotoQt ask for a new File.");
        addOption(cat, {"s", "show"}, "Shows PhotoQt (does nothing if already shown).");
        addOption(cat, "hide", "Hides PhotoQt to system tray (does nothing if already hidden).");
        addOption(cat, {"t", "toggle"}, "Toggle PhotoQt - hides PhotoQt if visible, shows if hidden.");
        addOption(cat, {"thumbs", "no-thumbs"}, "Enable/Disable thumbnails.");

        // Second category
        cat = "Start-up-only options";
        addOption(cat, "start-in-tray", "Start PhotoQt hidden to the system tray.");
        addOption(cat, "standalone", "Create standalone PhotoQt, multiple instances but no remote interaction possible.");

        // Third category
        cat = "General Options";
        addOption(cat, {"debug", "no-debug"}, "Switch on/off debug messages.");
        addOption(cat, "export", "Export configuration to given filename.", "filename");
        addOption(cat, "import", "Import configuration from given filename.", "filename");

        // Process the command line
        process(app);

    }

    // Convenience function, allows to pass a single option as string
    void addOption(QString cat, QString option, QString description, QString valueName = "") {
        addOption(cat, QStringList() << option, description, valueName);
    }

    // Add a command line option
    void addOption(QString cat, QStringList option, QString description, QString valueName = "") {

        // Store a new category
        if(!categories.contains(cat))
            categories.append(cat);

        // Compose the option string that is to be displayed
        QString optionString = "";
        // Loop over all options
        for(QString o : option) {

            // Store this as a valid options the user can use
            validOptions << o;

            // If this flag comes with a value, store that
            if(valueName != "")
                optionsWithValue << o;

            // Multiple options are displayed separated by comma
            if(optionString != "")
                optionString += ", ";

            // Add on the option to the string.
            // 1-character flags are called with a single '-'
            // 2+-character flags are called with a double '-'
            optionString += (o.length()==1 ? "-" : "--") + o;

        }

        // If option comes with a value, displayed after options in angled brackets
        if(valueName.length() > 0)
            optionString += " <" + valueName + ">";

        // Find largets width necessary
        if(optionString.length() > maxEntriesWidth)
            maxEntriesWidth = optionString.length();

        // Store entry
        allEntries << (QStringList() << cat << optionString << description);

    }

private:

    // Show the help message and quit
    void showHelp() {

        // the max width gets two added on the left (indented by 2) and on the right (spacing between option and description)
        int entryWidth = 2+maxEntriesWidth+2;

        int maxWidth = 78;

        // Header
        std::cout << "Usage: photoqt [options] [filename]" << std::endl;
        std::cout << "PhotoQt Image Viewer" << std::endl << std::endl;

        // help and version option
        std::cout << std::setfill(' ') << std::setw(entryWidth) << std::left << "  -h, --help" << "Displays this help." << std::endl;
        std::cout << std::setfill(' ') << std::setw(entryWidth) << std::left << "  -v, --version" << "Displays version information." << std::endl;

        // Loop over all categories
        for(QString cat : categories) {

            // Display category followed by colon
            std::cout << std::endl << cat.toStdString() << ":" << std::endl;

            // Loop over all entries to find the ones matching this category
            for(QStringList entry : allEntries) {

                // If categories match, output option
                if(entry.at(0) == cat) {

                    // Output category
                    std::cout << std::setfill(' ') << std::setw(entryWidth) << std::left << ("  " + entry.at(1).toStdString());

                    // The description. This will be reduced by whatever is outputted
                    QString desc = entry.at(2);

                    // Keep as going as long as there is something to output
                    while(desc.length() > 0) {

                        // The maximum width that is available for the description
                        int maxDescLength = std::min(maxWidth-entryWidth, desc.length()-1);

                        // Make sure that, if we are not at the end of the string, we break the string at a space
                        while(desc.at(maxDescLength) != ' ' && maxDescLength < desc.length()-1)
                            --maxDescLength;

                        // Error checking, this should never really happen, but just to be safe
                        if(maxDescLength < 1)
                            break;

                        // If this is the second line, we need to pad the output on the left for proper indentation
                        if(desc.length() < entry.at(2).length())
                            std::cout << std::setfill(' ') << std::setw(entryWidth) << " ";

                        // Output the description (sub-)string
                        std::cout << desc.left(maxDescLength+1).trimmed().toStdString() << std::endl;

                        // Remove whatever part of the description is displayed
                        desc = desc.remove(0, maxDescLength+1);

                    }

                }

            }

        }

        // Output the positional argument at end
        std::cout << std::endl;
        std::cout << "Arguments:" << std::endl;
        std::cout << std::setfill(' ') << std::setw(entryWidth) << std::left << "  filename" << "File to open with PhotoQt." << std::endl;

        // And quit application
        qApp->quit();
        exit(0);

    }

    // When an error was detected, display error and quit
    void showError(QString err) {
        std::cout << err.toStdString() << std::endl;
        qApp->quit();
        exit(0);
    }

    // Process the command line
    void process(QCoreApplication *app) {

        // Get all arguments
        QStringList args = app->arguments();

        // If help flag is set, show help and quit
        if(args.contains("-h") || args.contains("--help")) {
            showHelp();
            return;
        }

        // Set the found filename to empty
        foundFilename = "";

        // Loop over all arguments
        for(int i = 1; i < args.length(); ++i) {

            // quick access for current flag
            QString a = args.at(i);

            // If flag doesn't start with a '-', then this is the positional flag, i.e., the filename
            if(!a.startsWith("-")) {

                // If this is the first filename, store that
                if(foundFilename.trimmed() == "")
                    foundFilename = a;
                // Else show error as only one filename is allowed
                else {
                    showError("Only one filename can be passed on!");
                    return;
                }

            // 'Normal' flags
            } else {

                // Remove any '-' from the beginning of the flag
                while(a.startsWith("-"))
                    a = a.remove(0,1);

                // If option is not a valid one, show error and quit
                if(!validOptions.contains(a)) {
                    showError("Unknown option '" + a + "'.");
                    return;
                }

                // If option comes with a value
                if(optionsWithValue.contains(a)) {

                    // If no value was provided, show error and quit
                    if(i == args.length()-1 || args.at(i+1).startsWith("-")) {
                        showError("Filename required for option '" + a + "'.");
                        return;
                    // Store value
                    } else {
                        foundValues.insert(a, args.at(++i));
                        // This is a simple list holding all passed on flags
                        // This makes it much easier to find out what has been set or not
                        foundOptions.append(a);
                    }

                // A normal flag without value
                } else
                    foundOptions.append(a);

            }

        }

    }

public:
    // All options that have been found
    QStringList foundOptions;
    // All option/value pairs that have been found
    QMap<QString,QString> foundValues;
    // The found filename (if any)
    QString foundFilename;

private:
    // Hold max width required for options
    int maxEntriesWidth;
    // All categories that have been set
    QStringList categories;
    // All entries
    QList<QStringList> allEntries;
    // All options that are set as one list
    QStringList validOptions;
    // All options that are set with values as one list
    QStringList optionsWithValue;

};


#endif
