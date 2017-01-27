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

#ifndef STARTUPCHECK_EXPORTIMPORT_H
#define STARTUPCHECK_EXPORTIMPORT_H

#include "../logger.h"
#include "../scripts/getanddostuff/external.h"
#include "../singleinstance/singleinstance.h"

namespace StartupCheck {

	namespace ExportImport {

		static inline int handleExportImport(SingleInstance *a) {

			if(a->exportAndQuitNow) {
				GetAndDoStuffExternal external;
				QString ret = external.exportConfig();
				if(ret == "-")
					LOG << CURDATE << "Exporting was aborted by user... I will quit now!" << NL;
				else if(ret != "")
					LOG << CURDATE << "Exporting configuration failed with error message: " << ret.toStdString() << NL;
				else
					LOG << CURDATE << "Configuration successfully exported... I will quit now!" << NL;
				QMetaObject::invokeMethod(qApp, "quit", Qt::QueuedConnection);
				return a->exec();
			}
			if(a->importAndQuitNow != "") {
				GetAndDoStuffExternal external;
				QString ret = external.importConfig(a->importAndQuitNow);
				if(ret != "")
					LOG << CURDATE << "Importing configuration failed with error message: " << ret.toStdString() << NL;
				else
					LOG << CURDATE << "Configuration successfully imported... I will quit now!" << NL;
				QMetaObject::invokeMethod(qApp, "quit", Qt::QueuedConnection);
				return a->exec();
			}

			// return value of -1 means: just ignore this and keep going normally, nothing happened
			return -1;

		}

	}

}

#endif // STARTUPCHECK_EXPORTIMPORT_H
