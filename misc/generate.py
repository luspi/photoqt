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

import numpy as np
import sys

known_args = np.array(['all', 'filetypecolors', 'filetypes', 'cmake', 'windowsrc', 'nsi', 'formatsdb'])

if len(sys.argv) != 2 or sys.argv[1] not in known_args:

    print("""
One of the following flags is required:

 all\t\tGenerate all items
 filetypecolors\tCheck filetype colors and add any new/missing ones
 filetypes\tGenerate filetype icons
 cmake\t\tGenerate CMake desktop file creation
 windowsrc\tGenerate windows resource file
 nsi\t\tGenerate nsi entries
 formatsdb\tSQL for writing formats to website database
""")

    exit()

import sqlite3

which = sys.argv[1]

import os
os.makedirs('output/', exist_ok=True)


#############################################################
#############################################################
# CHECK FOR MISSING/NEW ICON COLORS
if which == 'filetypecolors':

    import random

    print("Checking filetype colors...")

    def myhex(x):
        val = hex(x)[2:]
        if len(val) == 1:
            val = f"0{val}"
        return val


    # create database connection
    conn = sqlite3.connect('imageformats.db')
    c = conn.cursor()

    # get all data
    c.execute('SELECT endings,category FROM imageformats ORDER BY endings')
    data = c.fetchall()

    newdata = ({})

    conn2 = sqlite3.connect('icons/iconcolors.db')
    c2 = conn2.cursor()

    for row in data:

        ending = row[0]

        c2.execute(f"SELECT * FROM colors WHERE endings='{ending}'")
        howmany = len(c2.fetchall())

        if howmany == 0:

            print("")
            print(f"Found new ending: {ending}")

            color = f"#{myhex(random.randint(0,192))}{myhex(random.randint(0,192))}{myhex(random.randint(0,192))}"
            print(f"Generating new random color: {color}")

            newdata[ending] = [color,row[1]]


    for ind in newdata:
        c2.execute(f"INSERT INTO colors (endings, color, category) VALUES('{ind}','{newdata[ind][0]}', '{newdata[ind][1]}')")

    conn2.commit()

#############################################################
#############################################################
# GENERATE FILETYPES IN SUBDIRECTORY
if which == 'all' or which == 'filetypes':

    import math
    import os
    import glob
    import multiprocessing
    import shutil

    os.makedirs('output/', exist_ok=True)
    os.makedirs('output/svg', exist_ok=True)
    os.makedirs('output/svg/large', exist_ok=True)
    os.makedirs('output/svg/small', exist_ok=True)
    os.makedirs('output/svg/squared', exist_ok=True)
    os.makedirs('output/svg/network', exist_ok=True)
    os.makedirs('output/ico', exist_ok=True)
    os.makedirs('output/tmp', exist_ok=True)
    files = glob.glob('./output/tmp/*')
    for f in files:
        os.remove(f)

    conn = sqlite3.connect('icons/iconcolors.db')
    c = conn.cursor()

    c.execute("SELECT endings,color,category FROM colors ORDER BY endings")
    data = c.fetchall()

    # fontsizes and x/y for strings of length 1 to 9
    fontsizes = [
        167.569,
        167.569,
        167.569,
        167.569,
        167.569,
        158.75,
        141.111,
        123.472,
        114.653
        ]
    xy = [
        [344.67334, 827.80219],
        [294.2308, 827.80219],
        [246.16951, 827.80219],
        [193.34572, 827.80219],
        [142.90329, 827.80219],

        [108.4817, 834.60229],
        [98.047729, 834.97253],
        [98.233337, 835.34283],

        [85.050117, 842.14288],
        ]

    print("Generating filetype icons...")


    qrc_cont = "<RCC>\n    <qresource prefix=\"/\">\n"

    updatedEndings = np.array([])

    totallen = len(data)
    i = 1
    for row in data:

        endings = row[0].split(",")
        color = row[1]
        category = row[2]

        print(f"{i}/{totallen}: {endings}")
        i += 1

        for e in endings:

            l = len(e)
            if e == "unknown":
                l = 1

            qrc_cont += f"        <file>filetypes/{e}.svg</file>\n"
            qrc_cont += f"        <file>filetypes/network_{e}.svg</file>\n"

            if e == "svg" or e == "svgz":
                category = "svg"

            fname_large = f"output/svg/large/{e}.svg"
            fname_small = f"output/svg/small/{e}.svg"
            fname_squared = f"output/svg/squared/{e}.svg"
            fname_network = f"output/svg/network/network_{e}.svg"

            generateHowMany = 0

            if not os.path.exists(fname_large):

                generateHowMany += 1

                print(f"  > large SVG: {e}")

                icn_large = open(f"icons/{category}.svg").read()
                icn_large = icn_large.replace("#f00", color)
                icn_large = icn_large.replace("ZZZ", "?" if (e=="unknown") else e.upper())
                icn_large = icn_large.replace("font-size:167.569px", f"font-size:{fontsizes[l-1]}px")
                icn_large = icn_large.replace('x="246.16951"', f'x="{xy[l-1][0]}"')
                icn_large = icn_large.replace('y="827.80219"', f'y="{xy[l-1][1]}"')
                f_large = open(fname_large, "w")
                f_large.write(icn_large)
                f_large.close()

            if not os.path.exists(fname_squared):

                generateHowMany += 1

                print(f"  > square SVG: {e}")

                icn_squared = open(f"icons/{category}_squared.svg").read()
                icn_squared = icn_squared.replace("#f00", color)
                icn_squared = icn_squared.replace("ZZZ", "?" if (e=="unknown") else e.upper())
                icn_squared = icn_squared.replace("font-size:167.569px", f"font-size:{fontsizes[l-1]}px")
                icn_squared = icn_squared.replace('x="378.4613"', f'x="{2*66.145895+xy[l-1][0]}"')
                icn_squared = icn_squared.replace('y="827.80219"', f'y="{xy[l-1][1]}"')
                f_squared = open(fname_squared, "w")
                f_squared.write(icn_squared)
                f_squared.close()

            if not os.path.exists(fname_network):

                generateHowMany += 1

                print(f"  > network SVG: {e}")

                icn_network = open(f"icons/{category}_network.svg").read()
                icn_network = icn_network.replace("#f00", color)
                icn_network = icn_network.replace("ZZZ", "?" if (e=="unknown") else e.upper())
                icn_network = icn_network.replace("font-size:167.569px", f"font-size:{fontsizes[l-1]}px")
                icn_network = icn_network.replace('x="378.4613"', f'x="{2*66.145895+xy[l-1][0]}"')
                icn_network = icn_network.replace('y="827.80219"', f'y="{xy[l-1][1]}"')
                f_network = open(fname_network, "w")
                f_network.write(icn_network)
                f_network.close()

            if not os.path.exists(fname_small):

                generateHowMany += 1

                print(f"  > small SVG: {e}")

                icn_small = open(f"icons/{category}_small.svg").read()
                icn_small = icn_small.replace("#f00", color)
                f_small = open(fname_small, "w")
                f_small.write(icn_small)
                f_small.close()

            if not os.path.exists(f"output/ico/{e}.ico"):

                generateHowMany += 1

                print(f"  > ICON: {e}")

                def convert(size):
                    global fname_small
                    global fname_large
                    global e
                    if size < 64:
                        os.system(f"convert -background none -gravity center -compress zip {fname_small} -resize {size}x{size} -extent {size}x{size} -compress zip output/tmp/{e}{size}.png")
                    else:
                        os.system(f"convert -background none -gravity center -compress zip {fname_large} -resize {size}x{size} -extent {size}x{size} -compress zip output/tmp/{e}{size}.png")
                    os.system(f"optipng -o7 -strip all output/tmp/{e}{size}.png")

                pool_obj = multiprocessing.Pool()
                pool_obj.map(convert,[256,128,64,48,32,16])

                exe = "./go-png2ico "
                for sze in [256,128,64,48,32,16]:
                    exe += f"output/tmp/{e}{sze}.png "
                exe += f"output/ico/{e}.ico"
                os.system(exe)

            if generateHowMany == 0:
                print(f"  > {e} already up to date")
            else:
                updatedEndings = np.append(updatedEndings, e)

    qrc_cont += "    </qresource>\n"
    qrc_cont += "</RCC>\n"

    f_qrc = open("output/filetypes.qrc", "w")
    f_qrc.write(qrc_cont)
    f_qrc.close()

    shutil.rmtree("output/tmp/")

    if len(updatedEndings) > 0:
        print("**********************")
        print("The following endings have been updated:")
        print(updatedEndings)

#############################################################
#############################################################
# GENERATE CMAKE DESKTOP FILE CREATION
if which == 'all' or which == 'cmake':

    print("Generating addition to CMake ComposeDesktopFile()...")

    # create database connection
    conn = sqlite3.connect('imageformats.db')
    c = conn.cursor()

    # get all data
    c.execute('SELECT * FROM imageformats ORDER BY endings')
    data = c.fetchall()

    mt = np.array([], dtype=str)

    cont = "set(MIMETYPE \""
    i = 0
    for row in data:
        if row[2] != "" and row[4] == "img":
            parts = row[2].split(",")
            for p in parts:
                if p not in mt:
                    if i%5 == 0 and i > 0:
                        cont += "\")\nset(MIMETYPE \"${MIMETYPE}"
                    cont += f"{p};"
                    i += 1
                    mt = np.append(mt, p)
    cont += "\")\n\nfile(APPEND \"org.photoqt.photoqt.desktop\" \"MimeType=${MIMETYPE}\")\n"

    f_new = open("output/add_to_ComposeDesktopFile.cmake", "w")
    f_new.write(cont)
    f_new.close()

