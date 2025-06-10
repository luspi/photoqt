##########################################################################
##                                                                      ##
## Copyright (C) 2011-2025 Lukas Spies                                  ##
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

f = open("output/pqc_settings.h", "w")
f.write(header.get())
f.close()


##############################################################################################
##############################################################################################
##############################################################################################

cont= constructor.get()

cont += getsetdef.get()

cont += readdb.get()

f = open("parts/backupdatabase.cpp", "r")
cont += f.read()

cont += savechangedvalue.get()

cont += setdefault.get()

cont += getdefaultfor.get()


f = open("parts/closereopen.cpp", "r")
cont += f.read()

f = open("parts/migrate.cpp", "r")
cont += f.read()

f = open("parts/verifynameandgettype.cpp", "r")
cont += f.read()

cont += setupfresh.get()

cont += resettodefault.get()


f = open("output/pqc_settings.cpp", "w")
f.write(cont)
f.close()
