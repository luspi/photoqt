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

		// Add optional argument 'filename'
		parser.addPositionalArgument("filename",tr("File to open with PhotoQt"), "[filename]");

		// And process the command line
		parser.process(*app);

	}

};


#endif
