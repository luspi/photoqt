##########################################################################
##                                                                      ##
## Copyright (C) 2011-2026 Lukas Spies                                  ##
## Contact: https://photoqt.org                                         ##
##                                                                      ##
## This file is part of PhotoQt.                                        ##
##                                                                      ##
## PhotoQt is free software: you can redistribute it and/or modify      ##
## it under the terms of the GNU General Public License as published by ##
## the Free Software Foundation, either version 2 of the License, or    ##
## (at your option) any later version.                                  ##
##                                                                      ##
## PhotoQt is distributed in the hope that it will be useful,           ##
## but WITHOUT ANY WARRANTY; without even the implied warranty of       ##
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        ##
## GNU General Public License for more details.                         ##
##                                                                      ##
## You should have received a copy of the GNU General Public License    ##
## along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      ##
##                                                                      ##
##########################################################################

import os
os.makedirs('output/', exist_ok=True)

import parts.header as header
import parts.constructor as constructor
import parts.getsetdef as getsetdef
import parts.readdb as readdb
import parts.savechangedvalue as savechangedvalue
import parts.setdefault as setdefault
import parts.getdefaultfor as getdefaultfor
import parts.setupfresh as setupfresh
import parts.resettodefault as resettodefault
import parts.cpp_header as cpp_header
import parts.updatefromcommandline as updatefromcommandline

##############################################################################################
##############################################################################################
##############################################################################################

# which settings to duplicate for the C++ settings interface
duplicateSettings = ["generalExtensionsEnabled",
                     "generalExtensionsAllowUntrusted",
                     "generalInterfaceVariant",
                     "",
                     "imageviewFitInWindow",
                     "imageviewSortImagesAscending",
                     "imageviewSortImagesBy",
                     "imageviewCache",
                     "imageviewColorSpaceEnable",
                     "imageviewColorSpaceLoadEmbedded",
                     "imageviewColorSpaceDefault",
                     "imageviewAdvancedSortCriteria",
                     "imageviewAdvancedSortAscending",
                     "imageviewAdvancedSortQuality",
                     "imageviewAdvancedSortDateCriteria",
                     "imageviewRespectDevicePixelRatio",
                     "",
                     "filedialogDevicesShowTmpfs",
                     "filedialogShowHiddenFilesFolders",
                     "filedialogFolderContentThumbnailsSortBy",
                     "filedialogFolderContentThumbnailsSortAscending",
                     "",
                     "filetypesLoadAppleLivePhotos",
                     "filetypesLoadMotionPhotos",
                     "filetypesExternalUnrar",
                     "filetypesVideoThumbnailer",
                     "filetypesRAWUseEmbeddedIfAvailable",
                     "filetypesPDFQuality",
                     "filetypesVideoPreferLibmpv",
                     "filetypesArchiveAlwaysEnterAutomatically",
                     "filetypesComicBookAlwaysEnterAutomatically",
                     "filetypesDocumentAlwaysEnterAutomatically",
                     "filetypesArchiveDontLoadMoreFilesThan",
                     "filetypesArchiveDontLoadMoreFilesThanCount",
                     "filetypesArchiveIgnoreLargerThan",
                     "filetypesArchiveIgnoreLargerThanSize",
                     "",
                     "interfaceAccentColor",
                     "interfaceFontNormalWeight",
                     "interfaceFontBoldWeight",
                     "interfacePopoutWhenWindowIsSmall",
                     "interfaceLanguage",
                     "interfacePopoutMapExplorerNonModal",
                     "interfacePopoutFileDialogNonModal",
                     "interfacePopoutSettingsManagerNonModal",
                     "",
                     "thumbnailsExcludeDropBox",
                     "thumbnailsExcludeNextcloud",
                     "thumbnailsExcludeOwnCloud",
                     "thumbnailsExcludeFolders",
                     "thumbnailsExcludeNetworkShares",
                     "thumbnailsCacheBaseDirDefault",
                     "thumbnailsCacheBaseDirLocation",
                     "thumbnailsMaxNumberThreads",
                     "thumbnailsCache",
                     "thumbnailsIconsOnly",
                     "",
                     "metadataAutoRotation"]

duplicateSettingsSignal = ["imageviewSortImagesBy",
                           "imageviewSortImagesAscending",
                           "interfaceAccentColor",
                           "interfaceFontBoldWeight",
                           "interfaceFontNormalWeight",
                           "filedialogShowHiddenFilesFolders"]

##############################################################################################
##############################################################################################
##############################################################################################

f = open("output/pqc_settings.h", "w")
f.write(header.get())
f.close()

##############################################################################################
##############################################################################################
##############################################################################################

cont = constructor.get()
cont += getsetdef.get(duplicateSettings, duplicateSettingsSignal)
cont += readdb.get(duplicateSettings, duplicateSettingsSignal)
f = open("parts/backupdatabase.cpp", "r"); cont += f.read()
cont += savechangedvalue.get()
cont += setdefault.get()
f = open("parts/closereopen.cpp", "r"); cont += f.read()
f = open("parts/verifynameandgettype.cpp", "r"); cont += f.read()
cont += setupfresh.get(duplicateSettings, duplicateSettingsSignal)
cont += resettodefault.get()
cont += updatefromcommandline.get(duplicateSettings, duplicateSettingsSignal)


f = open("output/pqc_settings.cpp", "w")
f.write(cont)
f.close()

##############################################################################################
##############################################################################################
##############################################################################################

cont = cpp_header.get(duplicateSettings)

f = open("output/pqc_settingscpp.h", "w")
f.write(cont)
f.close()
