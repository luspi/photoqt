#ifndef STARTUPCHECK_STARTUPMIGRATION_H
#define STARTUPCHECK_STARTUPMIGRATION_H

#include "../logger.h"

namespace StartupCheck {

	namespace Migration {

		static inline void migrateIfNecessary(bool verbose) {

			if(verbose) LOG << DATE << "StartupCheck::Migration" << std::endl;

			// This class will handle the planned migration of the config/..
			// of PhotoQt to new settings that satisfy the freedesktop.org standard

		}

	}

}

#endif // STARTUPCHECK_STARTUPMIGRATION_H
