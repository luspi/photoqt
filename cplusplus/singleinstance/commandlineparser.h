#ifndef COMMANDLINEPARSER_H
#define COMMANDLINEPARSER_H

#include <QCommandLineParser>

class CommandLineParser : public QCommandLineParser {

public:

	explicit CommandLineParser(QCoreApplication *app) : QCommandLineParser() {

		// We use only long options
		this->setSingleDashWordOptionMode(QCommandLineParser::ParseAsLongOptions);

		// Set some standard options
		this->setApplicationDescription("PhotoQt Image Viewer");
		this->addHelpOption();
		this->addVersionOption();

		// Add custom PhotoQt options (C++11 way)
		this->addOptions({
				{{"v", "verbose"},
				 tr("Enable debug messages (at start-up only)")},
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
				 tr("Start PhotoQt hidden to the system tray (at start-up only)")}

		 });

		// Add optional argument 'filename'
		this->addPositionalArgument("filename",tr("File to open with PhotoQt"), "[filename]");

		// And process the command line
		this->process(*app);

	}

};


#endif
