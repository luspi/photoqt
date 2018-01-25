/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef COMMANDLINEPARSER_H
#define COMMANDLINEPARSER_H

#include <QCommandLineParser>

class CommandLineParser : public QObject {

    Q_OBJECT

public:

    QCommandLineParser parser;

    explicit CommandLineParser(QCoreApplication *app) : QObject() {

        // We use only long options
        parser.setSingleDashWordOptionMode(QCommandLineParser::ParseAsLongOptions);

        // Set some standard options
        parser.setApplicationDescription("PhotoQt Image Viewer");
        parser.addHelpOption();
        parser.addVersionOption();

        // Add custom PhotoQt options (We HAVE to go the long way, as the shortcut possible isn't available in Qt 5.3)
        QCommandLineOption opt_open(QStringList() << "o" << "open", tr("Make PhotoQt ask for a new File"));
        parser.addOption(opt_open);
        QCommandLineOption opt_toggle(QStringList() << "t" << "toggle", tr("Toggle PhotoQt - hides PhotoQt if visible, shows if hidden"));
        parser.addOption(opt_toggle);
        QCommandLineOption opt_show(QStringList() << "s" << "show", tr("Shows PhotoQt (does nothing if already shown)"));
        parser.addOption(opt_show);
        QCommandLineOption opt_hide(QStringList() << "h" << "hide", tr("Hides PhotoQt (does nothing if already hidden)"));
        parser.addOption(opt_hide);
        QCommandLineOption opt_nothumbs("no-thumbs", tr("Disable thumbnails"));
        parser.addOption(opt_nothumbs);
        QCommandLineOption opt_thumbs("thumbs", tr("Enable thumbnails"));
        parser.addOption(opt_thumbs);
        QCommandLineOption opt_startintray("start-in-tray", tr("Start PhotoQt hidden to the system tray (at start-up only)"));
        parser.addOption(opt_startintray);
        QCommandLineOption opt_verbose(QStringList() << "debug" << "verbose", tr("Enable debug messages (at start-up only)"));
        parser.addOption(opt_verbose);
        QCommandLineOption opt_export("export", tr("Export configuration file to given filename"), "filename");
        parser.addOption(opt_export);
        QCommandLineOption opt_import("import", tr("Import configuration file with given filename"), "filename");
        parser.addOption(opt_import);
        QCommandLineOption opt_standalone("standalone", tr("Create standalone PhotoQt, multiple instances but no remote interaction possible!"));
        parser.addOption(opt_standalone);

        // Add optional argument 'filename'
        parser.addPositionalArgument("filename",tr("File to open with PhotoQt"), "[filename]");

        // And process the command line
        parser.process(*app);

    }

};


#endif