#############################################################
#############################################################
# GENERATE WINDOWS RESOURCE FILE
if which == 'all' or which == 'windowsrc':

    print("Generating windows resource file...")

    conn = sqlite3.connect('icons/iconcolors.db')
    c = conn.cursor()

    c.execute("SELECT endings FROM colors ORDER BY endings")
    data = c.fetchall()

    cont = "IDI_ICON1               ICON    DISCARDABLE     \"windows/icon.ico\"\n";

    recorded = []

    iF = 2
    for row in data:

        endng = row[0].split(',')

        for e in endng:

            if e in recorded:
                continue
            recorded.append(e)

            cont += f"{iF}               ICON    DISCARDABLE     \"windows/filetypes/{e}.ico\"\n";

            iF += 1

    f_new = open("output/windowsicons.rc", "w")
    f_new.write(cont)
    f_new.close()


#############################################################
#############################################################
# GENERATE NSI ENTRIES
if which == 'all' or which == 'nsi':

    from datetime import datetime

    print("Generating new installer script...")
    print(" >> make sure to update the UnRegisterExtension calls for any changes in the previous version!")

    cont = """;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copyright (C) 2011-""" + str(datetime.now().year) + """ Lukas Spies
; Contact: http://photoqt.org
;
; This file is part of PhotoQt.
;
; PhotoQt is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 2 of the License, or
; (at your option) any later version.
;
; PhotoQt is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; In order to use this file, the following files need to be placed in the
; SAME DIRECTORY AS THE APPLICATION FILES:
;
; - AdvUninstLog.nsh
; - FileAssociation.nsh
; - icon_install.ico
; - icon.ico
; - license.txt
; - photoqt-setup.nsi (this file)
; - the windows/filetypes folder from the source tree
;
; In addition the EnVar plugin needs to be installed for NSIS:
; https://nsis.sourceforge.io/EnVar_plug-in
;
; This will then create a new file in the application directory
; called photoqt-xxx.exe where xxx is the version number specified below.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Unicode True

; modern ui
!include MUI2.nsh

; more flow control and logic
!include LogicLib.nsh

; allows creation of custom pages
!include nsDialogs.nsh

; macro for registering and unregistering file extensions
!include "FileAssociation.nsh"

; some main registry info, used for many things below
!define INSTDIR_REG_ROOT "HKLM"
!define INSTDIR_REG_KEY "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\PhotoQt"

;include the Uninstall log header
!include AdvUninstLog2.nsh

!define PHOTOQT_VERSION "xxx"

; name of project and installer filename
Name "PhotoQt"
OutFile "photoqt-${PHOTOQT_VERSION}.exe"

; this is a 64-bit program, thus install into 64-bit directory
InstallDir "$PROGRAMFILES64\\PhotoQt"
InstallDirRegKey ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "InstallDir"

; since we want to install into system location, request admin privileges
RequestExecutionLevel admin

; warn user on abort
!define MUI_ABORTWARNING

; a custom installer icon`
!define MUI_ICON "icon_install.ico"

; we have an interactive uninstall
!insertmacro UNATTENDED_UNINSTALL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Welcome page

!define MUI_WELCOMEPAGE_TITLE "Welcome to the installer of PhotoQt"

!define MUI_WELCOMEPAGE_TEXT "This installer will guide you through the installation of the PhotoQt. It is recommended that you close all other applications before starting the installer. $\\r$\\n$\\r$\\nIf you have any questions or concerns, please contact the developer through his website:$\\r$\\n$\\r$\\nhttps://photoqt.org$\\r$\\n$\\r$\\n$\\r$\\n Click Next to continue."


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Final page

!define MUI_FINISHPAGE_RUN "$INSTDIR/photoqt.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Open PhotoQt"

!define MUI_FINISHPAGE_LINK "PhotoQt website: https://photoqt.org"
!define MUI_FINISHPAGE_LINK_LOCATION "https://photoqt.org"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The order of pages

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "license.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
Page custom FinalStepsInit FinalStepsLeave
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES


; Set the language if the installer to English
; This has to come AFTER the list of pages above
!insertmacro MUI_LANGUAGE "English"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; List all the files and store some meta info

Section "PhotoQt" SecDummy

    ;The output path for where to install files to.
    SetOutPath "$INSTDIR"

    ;We start by removing existing files.
    !insertmacro UNINSTALL.NEW_PREUNINSTALL "$INSTDIR"

    ;Open the uninstall log file.
    !insertmacro UNINSTALL.LOG_OPEN_INSTALL

    ;Recursively add all the files.
    File /r /x *nsh /x *nsi /x *qmlc /x photoqt-setup.exe ".\\"

    ;Close the uninstall log.
    !insertmacro UNINSTALL.LOG_CLOSE_INSTALL

    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "InstallDir" "$INSTDIR"
    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "DisplayName" "PhotoQt"
    ;Same as create shortcut you need to use ${UNINST_EXE} instead of anything else.
    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "UninstallString" "${UNINST_EXE} /S"
    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "QuietUninstallString" "${UNINST_EXE} /S"
    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "DisplayVersion" "${PHOTOQT_VERSION}"
    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "Publisher" "Lukas Spies"

    IfSilent 0 +2
    Call FinalStepsLeave

SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function .onInit

    ;prepare log always within .onInit function
    !insertmacro UNINSTALL.LOG_PREPARE_INSTALL

FunctionEnd

Function .onInstSuccess

    ;create/update log always within .onInstSuccess function
    !insertmacro UNINSTALL.LOG_UPDATE_INSTALL

FunctionEnd


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ask the user whether to register for any filetypes

Var Dialog

Var LabelFiletypeDesc

Var RadioButtonNone
Var RadioButtonAll
Var RadioButtonAll_State

Var CheckboxPdfPs
Var CheckboxPdfPs_State
Var CheckboxPsdXcf
Var CheckboxPsdXcf_State

Var CheckboxStartMenu
Var CheckboxStartMenu_State
Var CheckboxDesktop
Var CheckboxDesktop_State

Function FinalStepsInit
    !insertmacro MUI_HEADER_TEXT "Finishing up" "$SMPROGRAMS\\$StartMenuFolder"

    nsDialogs::Create 1018
    Pop $Dialog
    ${If} $Dialog == error
        Abort
    ${EndIf}

    ${NSD_CreateLabel} 0 0 100% 18u "Here you can set PhotoQt as default application for all supported image formats. If you decide against this, then you can always still open any image from inside PhotoQt."
    Pop $LabelFiletypeDesc

    ${NSD_CreateRadioButton} 0 20u 100% 12u "Do not set as default for any image formats"
    Pop $RadioButtonNone
    ${NSD_OnClick} $RadioButtonNone FinalStepsDisEnable

    ${NSD_CreateRadioButton} 0 33u 100% 12u "Set as default for all supported image formats"
    Pop $RadioButtonAll
    ${NSD_Check} $RadioButtonAll
    ${NSD_OnClick} $RadioButtonAll FinalStepsDisEnable

    ${NSD_CreateCheckbox} 0 48u 100% 12u "Include PDF and PS"
    Pop $CheckboxPdfPs

    ${NSD_CreateCheckbox} 0 61u 100% 12u "Include PSD and XCF"
    Pop $CheckboxPsdXcf

    ${NSD_CreateHLine} 0 83u 100% 1u HLineBeforeDesktop

    ${NSD_CreateCheckbox} 0 88u 100% 12u "Create Desktop Icon"
    Pop $CheckboxDesktop

    ${NSD_CreateCheckbox} 0 103u 100% 12u "Create Start menu entry"
    Pop $CheckboxStartMenu
    ${NSD_Check} $CheckboxStartMenu

    nsDialogs::Show

FunctionEnd

; pdf/psd/xcf checkboxes are only enabled when PhotoQt is to be set as default
Function FinalStepsDisEnable

    ${NSD_GetState} $RadioButtonAll $RadioButtonAll_State
    ${If} $RadioButtonAll_State == ${BST_CHECKED}
        EnableWindow $CheckboxPdfPs 1
        EnableWindow $CheckboxPsdXcf 1
    ${Else}
        EnableWindow $CheckboxPdfPs 0
        EnableWindow $CheckboxPsdXcf 0
    ${EndIf}

FunctionEnd

; perform actions based on user choices
Function FinalStepsLeave

    SetShellVarContext all

    ${NSD_GetState} $RadioButtonAll $RadioButtonAll_State
    ${NSD_GetState} $CheckboxPdfPs $CheckboxPdfPs_State
    ${NSD_GetState} $CheckboxPsdXcf $CheckboxPsdXcf_State
    ${NSD_GetState} $CheckboxDesktop $CheckboxDesktop_State
    ${NSD_GetState} $CheckboxStartMenu $CheckboxStartMenu_State

    IfSilent 0 +3
    StrCpy $RadioButtonAll_State ${BST_CHECKED}
    StrCpy $CheckboxStartMenu_State ${BST_CHECKED}

    ; The file associations change over time. First we remove the old ones.
    ${UnRegisterExtension} "3fr" "3frfile"
    ${UnRegisterExtension} "fff" "ffffile"
    ${UnRegisterExtension} "aai" "aaifile"
    ${UnRegisterExtension} "ai" "aifile"
    ${UnRegisterExtension} "ani" "anifile"
    ${UnRegisterExtension} "apng" "apngfile"
    ${UnRegisterExtension} "ari" "arifile"
    ${UnRegisterExtension} "art" "artfile"
    ${UnRegisterExtension} "arw" "arwfile"
    ${UnRegisterExtension} "asf" "asffile"
    ${UnRegisterExtension} "avif" "aviffile"
    ${UnRegisterExtension} "avifs" "avifsfile"
    ${UnRegisterExtension} "avs" "avsfile"
    ${UnRegisterExtension} "x" "xfile"
    ${UnRegisterExtension} "mbfavs" "mbfavsfile"
    ${UnRegisterExtension} "bay" "bayfile"
    ${UnRegisterExtension} "bmp" "bmpfile"
    ${UnRegisterExtension} "dib" "dibfile"
    ${UnRegisterExtension} "bmq" "bmqfile"
    ${UnRegisterExtension} "bpg" "bpgfile"
    ${UnRegisterExtension} "cals" "calsfile"
    ${UnRegisterExtension} "ct1" "ct1file"
    ${UnRegisterExtension} "ct2" "ct2file"
    ${UnRegisterExtension} "ct3" "ct3file"
    ${UnRegisterExtension} "ct4" "ct4file"
    ${UnRegisterExtension} "c4" "c4file"
    ${UnRegisterExtension} "cal" "calfile"
    ${UnRegisterExtension} "nif" "niffile"
    ${UnRegisterExtension} "ras" "rasfile"
    ${UnRegisterExtension} "cap" "capfile"
    ${UnRegisterExtension} "eip" "eipfile"
    ${UnRegisterExtension} "liq" "liqfile"
    ${UnRegisterExtension} "iiq" "iiqfile"
    ${UnRegisterExtension} "cb7" "cb7file"
    ${UnRegisterExtension} "cbr" "cbrfile"
    ${UnRegisterExtension} "cbt" "cbtfile"
    ${UnRegisterExtension} "cbz" "cbzfile"
    ${UnRegisterExtension} "cg3" "cg3file"
    ${UnRegisterExtension} "g3" "g3file"
    ${UnRegisterExtension} "cine" "cinefile"
    ${UnRegisterExtension} "crw" "crwfile"
    ${UnRegisterExtension} "crr" "crrfile"
    ${UnRegisterExtension} "cr2" "cr2file"
    ${UnRegisterExtension} "cr3" "cr3file"
    ${UnRegisterExtension} "cs1" "cs1file"
    ${UnRegisterExtension} "cube" "cubefile"
    ${UnRegisterExtension} "cur" "curfile"
    ${UnRegisterExtension} "cut" "cutfile"
    ${UnRegisterExtension} "pal" "palfile"
    ${UnRegisterExtension} "dcr" "dcrfile"
    ${UnRegisterExtension} "kdc" "kdcfile"
    ${UnRegisterExtension} "drf" "drffile"
    ${UnRegisterExtension} "k25" "k25file"
    ${UnRegisterExtension} "dcs" "dcsfile"
    ${UnRegisterExtension} "dc2" "dc2file"
    ${UnRegisterExtension} "kc2" "kc2file"
    ${UnRegisterExtension} "dcx" "dcxfile"
    ${UnRegisterExtension} "dds" "ddsfile"
    ${UnRegisterExtension} "dfont" "dfontfile"
    ${UnRegisterExtension} "dic" "dicfile"
    ${UnRegisterExtension} "dcm" "dcmfile"
    ${UnRegisterExtension} "djvu" "djvufile"
    ${UnRegisterExtension} "djv" "djvfile"
    ${UnRegisterExtension} "dng" "dngfile"
    ${UnRegisterExtension} "dpx" "dpxfile"
    ${UnRegisterExtension} "dxo" "dxofile"
    ${UnRegisterExtension} "erf" "erffile"
    ${UnRegisterExtension} "exr" "exrfile"
    ${UnRegisterExtension} "ff" "fffile"
    ${UnRegisterExtension} "fits" "fitsfile"
    ${UnRegisterExtension} "fit" "fitfile"
    ${UnRegisterExtension} "fts" "ftsfile"
    ${UnRegisterExtension} "fl32" "fl32file"
    ${UnRegisterExtension} "ftx" "ftxfile"
    ${UnRegisterExtension} "gif" "giffile"
    ${UnRegisterExtension} "gpr" "gprfile"
    ${UnRegisterExtension} "heif" "heiffile"
    ${UnRegisterExtension} "heic" "heicfile"
    ${UnRegisterExtension} "hrz" "hrzfile"
    ${UnRegisterExtension} "icns" "icnsfile"
    ${UnRegisterExtension} "ico" "icofile"
    ${UnRegisterExtension} "iff" "ifffile"
    ${UnRegisterExtension} "jbig" "jbigfile"
    ${UnRegisterExtension} "jbg" "jbgfile"
    ${UnRegisterExtension} "bie" "biefile"
    ${UnRegisterExtension} "jfif" "jfiffile"
    ${UnRegisterExtension} "jng" "jngfile"
    ${UnRegisterExtension} "jpeg" "jpegfile"
    ${UnRegisterExtension} "jpg" "jpgfile"
    ${UnRegisterExtension} "jpe" "jpefile"
    ${UnRegisterExtension} "jif" "jiffile"
    ${UnRegisterExtension} "jpeg2000" "jpeg2000file"
    ${UnRegisterExtension} "j2k" "j2kfile"
    ${UnRegisterExtension} "jp2" "jp2file"
    ${UnRegisterExtension} "jpc" "jpcfile"
    ${UnRegisterExtension} "jpx" "jpxfile"
    ${UnRegisterExtension} "jxl" "jxlfile"
    ${UnRegisterExtension} "jxr" "jxrfile"
    ${UnRegisterExtension} "hdp" "hdpfile"
    ${UnRegisterExtension} "wdp" "wdpfile"
    ${UnRegisterExtension} "koa" "koafile"
    ${UnRegisterExtension} "gg" "ggfile"
    ${UnRegisterExtension} "gig" "gigfile"
    ${UnRegisterExtension} "kla" "klafile"
    ${UnRegisterExtension} "kra" "krafile"
    ${UnRegisterExtension} "lbm" "lbmfile"
    ${UnRegisterExtension} "mat" "matfile"
    ${UnRegisterExtension} "mdc" "mdcfile"
    ${UnRegisterExtension} "mef" "meffile"
    ${UnRegisterExtension} "mfw" "mfwfile"
    ${UnRegisterExtension} "miff" "mifffile"
    ${UnRegisterExtension} "mif" "miffile"
    ${UnRegisterExtension} "mng" "mngfile"
    ${UnRegisterExtension} "mos" "mosfile"
    ${UnRegisterExtension} "mpc" "mpcfile"
    ${UnRegisterExtension} "mtv" "mtvfile"
    ${UnRegisterExtension} "pic" "picfile"
    ${UnRegisterExtension} "mvg" "mvgfile"
    ${UnRegisterExtension} "nef" "neffile"
    ${UnRegisterExtension} "nrw" "nrwfile"
    ${UnRegisterExtension} "obm" "obmfile"
    ${UnRegisterExtension} "ora" "orafile"
    ${UnRegisterExtension} "orf" "orffile"
    ${UnRegisterExtension} "ori" "orifile"
    ${UnRegisterExtension} "otb" "otbfile"
    ${UnRegisterExtension} "otf" "otffile"
    ${UnRegisterExtension} "otc" "otcfile"
    ${UnRegisterExtension} "ttf" "ttffile"
    ${UnRegisterExtension} "ttc" "ttcfile"
    ${UnRegisterExtension} "p7" "p7file"
    ${UnRegisterExtension} "palm" "palmfile"
    ${UnRegisterExtension} "pam" "pamfile"
    ${UnRegisterExtension} "pbm" "pbmfile"
    ${UnRegisterExtension} "pcd" "pcdfile"
    ${UnRegisterExtension} "pcds" "pcdsfile"
    ${UnRegisterExtension} "pcx" "pcxfile"
    ${UnRegisterExtension} "pdb" "pdbfile"
    ${UnRegisterExtension} "pdd" "pddfile"
    ${UnRegisterExtension} "pef" "peffile"
    ${UnRegisterExtension} "ptx" "ptxfile"
    ${UnRegisterExtension} "pes" "pesfile"
    ${UnRegisterExtension} "pfb" "pfbfile"
    ${UnRegisterExtension} "pfm" "pfmfile"
    ${UnRegisterExtension} "afm" "afmfile"
    ${UnRegisterExtension} "inf" "inffile"
    ${UnRegisterExtension} "pfa" "pfafile"
    ${UnRegisterExtension} "ofm" "ofmfile"
    ${UnRegisterExtension} "pfm" "pfmfile"
    ${UnRegisterExtension} "pgm" "pgmfile"
    ${UnRegisterExtension} "pgx" "pgxfile"
    ${UnRegisterExtension} "phm" "phmfile"
    ${UnRegisterExtension} "pic" "picfile"
    ${UnRegisterExtension} "picon" "piconfile"
    ${UnRegisterExtension} "pict" "pictfile"
    ${UnRegisterExtension} "pct" "pctfile"
    ${UnRegisterExtension} "pic" "picfile"
    ${UnRegisterExtension} "pix" "pixfile"
    ${UnRegisterExtension} "als" "alsfile"
    ${UnRegisterExtension} "alias" "aliasfile"
    ${UnRegisterExtension} "png" "pngfile"
    ${UnRegisterExtension} "ppm" "ppmfile"
    ${UnRegisterExtension} "pnm" "pnmfile"
    ${UnRegisterExtension} "ptiff" "ptifffile"
    ${UnRegisterExtension} "ptif" "ptiffile"
    ${UnRegisterExtension} "pxn" "pxnfile"
    ${UnRegisterExtension} "pxr" "pxrfile"
    ${UnRegisterExtension} "qoi" "qoifile"
    ${UnRegisterExtension} "qtk" "qtkfile"
    ${UnRegisterExtension} "r3d" "r3dfile"
    ${UnRegisterExtension} "raf" "raffile"
    ${UnRegisterExtension} "raw" "rawfile"
    ${UnRegisterExtension} "rwl" "rwlfile"
    ${UnRegisterExtension} "rdc" "rdcfile"
    ${UnRegisterExtension} "rgba" "rgbafile"
    ${UnRegisterExtension} "rgb" "rgbfile"
    ${UnRegisterExtension} "sgi" "sgifile"
    ${UnRegisterExtension} "bw" "bwfile"
    ${UnRegisterExtension} "rgbe" "rgbefile"
    ${UnRegisterExtension} "hdr" "hdrfile"
    ${UnRegisterExtension} "rad" "radfile"
    ${UnRegisterExtension} "rgf" "rgffile"
    ${UnRegisterExtension} "rla" "rlafile"
    ${UnRegisterExtension} "rle" "rlefile"
    ${UnRegisterExtension} "rw2" "rw2file"
    ${UnRegisterExtension} "rwz" "rwzfile"
    ${UnRegisterExtension} "scr" "scrfile"
    ${UnRegisterExtension} "sct" "sctfile"
    ${UnRegisterExtension} "ch" "chfile"
    ${UnRegisterExtension} "ct" "ctfile"
    ${UnRegisterExtension} "sfw" "sfwfile"
    ${UnRegisterExtension} "alb" "albfile"
    ${UnRegisterExtension} "pwm" "pwmfile"
    ${UnRegisterExtension} "pwp" "pwpfile"
    ${UnRegisterExtension} "sixel" "sixelfile"
    ${UnRegisterExtension} "srf" "srffile"
    ${UnRegisterExtension} "mrw" "mrwfile"
    ${UnRegisterExtension} "sr2" "sr2file"
    ${UnRegisterExtension} "arq" "arqfile"
    ${UnRegisterExtension} "srw" "srwfile"
    ${UnRegisterExtension} "sti" "stifile"
    ${UnRegisterExtension} "sun" "sunfile"
    ${UnRegisterExtension} "ras" "rasfile"
    ${UnRegisterExtension} "sr" "srfile"
    ${UnRegisterExtension} "im1" "im1file"
    ${UnRegisterExtension} "im24" "im24file"
    ${UnRegisterExtension} "im32" "im32file"
    ${UnRegisterExtension} "im8" "im8file"
    ${UnRegisterExtension} "rast" "rastfile"
    ${UnRegisterExtension} "rs" "rsfile"
    ${UnRegisterExtension} "scr" "scrfile"
    ${UnRegisterExtension} "svg" "svgfile"
    ${UnRegisterExtension} "svgz" "svgzfile"
    ${UnRegisterExtension} "tar" "tarfile"
    ${UnRegisterExtension} "tga" "tgafile"
    ${UnRegisterExtension} "icb" "icbfile"
    ${UnRegisterExtension} "vda" "vdafile"
    ${UnRegisterExtension} "vst" "vstfile"
    ${UnRegisterExtension} "tiff" "tifffile"
    ${UnRegisterExtension} "tif" "tiffile"
    ${UnRegisterExtension} "tim" "timfile"
    ${UnRegisterExtension} "ttf" "ttffile"
    ${UnRegisterExtension} "vicar" "vicarfile"
    ${UnRegisterExtension} "vic" "vicfile"
    ${UnRegisterExtension} "img" "imgfile"
    ${UnRegisterExtension} "viff" "vifffile"
    ${UnRegisterExtension} "xv" "xvfile"
    ${UnRegisterExtension} "vtf" "vtffile"
    ${UnRegisterExtension} "wbmp" "wbmpfile"
    ${UnRegisterExtension} "webp" "webpfile"
    ${UnRegisterExtension} "wmf" "wmffile"
    ${UnRegisterExtension} "wmz" "wmzfile"
    ${UnRegisterExtension} "apm" "apmfile"
    ${UnRegisterExtension} "wpg" "wpgfile"
    ${UnRegisterExtension} "x3f" "x3ffile"
    ${UnRegisterExtension} "xbm" "xbmfile"
    ${UnRegisterExtension} "bm" "bmfile"
    ${UnRegisterExtension} "xpm" "xpmfile"
    ${UnRegisterExtension} "pm" "pmfile"
    ${UnRegisterExtension} "xwd" "xwdfile"
    ${UnRegisterExtension} "eps" "epsfile"
    ${UnRegisterExtension} "epsf" "epsffile"
    ${UnRegisterExtension} "epsi" "epsifile"
    ${UnRegisterExtension} "pdf" "pdffile"
    ${UnRegisterExtension} "ps" "psfile"
    ${UnRegisterExtension} "ps2" "ps2file"
    ${UnRegisterExtension} "ps3" "ps3file"
    ${UnRegisterExtension} "psd" "psdfile"
    ${UnRegisterExtension} "psb" "psbfile"
    ${UnRegisterExtension} "psdt" "psdtfile"
    ${UnRegisterExtension} "xcf" "xcffile"

    ${UnRegisterExtensionOld} "3fr" "3frfile"
    ${UnRegisterExtensionOld} "fff" "ffffile"
    ${UnRegisterExtensionOld} "aai" "aaifile"
    ${UnRegisterExtensionOld} "ai" "aifile"
    ${UnRegisterExtensionOld} "ani" "anifile"
    ${UnRegisterExtensionOld} "apng" "apngfile"
    ${UnRegisterExtensionOld} "ari" "arifile"
    ${UnRegisterExtensionOld} "art" "artfile"
    ${UnRegisterExtensionOld} "arw" "arwfile"
    ${UnRegisterExtensionOld} "asf" "asffile"
    ${UnRegisterExtensionOld} "avif" "aviffile"
    ${UnRegisterExtensionOld} "avifs" "avifsfile"
    ${UnRegisterExtensionOld} "avs" "avsfile"
    ${UnRegisterExtensionOld} "x" "xfile"
    ${UnRegisterExtensionOld} "mbfavs" "mbfavsfile"
    ${UnRegisterExtensionOld} "bay" "bayfile"
    ${UnRegisterExtensionOld} "bmp" "bmpfile"
    ${UnRegisterExtensionOld} "dib" "dibfile"
    ${UnRegisterExtensionOld} "bmq" "bmqfile"
    ${UnRegisterExtensionOld} "bpg" "bpgfile"
    ${UnRegisterExtensionOld} "cals" "calsfile"
    ${UnRegisterExtensionOld} "ct1" "ct1file"
    ${UnRegisterExtensionOld} "ct2" "ct2file"
    ${UnRegisterExtensionOld} "ct3" "ct3file"
    ${UnRegisterExtensionOld} "ct4" "ct4file"
    ${UnRegisterExtensionOld} "c4" "c4file"
    ${UnRegisterExtensionOld} "cal" "calfile"
    ${UnRegisterExtensionOld} "nif" "niffile"
    ${UnRegisterExtensionOld} "ras" "rasfile"
    ${UnRegisterExtensionOld} "cap" "capfile"
    ${UnRegisterExtensionOld} "eip" "eipfile"
    ${UnRegisterExtensionOld} "liq" "liqfile"
    ${UnRegisterExtensionOld} "iiq" "iiqfile"
    ${UnRegisterExtensionOld} "cb7" "cb7file"
    ${UnRegisterExtensionOld} "cbr" "cbrfile"
    ${UnRegisterExtensionOld} "cbt" "cbtfile"
    ${UnRegisterExtensionOld} "cbz" "cbzfile"
    ${UnRegisterExtensionOld} "cg3" "cg3file"
    ${UnRegisterExtensionOld} "g3" "g3file"
    ${UnRegisterExtensionOld} "cine" "cinefile"
    ${UnRegisterExtensionOld} "crw" "crwfile"
    ${UnRegisterExtensionOld} "crr" "crrfile"
    ${UnRegisterExtensionOld} "cr2" "cr2file"
    ${UnRegisterExtensionOld} "cr3" "cr3file"
    ${UnRegisterExtensionOld} "cs1" "cs1file"
    ${UnRegisterExtensionOld} "cube" "cubefile"
    ${UnRegisterExtensionOld} "cur" "curfile"
    ${UnRegisterExtensionOld} "cut" "cutfile"
    ${UnRegisterExtensionOld} "pal" "palfile"
    ${UnRegisterExtensionOld} "dcr" "dcrfile"
    ${UnRegisterExtensionOld} "kdc" "kdcfile"
    ${UnRegisterExtensionOld} "drf" "drffile"
    ${UnRegisterExtensionOld} "k25" "k25file"
    ${UnRegisterExtensionOld} "dcs" "dcsfile"
    ${UnRegisterExtensionOld} "dc2" "dc2file"
    ${UnRegisterExtensionOld} "kc2" "kc2file"
    ${UnRegisterExtensionOld} "dcx" "dcxfile"
    ${UnRegisterExtensionOld} "dds" "ddsfile"
    ${UnRegisterExtensionOld} "dfont" "dfontfile"
    ${UnRegisterExtensionOld} "dic" "dicfile"
    ${UnRegisterExtensionOld} "dcm" "dcmfile"
    ${UnRegisterExtensionOld} "djvu" "djvufile"
    ${UnRegisterExtensionOld} "djv" "djvfile"
    ${UnRegisterExtensionOld} "dng" "dngfile"
    ${UnRegisterExtensionOld} "dpx" "dpxfile"
    ${UnRegisterExtensionOld} "dxo" "dxofile"
    ${UnRegisterExtensionOld} "erf" "erffile"
    ${UnRegisterExtensionOld} "exr" "exrfile"
    ${UnRegisterExtensionOld} "ff" "fffile"
    ${UnRegisterExtensionOld} "fits" "fitsfile"
    ${UnRegisterExtensionOld} "fit" "fitfile"
    ${UnRegisterExtensionOld} "fts" "ftsfile"
    ${UnRegisterExtensionOld} "fl32" "fl32file"
    ${UnRegisterExtensionOld} "ftx" "ftxfile"
    ${UnRegisterExtensionOld} "gif" "giffile"
    ${UnRegisterExtensionOld} "gpr" "gprfile"
    ${UnRegisterExtensionOld} "heif" "heiffile"
    ${UnRegisterExtensionOld} "heic" "heicfile"
    ${UnRegisterExtensionOld} "hrz" "hrzfile"
    ${UnRegisterExtensionOld} "icns" "icnsfile"
    ${UnRegisterExtensionOld} "ico" "icofile"
    ${UnRegisterExtensionOld} "iff" "ifffile"
    ${UnRegisterExtensionOld} "jbig" "jbigfile"
    ${UnRegisterExtensionOld} "jbg" "jbgfile"
    ${UnRegisterExtensionOld} "bie" "biefile"
    ${UnRegisterExtensionOld} "jfif" "jfiffile"
    ${UnRegisterExtensionOld} "jng" "jngfile"
    ${UnRegisterExtensionOld} "jpeg" "jpegfile"
    ${UnRegisterExtensionOld} "jpg" "jpgfile"
    ${UnRegisterExtensionOld} "jpe" "jpefile"
    ${UnRegisterExtensionOld} "jif" "jiffile"
    ${UnRegisterExtensionOld} "jpeg2000" "jpeg2000file"
    ${UnRegisterExtensionOld} "j2k" "j2kfile"
    ${UnRegisterExtensionOld} "jp2" "jp2file"
    ${UnRegisterExtensionOld} "jpc" "jpcfile"
    ${UnRegisterExtensionOld} "jpx" "jpxfile"
    ${UnRegisterExtensionOld} "jxl" "jxlfile"
    ${UnRegisterExtensionOld} "jxr" "jxrfile"
    ${UnRegisterExtensionOld} "hdp" "hdpfile"
    ${UnRegisterExtensionOld} "wdp" "wdpfile"
    ${UnRegisterExtensionOld} "koa" "koafile"
    ${UnRegisterExtensionOld} "gg" "ggfile"
    ${UnRegisterExtensionOld} "gig" "gigfile"
    ${UnRegisterExtensionOld} "kla" "klafile"
    ${UnRegisterExtensionOld} "kra" "krafile"
    ${UnRegisterExtensionOld} "lbm" "lbmfile"
    ${UnRegisterExtensionOld} "mat" "matfile"
    ${UnRegisterExtensionOld} "mdc" "mdcfile"
    ${UnRegisterExtensionOld} "mef" "meffile"
    ${UnRegisterExtensionOld} "mfw" "mfwfile"
    ${UnRegisterExtensionOld} "miff" "mifffile"
    ${UnRegisterExtensionOld} "mif" "miffile"
    ${UnRegisterExtensionOld} "mng" "mngfile"
    ${UnRegisterExtensionOld} "mos" "mosfile"
    ${UnRegisterExtensionOld} "mpc" "mpcfile"
    ${UnRegisterExtensionOld} "mtv" "mtvfile"
    ${UnRegisterExtensionOld} "pic" "picfile"
    ${UnRegisterExtensionOld} "mvg" "mvgfile"
    ${UnRegisterExtensionOld} "nef" "neffile"
    ${UnRegisterExtensionOld} "nrw" "nrwfile"
    ${UnRegisterExtensionOld} "obm" "obmfile"
    ${UnRegisterExtensionOld} "ora" "orafile"
    ${UnRegisterExtensionOld} "orf" "orffile"
    ${UnRegisterExtensionOld} "ori" "orifile"
    ${UnRegisterExtensionOld} "otb" "otbfile"
    ${UnRegisterExtensionOld} "otf" "otffile"
    ${UnRegisterExtensionOld} "otc" "otcfile"
    ${UnRegisterExtensionOld} "ttf" "ttffile"
    ${UnRegisterExtensionOld} "ttc" "ttcfile"
    ${UnRegisterExtensionOld} "p7" "p7file"
    ${UnRegisterExtensionOld} "palm" "palmfile"
    ${UnRegisterExtensionOld} "pam" "pamfile"
    ${UnRegisterExtensionOld} "pbm" "pbmfile"
    ${UnRegisterExtensionOld} "pcd" "pcdfile"
    ${UnRegisterExtensionOld} "pcds" "pcdsfile"
    ${UnRegisterExtensionOld} "pcx" "pcxfile"
    ${UnRegisterExtensionOld} "pdb" "pdbfile"
    ${UnRegisterExtensionOld} "pdd" "pddfile"
    ${UnRegisterExtensionOld} "pef" "peffile"
    ${UnRegisterExtensionOld} "ptx" "ptxfile"
    ${UnRegisterExtensionOld} "pes" "pesfile"
    ${UnRegisterExtensionOld} "pfb" "pfbfile"
    ${UnRegisterExtensionOld} "pfm" "pfmfile"
    ${UnRegisterExtensionOld} "afm" "afmfile"
    ${UnRegisterExtensionOld} "inf" "inffile"
    ${UnRegisterExtensionOld} "pfa" "pfafile"
    ${UnRegisterExtensionOld} "ofm" "ofmfile"
    ${UnRegisterExtensionOld} "pfm" "pfmfile"
    ${UnRegisterExtensionOld} "pgm" "pgmfile"
    ${UnRegisterExtensionOld} "pgx" "pgxfile"
    ${UnRegisterExtensionOld} "phm" "phmfile"
    ${UnRegisterExtensionOld} "pic" "picfile"
    ${UnRegisterExtensionOld} "picon" "piconfile"
    ${UnRegisterExtensionOld} "pict" "pictfile"
    ${UnRegisterExtensionOld} "pct" "pctfile"
    ${UnRegisterExtensionOld} "pic" "picfile"
    ${UnRegisterExtensionOld} "pix" "pixfile"
    ${UnRegisterExtensionOld} "als" "alsfile"
    ${UnRegisterExtensionOld} "alias" "aliasfile"
    ${UnRegisterExtensionOld} "png" "pngfile"
    ${UnRegisterExtensionOld} "ppm" "ppmfile"
    ${UnRegisterExtensionOld} "pnm" "pnmfile"
    ${UnRegisterExtensionOld} "ptiff" "ptifffile"
    ${UnRegisterExtensionOld} "ptif" "ptiffile"
    ${UnRegisterExtensionOld} "pxn" "pxnfile"
    ${UnRegisterExtensionOld} "pxr" "pxrfile"
    ${UnRegisterExtensionOld} "qoi" "qoifile"
    ${UnRegisterExtensionOld} "qtk" "qtkfile"
    ${UnRegisterExtensionOld} "r3d" "r3dfile"
    ${UnRegisterExtensionOld} "raf" "raffile"
    ${UnRegisterExtensionOld} "raw" "rawfile"
    ${UnRegisterExtensionOld} "rwl" "rwlfile"
    ${UnRegisterExtensionOld} "rdc" "rdcfile"
    ${UnRegisterExtensionOld} "rgba" "rgbafile"
    ${UnRegisterExtensionOld} "rgb" "rgbfile"
    ${UnRegisterExtensionOld} "sgi" "sgifile"
    ${UnRegisterExtensionOld} "bw" "bwfile"
    ${UnRegisterExtensionOld} "rgbe" "rgbefile"
    ${UnRegisterExtensionOld} "hdr" "hdrfile"
    ${UnRegisterExtensionOld} "rad" "radfile"
    ${UnRegisterExtensionOld} "rgf" "rgffile"
    ${UnRegisterExtensionOld} "rla" "rlafile"
    ${UnRegisterExtensionOld} "rle" "rlefile"
    ${UnRegisterExtensionOld} "rw2" "rw2file"
    ${UnRegisterExtensionOld} "rwz" "rwzfile"
    ${UnRegisterExtensionOld} "scr" "scrfile"
    ${UnRegisterExtensionOld} "sct" "sctfile"
    ${UnRegisterExtensionOld} "ch" "chfile"
    ${UnRegisterExtensionOld} "ct" "ctfile"
    ${UnRegisterExtensionOld} "sfw" "sfwfile"
    ${UnRegisterExtensionOld} "alb" "albfile"
    ${UnRegisterExtensionOld} "pwm" "pwmfile"
    ${UnRegisterExtensionOld} "pwp" "pwpfile"
    ${UnRegisterExtensionOld} "sixel" "sixelfile"
    ${UnRegisterExtensionOld} "srf" "srffile"
    ${UnRegisterExtensionOld} "mrw" "mrwfile"
    ${UnRegisterExtensionOld} "sr2" "sr2file"
    ${UnRegisterExtensionOld} "arq" "arqfile"
    ${UnRegisterExtensionOld} "srw" "srwfile"
    ${UnRegisterExtensionOld} "sti" "stifile"
    ${UnRegisterExtensionOld} "sun" "sunfile"
    ${UnRegisterExtensionOld} "ras" "rasfile"
    ${UnRegisterExtensionOld} "sr" "srfile"
    ${UnRegisterExtensionOld} "im1" "im1file"
    ${UnRegisterExtensionOld} "im24" "im24file"
    ${UnRegisterExtensionOld} "im32" "im32file"
    ${UnRegisterExtensionOld} "im8" "im8file"
    ${UnRegisterExtensionOld} "rast" "rastfile"
    ${UnRegisterExtensionOld} "rs" "rsfile"
    ${UnRegisterExtensionOld} "scr" "scrfile"
    ${UnRegisterExtensionOld} "svg" "svgfile"
    ${UnRegisterExtensionOld} "svgz" "svgzfile"
    ${UnRegisterExtensionOld} "tar" "tarfile"
    ${UnRegisterExtensionOld} "tga" "tgafile"
    ${UnRegisterExtensionOld} "icb" "icbfile"
    ${UnRegisterExtensionOld} "vda" "vdafile"
    ${UnRegisterExtensionOld} "vst" "vstfile"
    ${UnRegisterExtensionOld} "tiff" "tifffile"
    ${UnRegisterExtensionOld} "tif" "tiffile"
    ${UnRegisterExtensionOld} "tim" "timfile"
    ${UnRegisterExtensionOld} "ttf" "ttffile"
    ${UnRegisterExtensionOld} "vicar" "vicarfile"
    ${UnRegisterExtensionOld} "vic" "vicfile"
    ${UnRegisterExtensionOld} "img" "imgfile"
    ${UnRegisterExtensionOld} "viff" "vifffile"
    ${UnRegisterExtensionOld} "xv" "xvfile"
    ${UnRegisterExtensionOld} "vtf" "vtffile"
    ${UnRegisterExtensionOld} "wbmp" "wbmpfile"
    ${UnRegisterExtensionOld} "webp" "webpfile"
    ${UnRegisterExtensionOld} "wmf" "wmffile"
    ${UnRegisterExtensionOld} "wmz" "wmzfile"
    ${UnRegisterExtensionOld} "apm" "apmfile"
    ${UnRegisterExtensionOld} "wpg" "wpgfile"
    ${UnRegisterExtensionOld} "x3f" "x3ffile"
    ${UnRegisterExtensionOld} "xbm" "xbmfile"
    ${UnRegisterExtensionOld} "bm" "bmfile"
    ${UnRegisterExtensionOld} "xpm" "xpmfile"
    ${UnRegisterExtensionOld} "pm" "pmfile"
    ${UnRegisterExtensionOld} "xwd" "xwdfile"
    ${UnRegisterExtensionOld} "eps" "epsfile"
    ${UnRegisterExtensionOld} "epsf" "epsffile"
    ${UnRegisterExtensionOld} "epsi" "epsifile"
    ${UnRegisterExtensionOld} "pdf" "pdffile"
    ${UnRegisterExtensionOld} "ps" "psfile"
    ${UnRegisterExtensionOld} "ps2" "ps2file"
    ${UnRegisterExtensionOld} "ps3" "ps3file"
    ${UnRegisterExtensionOld} "psd" "psdfile"
    ${UnRegisterExtensionOld} "psb" "psbfile"
    ${UnRegisterExtensionOld} "psdt" "psdtfile"
    ${UnRegisterExtensionOld} "xcf" "xcffile"

    ${UnRegisterExtensionApostrophe} "3fr" "3frfile"
    ${UnRegisterExtensionApostrophe} "fff" "ffffile"
    ${UnRegisterExtensionApostrophe} "aai" "aaifile"
    ${UnRegisterExtensionApostrophe} "ai" "aifile"
    ${UnRegisterExtensionApostrophe} "ani" "anifile"
    ${UnRegisterExtensionApostrophe} "apng" "apngfile"
    ${UnRegisterExtensionApostrophe} "ari" "arifile"
    ${UnRegisterExtensionApostrophe} "art" "artfile"
    ${UnRegisterExtensionApostrophe} "arw" "arwfile"
    ${UnRegisterExtensionApostrophe} "asf" "asffile"
    ${UnRegisterExtensionApostrophe} "avif" "aviffile"
    ${UnRegisterExtensionApostrophe} "avifs" "avifsfile"
    ${UnRegisterExtensionApostrophe} "avs" "avsfile"
    ${UnRegisterExtensionApostrophe} "x" "xfile"
    ${UnRegisterExtensionApostrophe} "mbfavs" "mbfavsfile"
    ${UnRegisterExtensionApostrophe} "bay" "bayfile"
    ${UnRegisterExtensionApostrophe} "bmp" "bmpfile"
    ${UnRegisterExtensionApostrophe} "dib" "dibfile"
    ${UnRegisterExtensionApostrophe} "bmq" "bmqfile"
    ${UnRegisterExtensionApostrophe} "bpg" "bpgfile"
    ${UnRegisterExtensionApostrophe} "cals" "calsfile"
    ${UnRegisterExtensionApostrophe} "ct1" "ct1file"
    ${UnRegisterExtensionApostrophe} "ct2" "ct2file"
    ${UnRegisterExtensionApostrophe} "ct3" "ct3file"
    ${UnRegisterExtensionApostrophe} "ct4" "ct4file"
    ${UnRegisterExtensionApostrophe} "c4" "c4file"
    ${UnRegisterExtensionApostrophe} "cal" "calfile"
    ${UnRegisterExtensionApostrophe} "nif" "niffile"
    ${UnRegisterExtensionApostrophe} "ras" "rasfile"
    ${UnRegisterExtensionApostrophe} "cap" "capfile"
    ${UnRegisterExtensionApostrophe} "eip" "eipfile"
    ${UnRegisterExtensionApostrophe} "liq" "liqfile"
    ${UnRegisterExtensionApostrophe} "iiq" "iiqfile"
    ${UnRegisterExtensionApostrophe} "cb7" "cb7file"
    ${UnRegisterExtensionApostrophe} "cbr" "cbrfile"
    ${UnRegisterExtensionApostrophe} "cbt" "cbtfile"
    ${UnRegisterExtensionApostrophe} "cbz" "cbzfile"
    ${UnRegisterExtensionApostrophe} "cg3" "cg3file"
    ${UnRegisterExtensionApostrophe} "g3" "g3file"
    ${UnRegisterExtensionApostrophe} "cine" "cinefile"
    ${UnRegisterExtensionApostrophe} "crw" "crwfile"
    ${UnRegisterExtensionApostrophe} "crr" "crrfile"
    ${UnRegisterExtensionApostrophe} "cr2" "cr2file"
    ${UnRegisterExtensionApostrophe} "cr3" "cr3file"
    ${UnRegisterExtensionApostrophe} "cs1" "cs1file"
    ${UnRegisterExtensionApostrophe} "cube" "cubefile"
    ${UnRegisterExtensionApostrophe} "cur" "curfile"
    ${UnRegisterExtensionApostrophe} "cut" "cutfile"
    ${UnRegisterExtensionApostrophe} "pal" "palfile"
    ${UnRegisterExtensionApostrophe} "dcr" "dcrfile"
    ${UnRegisterExtensionApostrophe} "kdc" "kdcfile"
    ${UnRegisterExtensionApostrophe} "drf" "drffile"
    ${UnRegisterExtensionApostrophe} "k25" "k25file"
    ${UnRegisterExtensionApostrophe} "dcs" "dcsfile"
    ${UnRegisterExtensionApostrophe} "dc2" "dc2file"
    ${UnRegisterExtensionApostrophe} "kc2" "kc2file"
    ${UnRegisterExtensionApostrophe} "dcx" "dcxfile"
    ${UnRegisterExtensionApostrophe} "dds" "ddsfile"
    ${UnRegisterExtensionApostrophe} "dfont" "dfontfile"
    ${UnRegisterExtensionApostrophe} "dic" "dicfile"
    ${UnRegisterExtensionApostrophe} "dcm" "dcmfile"
    ${UnRegisterExtensionApostrophe} "djvu" "djvufile"
    ${UnRegisterExtensionApostrophe} "djv" "djvfile"
    ${UnRegisterExtensionApostrophe} "dng" "dngfile"
    ${UnRegisterExtensionApostrophe} "dpx" "dpxfile"
    ${UnRegisterExtensionApostrophe} "dxo" "dxofile"
    ${UnRegisterExtensionApostrophe} "erf" "erffile"
    ${UnRegisterExtensionApostrophe} "exr" "exrfile"
    ${UnRegisterExtensionApostrophe} "ff" "fffile"
    ${UnRegisterExtensionApostrophe} "fits" "fitsfile"
    ${UnRegisterExtensionApostrophe} "fit" "fitfile"
    ${UnRegisterExtensionApostrophe} "fts" "ftsfile"
    ${UnRegisterExtensionApostrophe} "fl32" "fl32file"
    ${UnRegisterExtensionApostrophe} "ftx" "ftxfile"
    ${UnRegisterExtensionApostrophe} "gif" "giffile"
    ${UnRegisterExtensionApostrophe} "gpr" "gprfile"
    ${UnRegisterExtensionApostrophe} "heif" "heiffile"
    ${UnRegisterExtensionApostrophe} "heic" "heicfile"
    ${UnRegisterExtensionApostrophe} "hrz" "hrzfile"
    ${UnRegisterExtensionApostrophe} "icns" "icnsfile"
    ${UnRegisterExtensionApostrophe} "ico" "icofile"
    ${UnRegisterExtensionApostrophe} "iff" "ifffile"
    ${UnRegisterExtensionApostrophe} "jbig" "jbigfile"
    ${UnRegisterExtensionApostrophe} "jbg" "jbgfile"
    ${UnRegisterExtensionApostrophe} "bie" "biefile"
    ${UnRegisterExtensionApostrophe} "jfif" "jfiffile"
    ${UnRegisterExtensionApostrophe} "jng" "jngfile"
    ${UnRegisterExtensionApostrophe} "jpeg" "jpegfile"
    ${UnRegisterExtensionApostrophe} "jpg" "jpgfile"
    ${UnRegisterExtensionApostrophe} "jpe" "jpefile"
    ${UnRegisterExtensionApostrophe} "jif" "jiffile"
    ${UnRegisterExtensionApostrophe} "jpeg2000" "jpeg2000file"
    ${UnRegisterExtensionApostrophe} "j2k" "j2kfile"
    ${UnRegisterExtensionApostrophe} "jp2" "jp2file"
    ${UnRegisterExtensionApostrophe} "jpc" "jpcfile"
    ${UnRegisterExtensionApostrophe} "jpx" "jpxfile"
    ${UnRegisterExtensionApostrophe} "jxl" "jxlfile"
    ${UnRegisterExtensionApostrophe} "jxr" "jxrfile"
    ${UnRegisterExtensionApostrophe} "hdp" "hdpfile"
    ${UnRegisterExtensionApostrophe} "wdp" "wdpfile"
    ${UnRegisterExtensionApostrophe} "koa" "koafile"
    ${UnRegisterExtensionApostrophe} "gg" "ggfile"
    ${UnRegisterExtensionApostrophe} "gig" "gigfile"
    ${UnRegisterExtensionApostrophe} "kla" "klafile"
    ${UnRegisterExtensionApostrophe} "kra" "krafile"
    ${UnRegisterExtensionApostrophe} "lbm" "lbmfile"
    ${UnRegisterExtensionApostrophe} "mat" "matfile"
    ${UnRegisterExtensionApostrophe} "mdc" "mdcfile"
    ${UnRegisterExtensionApostrophe} "mef" "meffile"
    ${UnRegisterExtensionApostrophe} "mfw" "mfwfile"
    ${UnRegisterExtensionApostrophe} "miff" "mifffile"
    ${UnRegisterExtensionApostrophe} "mif" "miffile"
    ${UnRegisterExtensionApostrophe} "mng" "mngfile"
    ${UnRegisterExtensionApostrophe} "mos" "mosfile"
    ${UnRegisterExtensionApostrophe} "mpc" "mpcfile"
    ${UnRegisterExtensionApostrophe} "mtv" "mtvfile"
    ${UnRegisterExtensionApostrophe} "pic" "picfile"
    ${UnRegisterExtensionApostrophe} "mvg" "mvgfile"
    ${UnRegisterExtensionApostrophe} "nef" "neffile"
    ${UnRegisterExtensionApostrophe} "nrw" "nrwfile"
    ${UnRegisterExtensionApostrophe} "obm" "obmfile"
    ${UnRegisterExtensionApostrophe} "ora" "orafile"
    ${UnRegisterExtensionApostrophe} "orf" "orffile"
    ${UnRegisterExtensionApostrophe} "ori" "orifile"
    ${UnRegisterExtensionApostrophe} "otb" "otbfile"
    ${UnRegisterExtensionApostrophe} "otf" "otffile"
    ${UnRegisterExtensionApostrophe} "otc" "otcfile"
    ${UnRegisterExtensionApostrophe} "ttf" "ttffile"
    ${UnRegisterExtensionApostrophe} "ttc" "ttcfile"
    ${UnRegisterExtensionApostrophe} "p7" "p7file"
    ${UnRegisterExtensionApostrophe} "palm" "palmfile"
    ${UnRegisterExtensionApostrophe} "pam" "pamfile"
    ${UnRegisterExtensionApostrophe} "pbm" "pbmfile"
    ${UnRegisterExtensionApostrophe} "pcd" "pcdfile"
    ${UnRegisterExtensionApostrophe} "pcds" "pcdsfile"
    ${UnRegisterExtensionApostrophe} "pcx" "pcxfile"
    ${UnRegisterExtensionApostrophe} "pdb" "pdbfile"
    ${UnRegisterExtensionApostrophe} "pdd" "pddfile"
    ${UnRegisterExtensionApostrophe} "pef" "peffile"
    ${UnRegisterExtensionApostrophe} "ptx" "ptxfile"
    ${UnRegisterExtensionApostrophe} "pes" "pesfile"
    ${UnRegisterExtensionApostrophe} "pfb" "pfbfile"
    ${UnRegisterExtensionApostrophe} "pfm" "pfmfile"
    ${UnRegisterExtensionApostrophe} "afm" "afmfile"
    ${UnRegisterExtensionApostrophe} "inf" "inffile"
    ${UnRegisterExtensionApostrophe} "pfa" "pfafile"
    ${UnRegisterExtensionApostrophe} "ofm" "ofmfile"
    ${UnRegisterExtensionApostrophe} "pfm" "pfmfile"
    ${UnRegisterExtensionApostrophe} "pgm" "pgmfile"
    ${UnRegisterExtensionApostrophe} "pgx" "pgxfile"
    ${UnRegisterExtensionApostrophe} "phm" "phmfile"
    ${UnRegisterExtensionApostrophe} "pic" "picfile"
    ${UnRegisterExtensionApostrophe} "picon" "piconfile"
    ${UnRegisterExtensionApostrophe} "pict" "pictfile"
    ${UnRegisterExtensionApostrophe} "pct" "pctfile"
    ${UnRegisterExtensionApostrophe} "pic" "picfile"
    ${UnRegisterExtensionApostrophe} "pix" "pixfile"
    ${UnRegisterExtensionApostrophe} "als" "alsfile"
    ${UnRegisterExtensionApostrophe} "alias" "aliasfile"
    ${UnRegisterExtensionApostrophe} "png" "pngfile"
    ${UnRegisterExtensionApostrophe} "ppm" "ppmfile"
    ${UnRegisterExtensionApostrophe} "pnm" "pnmfile"
    ${UnRegisterExtensionApostrophe} "ptiff" "ptifffile"
    ${UnRegisterExtensionApostrophe} "ptif" "ptiffile"
    ${UnRegisterExtensionApostrophe} "pxn" "pxnfile"
    ${UnRegisterExtensionApostrophe} "pxr" "pxrfile"
    ${UnRegisterExtensionApostrophe} "qoi" "qoifile"
    ${UnRegisterExtensionApostrophe} "qtk" "qtkfile"
    ${UnRegisterExtensionApostrophe} "r3d" "r3dfile"
    ${UnRegisterExtensionApostrophe} "raf" "raffile"
    ${UnRegisterExtensionApostrophe} "raw" "rawfile"
    ${UnRegisterExtensionApostrophe} "rwl" "rwlfile"
    ${UnRegisterExtensionApostrophe} "rdc" "rdcfile"
    ${UnRegisterExtensionApostrophe} "rgba" "rgbafile"
    ${UnRegisterExtensionApostrophe} "rgb" "rgbfile"
    ${UnRegisterExtensionApostrophe} "sgi" "sgifile"
    ${UnRegisterExtensionApostrophe} "bw" "bwfile"
    ${UnRegisterExtensionApostrophe} "rgbe" "rgbefile"
    ${UnRegisterExtensionApostrophe} "hdr" "hdrfile"
    ${UnRegisterExtensionApostrophe} "rad" "radfile"
    ${UnRegisterExtensionApostrophe} "rgf" "rgffile"
    ${UnRegisterExtensionApostrophe} "rla" "rlafile"
    ${UnRegisterExtensionApostrophe} "rle" "rlefile"
    ${UnRegisterExtensionApostrophe} "rw2" "rw2file"
    ${UnRegisterExtensionApostrophe} "rwz" "rwzfile"
    ${UnRegisterExtensionApostrophe} "scr" "scrfile"
    ${UnRegisterExtensionApostrophe} "sct" "sctfile"
    ${UnRegisterExtensionApostrophe} "ch" "chfile"
    ${UnRegisterExtensionApostrophe} "ct" "ctfile"
    ${UnRegisterExtensionApostrophe} "sfw" "sfwfile"
    ${UnRegisterExtensionApostrophe} "alb" "albfile"
    ${UnRegisterExtensionApostrophe} "pwm" "pwmfile"
    ${UnRegisterExtensionApostrophe} "pwp" "pwpfile"
    ${UnRegisterExtensionApostrophe} "sixel" "sixelfile"
    ${UnRegisterExtensionApostrophe} "srf" "srffile"
    ${UnRegisterExtensionApostrophe} "mrw" "mrwfile"
    ${UnRegisterExtensionApostrophe} "sr2" "sr2file"
    ${UnRegisterExtensionApostrophe} "arq" "arqfile"
    ${UnRegisterExtensionApostrophe} "srw" "srwfile"
    ${UnRegisterExtensionApostrophe} "sti" "stifile"
    ${UnRegisterExtensionApostrophe} "sun" "sunfile"
    ${UnRegisterExtensionApostrophe} "ras" "rasfile"
    ${UnRegisterExtensionApostrophe} "sr" "srfile"
    ${UnRegisterExtensionApostrophe} "im1" "im1file"
    ${UnRegisterExtensionApostrophe} "im24" "im24file"
    ${UnRegisterExtensionApostrophe} "im32" "im32file"
    ${UnRegisterExtensionApostrophe} "im8" "im8file"
    ${UnRegisterExtensionApostrophe} "rast" "rastfile"
    ${UnRegisterExtensionApostrophe} "rs" "rsfile"
    ${UnRegisterExtensionApostrophe} "scr" "scrfile"
    ${UnRegisterExtensionApostrophe} "svg" "svgfile"
    ${UnRegisterExtensionApostrophe} "svgz" "svgzfile"
    ${UnRegisterExtensionApostrophe} "tar" "tarfile"
    ${UnRegisterExtensionApostrophe} "tga" "tgafile"
    ${UnRegisterExtensionApostrophe} "icb" "icbfile"
    ${UnRegisterExtensionApostrophe} "vda" "vdafile"
    ${UnRegisterExtensionApostrophe} "vst" "vstfile"
    ${UnRegisterExtensionApostrophe} "tiff" "tifffile"
    ${UnRegisterExtensionApostrophe} "tif" "tiffile"
    ${UnRegisterExtensionApostrophe} "tim" "timfile"
    ${UnRegisterExtensionApostrophe} "ttf" "ttffile"
    ${UnRegisterExtensionApostrophe} "vicar" "vicarfile"
    ${UnRegisterExtensionApostrophe} "vic" "vicfile"
    ${UnRegisterExtensionApostrophe} "img" "imgfile"
    ${UnRegisterExtensionApostrophe} "viff" "vifffile"
    ${UnRegisterExtensionApostrophe} "xv" "xvfile"
    ${UnRegisterExtensionApostrophe} "vtf" "vtffile"
    ${UnRegisterExtensionApostrophe} "wbmp" "wbmpfile"
    ${UnRegisterExtensionApostrophe} "webp" "webpfile"
    ${UnRegisterExtensionApostrophe} "wmf" "wmffile"
    ${UnRegisterExtensionApostrophe} "wmz" "wmzfile"
    ${UnRegisterExtensionApostrophe} "apm" "apmfile"
    ${UnRegisterExtensionApostrophe} "wpg" "wpgfile"
    ${UnRegisterExtensionApostrophe} "x3f" "x3ffile"
    ${UnRegisterExtensionApostrophe} "xbm" "xbmfile"
    ${UnRegisterExtensionApostrophe} "bm" "bmfile"
    ${UnRegisterExtensionApostrophe} "xpm" "xpmfile"
    ${UnRegisterExtensionApostrophe} "pm" "pmfile"
    ${UnRegisterExtensionApostrophe} "xwd" "xwdfile"
    ${UnRegisterExtensionApostrophe} "eps" "epsfile"
    ${UnRegisterExtensionApostrophe} "epsf" "epsffile"
    ${UnRegisterExtensionApostrophe} "epsi" "epsifile"
    ${UnRegisterExtensionApostrophe} "pdf" "pdffile"
    ${UnRegisterExtensionApostrophe} "ps" "psfile"
    ${UnRegisterExtensionApostrophe} "ps2" "ps2file"
    ${UnRegisterExtensionApostrophe} "ps3" "ps3file"
    ${UnRegisterExtensionApostrophe} "psd" "psdfile"
    ${UnRegisterExtensionApostrophe} "psb" "psbfile"
    ${UnRegisterExtensionApostrophe} "psdt" "psdtfile"
    ${UnRegisterExtensionApostrophe} "xcf" "xcffile"

"""

    # create database connection
    conn = sqlite3.connect('imageformats.db')
    c = conn.cursor()

    # get all data
    c.execute('SELECT * FROM imageformats ORDER BY endings')
    data = c.fetchall()

    # register file extensions in install script

    stdcont = ""
    pdfcont = ""
    psdcont = ""

    un_stdcont = ""
    un_pdfcont = ""
    un_psdcont = ""

    for row in data:

        endings = row[0].split(",")

        desc = row[3]
        if ":" in desc:
            desc = desc.split(":")[1].strip()

        for e in endings:

            line = ""
            un_line = ""

            if endings[0] == "zip" or endings[0] == "rar" or endings[0] == "7z":
                continue

            line = f"    ${{RegisterExtension}} \"$INSTDIR\\photoqt.exe\" \"{e}\" \"{desc}\"\n"
            un_line = f"    ${{UnRegisterExtension}} \"{e}\" \"{desc}\"\n"

            if endings[0] in ["eps", "pdf", "ps"]:
                pdfcont += line
                un_pdfcont += un_line
            elif endings[0] in ["psd", "xcf"]:
                psdcont += line
                un_psdcont += un_line
            elif row[5] == 1:
                stdcont += line
                un_stdcont += un_line

    cont += """
    ${If} $RadioButtonAll_State == ${BST_CHECKED}

        WriteRegStr HKCU "Software\\PhotoQt" "fileformats" "all"

""" + stdcont.replace("    ", "        ") + """

        ${If} $CheckboxPdfPs_State == ${BST_CHECKED}

            WriteRegStr HKCU "Software\\PhotoQt" "fileformats_pdfps" "registered"

""" + pdfcont.replace("    ", "            ") + """

        ${Else}

            ; if it was registered in a previous install, we need to de-register it here
            Var /GLOBAL fileformats_pdfps
            ReadRegStr $fileformats_pdfps HKCU "Software\\PhotoQt" "fileformats_pdfps"
            ${If} $fileformats_pdfps == "registered"

""" + un_pdfcont.replace("    ", "                ") + """

            ${EndIf}

            WriteRegStr HKCU "Software\\PhotoQt" "fileformats_pdfps" ""

        ${EndIf}

        ${If} $CheckboxPsdXcf_State == ${BST_CHECKED}

            WriteRegStr HKCU "Software\\PhotoQt" "fileformats_psdxcf" "registered"

""" + psdcont.replace("    ", "            ") + """

        ${Else}

            ; if it was registered in a previous install, we need to de-register it here
            Var /GLOBAL fileformats_psdxcf
            ReadRegStr $fileformats_psdxcf HKCU "Software\\PhotoQt" "fileformats_psdxcf"
            ${If} $fileformats_psdxcf == "registered"

""" + un_psdcont.replace("    ", "                ") + """

            ${EndIf}

            WriteRegStr HKCU "Software\\PhotoQt" "fileformats_psdxcf" ""

        ${EndIf}

    ${EndIf}

    ${If} $CheckboxDesktop_State == ${BST_CHECKED}

        ; create desktop shortcut
        CreateShortcut "$desktop\\PhotoQt.lnk" "$instdir\\photoqt.exe" "" "$INSTDIR\\icon.ico" 0

    ${Else}

        Delete "$desktop\\PhotoQt.lnk"

    ${EndIf}

    ${If} $CheckboxStartMenu_State == ${BST_CHECKED}

        ; create start menu entry in top level, no need for a subdirectory
        CreateShortcut "$SMPROGRAMS\\PhotoQt.lnk" "$INSTDIR\\photoqt.exe" "" "" 0

    ${Else}

        Delete "$SMPROGRAMS\\PhotoQt.lnk"

    ${EndIf}

    WriteRegStr HKLM "${INSTDIR_REG_KEY}" "DisplayIcon" "$INSTDIR\\icon.ico"
    WriteRegStr HKCR "Applications\\photoqt.exe" "FriendlyAppName" "PhotoQt"

    System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'

FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The uninstaller

Section "Uninstall"

    Var /GLOBAL un_fileformats
    Var /GLOBAL un_fileformats_pdfps
    Var /GLOBAL un_fileformats_psdxcf
    ReadRegStr $un_fileformats HKCU "Software\\PhotoQt" "fileformats"
    ReadRegStr $un_fileformats_pdfps HKCU "Software\\PhotoQt" "fileformats_pdfps"
    ReadRegStr $un_fileformats_psdxcf HKCU "Software\\PhotoQt" "fileformats_psdxcf"

    ; ... DE-register file formats ...
    ${If} $un_fileformats == "all"

""" + un_stdcont.replace("    ", "        ") + """
        WriteRegStr HKCU "Software\\PhotoQt" "fileformats" ""

    ${EndIf}

    ${If} $un_fileformats_pdfps == "registered"

""" + un_pdfcont.replace("    ", "        ") + """

        WriteRegStr HKCU "Software\\PhotoQt" "fileformats_pdfps" ""

    ${EndIf}

    ${If} $un_fileformats_psdxcf == "registered"

""" + un_psdcont.replace("    ", "        ") + """

        WriteRegStr HKCU "Software\\PhotoQt" "fileformats_psdxcf" ""

    ${EndIf}

    SetShellVarContext all
    Delete "$SMPROGRAMS\\PhotoQt.lnk"
    Delete "$desktop\\PhotoQt.lnk"

    ;begin uninstall
    !insertmacro UNINSTALL.NEW_UNINSTALL "$OUTDIR"

    DeleteRegKey ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}"
    DeleteRegKey HKCU "Software\\PhotoQt"

    ; Remove environment variables
    EnVar::Delete "PHOTOQT_MAGICK_CODER_MODULE_PATH"
    EnVar::Delete "PHOTOQT_MAGICK_FILTER_MODULE_PATH"

    System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'

SectionEnd
"""

    f = open("output/photoqt-setup.nsi", "w")
    f.write(cont)
    f.close()


