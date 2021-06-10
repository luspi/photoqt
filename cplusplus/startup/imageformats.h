/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

#ifndef PQSTARTUP_IMAGEFORMATS_H
#define PQSTARTUP_IMAGEFORMATS_H

#include "../logger.h"
#include "../settings/imageformats.h"

namespace PQStartup {

    namespace ImageFormats {

        static void ensureImageFormatsDatabaseExists() {

            QFile db(ConfigFiles::IMAGEFORMATS_DB());

            if(!db.exists()) {
                if(!QFile::copy(":/imageformats.db", ConfigFiles::IMAGEFORMATS_DB()))
                    LOG << CURDATE << "PQStartup::ImageFormats: unable to create default imageformats database" << NL;
                else {
                    QFile file(ConfigFiles::IMAGEFORMATS_DB());
                    file.setPermissions(QFile::WriteOwner|QFile::ReadOwner|QFile::ReadGroup|QFile::ReadOther);
                }
            }

        }

        static void updateFormats() {

            if(!PQImageFormats::get().enterNewFormat("jxl", "image/jxl", "JPEG XL", "img", 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, "", "jxl"))
                LOG << CURDATE << "PQStartup::ImageFormats: unable to enter new format JPEG XL." << NL;

            // we re-read the database after updating it for the above changes to be live
            PQImageFormats::get().readDatabase();

        }

    }

}

#endif // PQSTARTUP_IMAGEFORMATS_H
