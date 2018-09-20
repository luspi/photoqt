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

#include "commandlineparser.h"

CommandLineParser::CommandLineParser(QCoreApplication *app) : QObject() {

    // This will hold the maximum width of the options to align everything nicely
    maxEntriesWidth = 0;

    // These 4 options should always be the first four!
    validOptions << "h" << "help" << "v" << "version";

    // First category
    QString cat = "Interaction with PhotoQt";
    addOption(cat, QStringList() << "o" << "open", "Make PhotoQt ask for a new File.");
    addOption(cat, QStringList() << "s" << "show", "Shows PhotoQt (does nothing if already shown).");
    addOption(cat, QStringList() << "hide", "Hides PhotoQt to system tray (does nothing if already hidden).");
    addOption(cat, QStringList() << "t" << "toggle", "Toggle PhotoQt - hides PhotoQt if visible, shows if hidden.");
    addOption(cat, QStringList() << "thumbs" << "no-thumbs", "Enable/Disable thumbnails.");

    // Second category
    cat = "Start-up-only options";
    addOption(cat, QStringList() << "start-in-tray", "Start PhotoQt hidden to the system tray.");
    addOption(cat, QStringList() << "standalone", "Create standalone PhotoQt, multiple instances but no remote interaction possible.");

    // Third category
    cat = "General Options";
    addOption(cat, QStringList() << "debug" << "no-debug", "Switch on/off debug messages.");
    addOption(cat, QStringList() << "export", "Export configuration to given filename.", "filename");
    addOption(cat, QStringList() << "import", "Import configuration from given filename.", "filename");

    // Process the command line
    process(app);

}

// Add a command line option
void CommandLineParser::addOption(QString cat, QStringList option, QString description, QString valueName) {

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

// Show the help message and quit
void CommandLineParser::showHelp() {

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
void CommandLineParser::showError(QString err) {
    std::cout << err.toStdString() << std::endl;
    qApp->quit();
    exit(0);
}

// Process the command line
void CommandLineParser::process(QCoreApplication *app) {

    // Get all arguments
    QStringList args = app->arguments();

    // If help flag is set, show help and quit
    if(args.contains("-h") || args.contains("--help"))
        // This function is marked as 'noreturn' and will never return control flow.
        // Thus it does not need to be followed by a 'return' as it already stops and quits the application
        showHelp();

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
            else
                // This function is marked as 'noreturn' and will never return control flow.
                // Thus it does not need to be followed by a 'return' as it already stops and quits the application
                showError("Only one filename can be passed on!");

        // 'Normal' flags
        } else {

            // Remove any '-' from the beginning of the flag
            while(a.startsWith("-"))
                a = a.remove(0,1);

            // If option is not a valid one, show error and quit
            if(!validOptions.contains(a))
                // This function is marked as 'noreturn' and will never return control flow.
                // Thus it does not need to be followed by a 'return' as it already stops and quits the application
                showError("Unknown option '" + a + "'.");

            // If option comes with a value
            if(optionsWithValue.contains(a)) {

                // If no value was provided, show error and quit
                if(i == args.length()-1 || args.at(i+1).startsWith("-")) {
                    // This function is marked as 'noreturn' and will never return control flow.
                    // Thus it does not need to be followed by a 'return' as it already stops and quits the application
                    showError("Filename required for option '" + a + "'.");
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