#############################################################
#############################################################
# GENERATE NSI ENTRIES
if which == 'all' or which == 'formatsdb':

    sqltxt = "delete from imageformats;\n"

    conndb = sqlite3.connect('imageformats.db')
    cdb = conndb.cursor()

    cdb.execute("SELECT endings,description,qt,imagemagick,graphicsmagick,libraw,poppler,xcftools,devil,freeimage,archive,video,libmpv FROM imageformats ORDER BY endings")
    data = cdb.fetchall()

    for row in data:

        end = row[0]
        des = row[1]
        qt  = row[2]
        im  = row[3]
        gm  = row[4]
        raw = row[5]
        pop = row[6]
        xcf = row[7]
        dev = row[8]
        fre = row[9]
        arc = row[10]
        vid = row[11]
        mpv = row[12]

        sqltxt += f"INSERT INTO imageformats (`endings`,`description`,`qt`,`imagemagick`,`graphicsmagick`,`libraw`,`poppler`,`xcftools`,`devil`,`freeimage`,`archive`,`video`,`libmpv`) VALUES ('{end}', '{des}', {qt}, {im}, {gm}, {raw}, {pop}, {xcf}, {dev}, {fre}, {arc}, {vid}, {mpv});\n"

    f = open("output/imageformats_website.sql", "w")
    f.write(sqltxt)
