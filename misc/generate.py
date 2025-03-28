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

                exe = "go-png2ico "
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
    ${UnRegisterExtension} ".3fr" "Hasselblad Raw Image Format"
    ${UnRegisterExtension} ".aai" "AAI Dune image"
    ${UnRegisterExtension} ".ani" "Animated Windows cursors"
    ${UnRegisterExtension} ".apng" "Animated Portable Network Graphics"
    ${UnRegisterExtension} ".ari" "ARRIFLEX Raw Image Format"
    ${UnRegisterExtension} ".art" "1st Publisher"
    ${UnRegisterExtension} ".arw" "Sony Digital Camera Alpha Raw Image Format"
    ${UnRegisterExtension} ".asf" "Advanced Systems Format"
    ${UnRegisterExtension} ".avif" "AV1 Image File Format"
    ${UnRegisterExtension} ".avifs" "AV1 Image File Format"
    ${UnRegisterExtension} ".avs" "AVS X image"
    ${UnRegisterExtension} ".x" "AVS X image"
    ${UnRegisterExtension} ".mbfavs" "AVS X image"
    ${UnRegisterExtension} ".bay" "Casio Raw Image Format"
    ${UnRegisterExtension} ".bmp" "Microsoft Windows bitmap"
    ${UnRegisterExtension} ".dib" "Microsoft Windows bitmap"
    ${UnRegisterExtension} ".bpg" "Better Portable Graphics"
    ${UnRegisterExtension} ".cals" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".ct1" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".ct2" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".ct3" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".ct4" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".c4" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".cal" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".nif" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".ras" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".cap" "Phase One Raw Image Format"
    ${UnRegisterExtension} ".eip" "Phase One Raw Image Format"
    ${UnRegisterExtension} ".liq" "Phase One Raw Image Format"
    ${UnRegisterExtension} ".cb7" "Comic book archive"
    ${UnRegisterExtension} ".cbr" "Comic book archive"
    ${UnRegisterExtension} ".cbt" "Comic book archive"
    ${UnRegisterExtension} ".cbz" "Comic book archive"
    ${UnRegisterExtension} ".cg3" "CCITT Group 3"
    ${UnRegisterExtension} ".g3" "CCITT Group 3"
    ${UnRegisterExtension} ".crw" "Canon Digital Camera Raw Image Format"
    ${UnRegisterExtension} ".crr" "Canon Digital Camera Raw Image Format"
    ${UnRegisterExtension} ".cr2" "Canon Digital Camera Raw Image Format"
    ${UnRegisterExtension} ".cr3" "Canon Digital Camera Raw Image Format"
    ${UnRegisterExtension} ".cube" "Cube Color lookup table converted to a HALD image"
    ${UnRegisterExtension} ".cur" "Microsoft Windows cursor format"
    ${UnRegisterExtension} ".cut" "Dr. Halo"
    ${UnRegisterExtension} ".pal" "Dr. Halo"
    ${UnRegisterExtension} ".dcr" "Kodak Cineon Raw Image Format"
    ${UnRegisterExtension} ".kdc" "Kodak Cineon Raw Image Format"
    ${UnRegisterExtension} ".drf" "Kodak Cineon Raw Image Format"
    ${UnRegisterExtension} ".k25" "Kodak Cineon Raw Image Format"
    ${UnRegisterExtension} ".dcs" "Kodak Cineon Raw Image Format"
    ${UnRegisterExtension} ".dcx" "ZSoft IBM PC multi-page Paintbrush image"
    ${UnRegisterExtension} ".dds" "DirectDraw Surface"
    ${UnRegisterExtension} ".dfont" "Multi-face font package"
    ${UnRegisterExtension} ".dic" "Digital Imaging and Communications in Medicine (DICOM) image"
    ${UnRegisterExtension} ".dcm" "Digital Imaging and Communications in Medicine (DICOM) image"
    ${UnRegisterExtension} ".djvu" "DjVu digital document format "
    ${UnRegisterExtension} ".djv" "DjVu digital document format "
    ${UnRegisterExtension} ".dng" "Adobe Digital Negative Raw Image Format"
    ${UnRegisterExtension} ".dpx" "Digital Moving Picture Exchange"
    ${UnRegisterExtension} ".erf" "Epson Raw Image Format"
    ${UnRegisterExtension} ".exr" "OpenEXR"
    ${UnRegisterExtension} ".ff" "farbfeld"
    ${UnRegisterExtension} ".fits" "Flexible Image Transport System"
    ${UnRegisterExtension} ".fit" "Flexible Image Transport System"
    ${UnRegisterExtension} ".fts" "Flexible Image Transport System"
    ${UnRegisterExtension} ".fl32" "FilmLight floating point image format"
    ${UnRegisterExtension} ".ftx" "FAKK 2"
    ${UnRegisterExtension} ".gif" "Graphics Interchange Format"
    ${UnRegisterExtension} ".gpr" "GoPro GPR Raw Image Format"
    ${UnRegisterExtension} ".heif" "High Efficiency Image Format"
    ${UnRegisterExtension} ".heic" "High Efficiency Image Format"
    ${UnRegisterExtension} ".hrz" "Slow-scan television"
    ${UnRegisterExtension} ".icns" "Apple Icon Image"
    ${UnRegisterExtension} ".ico" "Microsoft Windows icon format"
    ${UnRegisterExtension} ".iff" "Interchange File Format"
    ${UnRegisterExtension} ".jbig" "Joint Bi-level Image experts Group file interchange format (JBIG)"
    ${UnRegisterExtension} ".jbg" "Joint Bi-level Image experts Group file interchange format (JBIG)"
    ${UnRegisterExtension} ".bie" "Joint Bi-level Image experts Group file interchange format (JBIG)"
    ${UnRegisterExtension} ".jng" "JPEG Network Graphics"
    ${UnRegisterExtension} ".jpeg" "Joint Photographic Experts Group JFIF format"
    ${UnRegisterExtension} ".jpg" "Joint Photographic Experts Group JFIF format"
    ${UnRegisterExtension} ".jpe" "Joint Photographic Experts Group JFIF format"
    ${UnRegisterExtension} ".jif" "Joint Photographic Experts Group JFIF format"
    ${UnRegisterExtension} ".jpeg2000" "JPEG-2000"
    ${UnRegisterExtension} ".j2k" "JPEG-2000"
    ${UnRegisterExtension} ".jp2" "JPEG-2000"
    ${UnRegisterExtension} ".jpc" "JPEG-2000"
    ${UnRegisterExtension} ".jpx" "JPEG-2000"
    ${UnRegisterExtension} ".jxl" "JPEG XL"
    ${UnRegisterExtension} ".jxr" "JPEG-XR"
    ${UnRegisterExtension} ".hdp" "JPEG-XR"
    ${UnRegisterExtension} ".wdp" "JPEG-XR"
    ${UnRegisterExtension} ".koa" "KOALA files"
    ${UnRegisterExtension} ".gg" "KOALA files"
    ${UnRegisterExtension} ".gig" "KOALA files"
    ${UnRegisterExtension} ".kla" "KOALA files"
    ${UnRegisterExtension} ".kra" "Krita Document"
    ${UnRegisterExtension} ".lbm" "Interlaced Bitmap"
    ${UnRegisterExtension} ".mat" "MATLAB image format"
    ${UnRegisterExtension} ".mdc" "Minolta/Agfa Raw Image Format"
    ${UnRegisterExtension} ".mef" "Mamiya Raw Image Format"
    ${UnRegisterExtension} ".miff" "Magick image file format"
    ${UnRegisterExtension} ".mif" "Magick image file format"
    ${UnRegisterExtension} ".mng" "Multiple-image Network Graphics"
    ${UnRegisterExtension} ".mos" "Leaf Raw Image Format"
    ${UnRegisterExtension} ".mpc" "Magick Persistent Cache image file format"
    ${UnRegisterExtension} ".mtv" "MTV ray tracer bitmap"
    ${UnRegisterExtension} ".pic" "MTV ray tracer bitmap"
    ${UnRegisterExtension} ".mvg" "Magick Vector Graphics"
    ${UnRegisterExtension} ".nef" "Nikon Digital SLR Camera Raw Image Format"
    ${UnRegisterExtension} ".nrw" "Nikon Digital SLR Camera Raw Image Format"
    ${UnRegisterExtension} ".ora" "OpenRaster"
    ${UnRegisterExtension} ".orf" "Olympus Digital Camera Raw Image Format"
    ${UnRegisterExtension} ".otb" "On-the-air Bitmap"
    ${UnRegisterExtension} ".otf" "OpenType font file"
    ${UnRegisterExtension} ".otc" "OpenType font file"
    ${UnRegisterExtension} ".ttf" "OpenType font file"
    ${UnRegisterExtension} ".ttc" "OpenType font file"
    ${UnRegisterExtension} ".p7" "Xv Visual Schnauzer thumbnail format"
    ${UnRegisterExtension} ".palm" "Palm pixmap"
    ${UnRegisterExtension} ".pam" "Portable Arbitrary Map format"
    ${UnRegisterExtension} ".pbm" "Portable bitmap format (black and white)"
    ${UnRegisterExtension} ".pcd" "Photo CD"
    ${UnRegisterExtension} ".pcds" "Photo CD"
    ${UnRegisterExtension} ".pcx" "ZSoft PiCture eXchange"
    ${UnRegisterExtension} ".pdb" "Palm Database ImageViewer Format"
    ${UnRegisterExtension} ".pef" "Pentax Raw Image Format"
    ${UnRegisterExtension} ".ptx" "Pentax Raw Image Format"
    ${UnRegisterExtension} ".pes" "Embrid Embroidery Format"
    ${UnRegisterExtension} ".pfb" "Postscript Type 1 font "
    ${UnRegisterExtension} ".pfm" "Postscript Type 1 font "
    ${UnRegisterExtension} ".afm" "Postscript Type 1 font "
    ${UnRegisterExtension} ".inf" "Postscript Type 1 font "
    ${UnRegisterExtension} ".pfa" "Postscript Type 1 font "
    ${UnRegisterExtension} ".ofm" "Postscript Type 1 font "
    ${UnRegisterExtension} ".pfm" "Portable Float Map"
    ${UnRegisterExtension} ".pgm" "Portable graymap format (gray scale)"
    ${UnRegisterExtension} ".pgx" "JPEG 2000 uncompressed format"
    ${UnRegisterExtension} ".phm" "Portable float map format 16-bit half"
    ${UnRegisterExtension} ".pic" "Softimage PIC"
    ${UnRegisterExtension} ".picon" "Personal Icon"
    ${UnRegisterExtension} ".pict" "QuickDraw/PICT"
    ${UnRegisterExtension} ".pct" "QuickDraw/PICT"
    ${UnRegisterExtension} ".pic" "QuickDraw/PICT"
    ${UnRegisterExtension} ".pix" "Alias/Wavefront RLE image format"
    ${UnRegisterExtension} ".als" "Alias/Wavefront RLE image format"
    ${UnRegisterExtension} ".alias" "Alias/Wavefront RLE image format"
    ${UnRegisterExtension} ".png" "Portable Network Graphics"
    ${UnRegisterExtension} ".ppm" "Portable pixmap format (color)"
    ${UnRegisterExtension} ".pnm" "Portable pixmap format (color)"
    ${UnRegisterExtension} ".ptiff" "Pyramid encoded TIFF"
    ${UnRegisterExtension} ".ptif" "Pyramid encoded TIFF"
    ${UnRegisterExtension} ".pxn" "Logitech Raw Image Format"
    ${UnRegisterExtension} ".qoi" "Quite OK image format"
    ${UnRegisterExtension} ".raf" "Fuji CCD Raw Image Format"
    ${UnRegisterExtension} ".raw" "Leica Raw Image Format"
    ${UnRegisterExtension} ".rwl" "Leica Raw Image Format"
    ${UnRegisterExtension} ".rgba" "SGI images"
    ${UnRegisterExtension} ".rgb" "SGI images"
    ${UnRegisterExtension} ".sgi" "SGI images"
    ${UnRegisterExtension} ".bw" "SGI images"
    ${UnRegisterExtension} ".rgbe" "Radiance RGBE image format"
    ${UnRegisterExtension} ".hdr" "Radiance RGBE image format"
    ${UnRegisterExtension} ".rad" "Radiance RGBE image format"
    ${UnRegisterExtension} ".rgf" "LEGO Mindstorms EV3 Robot Graphics File"
    ${UnRegisterExtension} ".rla" "Wavefront RLA File Format"
    ${UnRegisterExtension} ".rle" "Utah Run length encoded image file"
    ${UnRegisterExtension} ".rw2" "Panasonic Raw Image Format"
    ${UnRegisterExtension} ".scr" "ZX-Spectrum SCREEN"
    ${UnRegisterExtension} ".sct" "Scitex Continuous Tone Picture"
    ${UnRegisterExtension} ".ch" "Scitex Continuous Tone Picture"
    ${UnRegisterExtension} ".ct" "Scitex Continuous Tone Picture"
    ${UnRegisterExtension} ".sfw" "Seattle File Works image"
    ${UnRegisterExtension} ".alb" "Seattle File Works image"
    ${UnRegisterExtension} ".pwm" "Seattle File Works image"
    ${UnRegisterExtension} ".pwp" "Seattle File Works image"
    ${UnRegisterExtension} ".sixel" "DEC SIXEL Graphics Format"
    ${UnRegisterExtension} ".srf" "Sony (Minolta) Raw Image Format"
    ${UnRegisterExtension} ".mrw" "Sony (Minolta) Raw Image Format"
    ${UnRegisterExtension} ".sr2" "Sony (Minolta) Raw Image Format"
    ${UnRegisterExtension} ".srw" "Samsung Raw Image Format"
    ${UnRegisterExtension} ".sun" "SUN Rasterfile"
    ${UnRegisterExtension} ".ras" "SUN Rasterfile"
    ${UnRegisterExtension} ".sr" "SUN Rasterfile"
    ${UnRegisterExtension} ".im1" "SUN Rasterfile"
    ${UnRegisterExtension} ".im24" "SUN Rasterfile"
    ${UnRegisterExtension} ".im32" "SUN Rasterfile"
    ${UnRegisterExtension} ".im8" "SUN Rasterfile"
    ${UnRegisterExtension} ".rast" "SUN Rasterfile"
    ${UnRegisterExtension} ".rs" "SUN Rasterfile"
    ${UnRegisterExtension} ".scr" "SUN Rasterfile"
    ${UnRegisterExtension} ".svg" "Scalable Vector Graphics"
    ${UnRegisterExtension} ".svgz" "Scalable Vector Graphics"
    ${UnRegisterExtension} ".tar" "TAR file format"
    ${UnRegisterExtension} ".tga" "Truevision Targa image"
    ${UnRegisterExtension} ".icb" "Truevision Targa image"
    ${UnRegisterExtension} ".vda" "Truevision Targa image"
    ${UnRegisterExtension} ".vst" "Truevision Targa image"
    ${UnRegisterExtension} ".tiff" "Tagged Image File Format"
    ${UnRegisterExtension} ".tif" "Tagged Image File Format"
    ${UnRegisterExtension} ".tim" "PSX TIM (PlayStation Graphics)"
    ${UnRegisterExtension} ".ttf" "TrueType font file"
    ${UnRegisterExtension} ".vicar" "VICAR rasterfile format"
    ${UnRegisterExtension} ".vic" "VICAR rasterfile format"
    ${UnRegisterExtension} ".img" "VICAR rasterfile format"
    ${UnRegisterExtension} ".viff" "Khoros Visualization Image File Format"
    ${UnRegisterExtension} ".xv" "Khoros Visualization Image File Format"
    ${UnRegisterExtension} ".vtf" "Valve Texture Format"
    ${UnRegisterExtension} ".wbmp" "Wireless Bitmap"
    ${UnRegisterExtension} ".webp" "Google web image format"
    ${UnRegisterExtension} ".wmf" "Windows Metafile"
    ${UnRegisterExtension} ".wmz" "Windows Metafile"
    ${UnRegisterExtension} ".apm" "Windows Metafile"
    ${UnRegisterExtension} ".wpg" "Word Perfect Graphics File"
    ${UnRegisterExtension} ".xbm" "X BitMap"
    ${UnRegisterExtension} ".bm" "X BitMap"
    ${UnRegisterExtension} ".xpm" "X PixMap"
    ${UnRegisterExtension} ".pm" "X PixMap"
    ${UnRegisterExtension} ".xwd" "X Windows system window dump"
    ${UnRegisterExtension} ".eps" "Encapsulated PostScript"
    ${UnRegisterExtension} ".epsf" "Encapsulated PostScript"
    ${UnRegisterExtension} ".epsi" "Encapsulated PostScript"
    ${UnRegisterExtension} ".pdf" "Adobe Portable Document Format"
    ${UnRegisterExtension} ".ps" "Adobe Level III PostScript file"
    ${UnRegisterExtension} ".ps2" "Adobe Level III PostScript file"
    ${UnRegisterExtension} ".ps3" "Adobe Level III PostScript file"
    ${UnRegisterExtension} ".psd" "Adobe PhotoShop"
    ${UnRegisterExtension} ".psb" "Adobe PhotoShop"
    ${UnRegisterExtension} ".xcf" "Gimp XCF"
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

            line = f"    ${{RegisterExtension}} \"$INSTDIR\\photoqt.exe\" \".{e}\" \"{e.lower()}file\"\n"
            un_line = f"    ${{UnRegisterExtension}} \".{e}\" \"{e.lower()}file\"\n"

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
