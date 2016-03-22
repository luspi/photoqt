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

		// Add custom PhotoQt options (C++11 way)
		parser.addOptions({
				{{"o","open"},
				 tr("Make PhotoQt ask for a new File")},
				{{"t","toggle"},
				 tr("Toggle PhotoQt - hides PhotoQt if visible, shows if hidden")},
				{{"s","show"},
				 tr("Shows PhotoQt (does nothing if already shown)")},
				{{"h","hide"},
				 tr("Hides PhotoQt (does nothing if already hidden)")},
				{"no-thumbs",
				 tr("Disable thumbnails")},
				{"thumbs",
				 tr("Enable thumbnails")},
				{"start-in-tray",
				 tr("Start PhotoQt hidden to the system tray (at start-up only)")},
				{"verbose",
				 tr("Enable debug messages (at start-up only)")}

		 });

		// Add optional argument 'filename'
		parser.addPositionalArgument("filename",tr("File to open with PhotoQt"), "[filename]");

		// And process the command line
		parser.process(*app);

	}

};


#endif
