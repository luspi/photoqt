#!/usr/bin/python

import sys
from os import listdir
from os.path import isfile, join

# NSIS Modern User Interface
# PhotoQT Setup


numparams = len(sys.argv);
params = sys.argv;

if numparams != 4:
    print("ERROR! Unexpected number of command line arguments. Expected arguments:\n1) Directory, 2) version (e.g., 1.5), 3) architecture (32 or 64)\n\n");
    exit();

directory = sys.argv[1];
#directory = "/home/luspi/Programming/tmp/photoqt-1.5.1/photoqt.i686/";
version = sys.argv[2];
#version = "1.5.1";
architecture = sys.argv[3];
#architecture = "32";

if not architecture=="32" and not architecture == "64":
    print("ERROR! architecture has to be either 32 or 64")
    exit();


#--------------------------------
# INCLUDES

# Include Modern UI
cont = "!include MUI2.nsh\n\n";

# Include stuff for nsdialog
cont += "!include LogicLib.nsh\n";
cont += "!include nsDialogs.nsh\n\n";

# Register app for filetypes
cont += "!include \"FileAssociation.nsh\"\n\n";


#--------------------------------
# GENERAL

# Name and file
cont += "Name \"PhotoQt\"\n";
cont += "OutFile \"photoqt-" + version + "_" + architecture + "bit.exe\"\n\n";

# Default installation folder
cont += "InstallDir \"$PROGRAMFILES\\PhotoQt\"\n\n";

# Get installation folder from registry if available\n";
cont += "InstallDirRegKey HKCU \"Software\\PhotoQt\" \"\"\n\n";

# Request application privileges for Windows Vista
cont += "RequestExecutionLevel admin\n\n";


#--------------------------------
# INTERFACE SETTINGS

cont += "!define MUI_ABORTWARNING\n";
cont += "!define MUI_ICON \"icon_install.ico\"\n\n";

cont += "!define UNINST_KEY \"HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\PhotoQt\"\n\n";

# Show all languages, despite user's codepage
cont += "!define MUI_LANGDLL_ALLLANGUAGES\n\n";

# Remember the installer language
cont += "!define MUI_LANGDLL_REGISTRY_ROOT \"HKCU\"\n";
cont += "!define MUI_LANGDLL_REGISTRY_KEY \"Software\\PhotoQt\"\n";
cont += "!define MUI_LANGDLL_REGISTRY_VALUENAME \"Installer Language\"\n";
cont += "!define MUI_LANGDLL_ALWAYSSHOW\n\n";


#--------------------------------
# PAGES

# Welcome text
cont += "!define MUI_WELCOMEPAGE_TITLE $(WelcomePage_Title)\n";
cont += "!define MUI_WELCOMEPAGE_TEXT $(WelcomePage_Text_part1)$\\r$\\n$\\r$\\n$(WelcomePage_Text_part2)\n\n";


# Installer pages
cont += "!define MUI_PAGE_CUSTOMFUNCTION_LEAVE warnUninstPrev\n";
cont += "!insertmacro MUI_PAGE_WELCOME\n";
cont += "!insertmacro MUI_PAGE_LICENSE \"license.txt\"\n";
cont += "!insertmacro MUI_PAGE_DIRECTORY\n";
cont += "!insertmacro MUI_PAGE_INSTFILES\n";
cont += "Page custom FinalStepsInit FinalStepsLeave\n";
cont += "!insertmacro MUI_PAGE_FINISH\n\n";

# UNinstaller pages
cont += "!insertmacro MUI_UNPAGE_CONFIRM\n";
cont += "!insertmacro MUI_UNPAGE_INSTFILES\n\n";


#--------------------------------
# LOCALISATION

cont += "!insertmacro MUI_LANGUAGE \"English\"\n";
cont += ";@INSERT_TRANSLATIONS@\n\n";

cont += "LangString    WelcomePage_Title                    ${LANG_English} \"Welcome to PhotoQt Setup\"\n";
cont += "LangString    WelcomePage_Text_part1               ${LANG_English} \"This installer will guide you through the installation of the PhotoQt.\"\n";
cont += "LangString    WelcomePage_Text_part2               ${LANG_English} \"PhotoQt is a simple image viewer, designed to be good looking and highly configurable, yet easy to use and fast.\"\n";
cont += "LangString    WelcomePage_UninstallPrevious        ${LANG_English} \"Some version of PhotoQt is currently installed... It is highly recommended to first uninstall any previous versions!\"\n";
cont += "LangString    FinishPage_Title                     ${LANG_English} \"Finishing up\"\n";
cont += "LangString    FinishPage_Subtitle                  ${LANG_English} \"Just a few final steps\"\n";
cont += "LangString    FinishPage_Description               ${LANG_English} \"We're almost done! Here you can tell PhotoQt to register as default application for (1) none, (2) some or (3) all image formats:\"\n";
cont += "LangString    FinishPage_RegisterNone              ${LANG_English} \"Register for NO image formats\"\n";
cont += "LangString    FinishPage_RegisterMostCommon        ${LANG_English} \"Register for the MOST COMMON image formats\"\n";
cont += "LangString    FinishPage_RegisterAll               ${LANG_English} \"Register for ALL SUPPORTED image formats (including slightly more exotic ones)\"\n";
cont += "LangString    FinishPage_RegisterPdfPs             ${LANG_English} \"Include PDF and PS\"\n";
cont += "LangString    FinishPage_RegisterPsdXcf            ${LANG_English} \"Include PSD and XCF\"\n";
cont += "LangString    FinishPage_DesktopIcon               ${LANG_English} \"Create Desktop Icon\"\n";
cont += "LangString    FinishPage_StartMenu                 ${LANG_English} \"Create Start menu entry\"\n\n";


#--------------------------------
# Reserve Files

# If you are using solid compression, files that are required before
# the actual installation should be stored first in the data block,
# because this will make your installer start faster.

cont += "!insertmacro MUI_RESERVEFILE_LANGDLL\n\n";


#--------------------------------
# INSTALLER SECTIONS

cont += "Section \"PhotoQt\" SecDummy\n\n";

cont += "    SetShellVarContext all\n\n";

# Install files

# Write the installation path into the registry
cont += "    WriteRegStr \"HKLM\" \"Software\\PhotoQt\" \"Install Directory\" \"$INSTDIR\"\n";
# Write the Uninstall information into the registry
cont += "    WriteRegStr \"HKLM\" \"UNINST_KEY\" \"UninstallString\" \"$INSTDIR\\uninstall.exe\"\n\n";

# while looping over all the files, we simultaneously compose the uninstall section and store it in a temporary array that we add on to cont later
deletecont = ""

# recursive read dir function
def readDirectory(direct):
    global cont
    global directory
    global deletecont
    cont += "\n    SetOutPath \"$INSTDIR\\" + (direct[len(directory):]).replace("/", "\\") + "\"\n";
    for f in listdir(direct):
        if isfile(join(direct, f)) and not f[-3:]=="nsi" and not f[-4:]=="qmlc" and not f[-3:]=="jsc" and not f[-3:]=="nsh" and not f=="icon_install.ico" and (not f[-3:]=="exe" or f == "photoqt.exe"):
            cont += "    File \"" + (join(direct, f)[len(directory):]).replace("/", "\\") + "\"\n";
            deletecont += "    Delete \"$INSTDIR\\" + (join(direct, f)[len(directory):]).replace("/", "\\") + "\"\n";
    for f in listdir(direct):
        if not isfile(join(direct, f)):
            readDirectory(join(direct, f))

# read files in top directory
cont += "    SetOutPath \"$INSTDIR\"\n";
for f in listdir(directory):
    if isfile(join(directory, f)) and not f[-3:]=="nsi" and not f[-3:]=="nsh" and not f=="icon_install.ico" and (not f[-3:]=="exe" or f == "photoqt.exe"):
        cont += "    File \"" + f + "\"\n";
        deletecont += "    Delete \"$INSTDIR\\" + f + "\"\n";
# loop over directories and recursively look into all of them
for f in listdir(directory):
    if not isfile(join(directory, f)):
        readDirectory(join(directory, f))


cont +="\n\n";

# Store installation folder
cont += "    WriteRegStr HKCU \"Software\\PhotoQt\" \"\" $INSTDIR\n\n";

# Create uninstaller
cont += "    WriteUninstaller \"$INSTDIR\\uninstall.exe\"\n\n";

cont += "SectionEnd\n";


#--------------------------------
# INSTALLER FUNTIONS

cont += "Function .onInit\n";
cont += "    !insertmacro MUI_LANGDLL_DISPLAY\n";
cont += "FunctionEnd\n\n";

cont += "Function warnUninstPrev\n";
cont += "    IfFileExists \"$INSTDIR\\photoqt.exe\" 0 +2\n";
cont += "        MessageBox MB_OK|MB_ICONEXCLAMATION $(WelcomePage_UninstallPrevious)\n";
cont += "FunctionEnd\n\n";


# Custom page (nsdialog)
cont += "Var Dialog\n\n";

# Description text
cont += "Var LabelFiletypeDesc\n\n";

# Variables for checkboxes and their states
cont += "Var RadioButtonNone\n";
cont += "Var RadioButtonBasic\n";
cont += "Var RadioButtonBasic_State\n";
cont += "Var RadioButtonAdvanced\n";
cont += "Var RadioButtonAdvanced_State\n";
cont += "Var CheckboxPdfPs\n";
cont += "Var CheckboxPdfPs_State\n";
cont += "Var CheckboxPsdXcf\n";
cont += "Var CheckboxPsdXcf_State\n\n";

cont += "Var CheckboxStartMenu\n";
cont += "Var CheckboxStartMenu_State\n";
cont += "Var CheckboxDesktop\n";
cont += "Var CheckboxDesktop_State\n\n";

cont += "Function FinalStepsInit\n";

# Set header and subtitle
cont += "    !insertmacro MUI_HEADER_TEXT $(FinishPage_Title) $(FinishPage_Subtitle)\n\n";

# Create dialog
cont += "    nsDialogs::Create 1018\n";
cont += "    Pop $Dialog\n";
cont += "    ${If} $Dialog == error\n";
cont += "        Abort\n";
cont += "    ${EndIf}\n\n";

# Create description label
cont += "    ${NSD_CreateLabel} 0 0 100% 24u $(FinishPage_Description)\n";
cont += "    Pop $LabelFiletypeDesc\n\n";


# Create all the radiobuttons/checkboxes

cont += "    ${NSD_CreateRadioButton} 0 25u 100% 12u $(FinishPage_RegisterNone)\n";
cont += "    Pop $RadioButtonNone\n";
cont += "    ${NSD_OnClick} $RadioButtonNone FinalStepsDisEnable\n\n";

cont += "    ${NSD_CreateRadioButton} 0 38u 100% 12u $(FinishPage_RegisterMostCommon)\n";
cont += "    Pop $RadioButtonBasic\n";
cont += "    ${NSD_OnClick} $RadioButtonBasic FinalStepsDisEnable\n\n";

cont += "    ${NSD_CreateRadioButton} 0 51u 100% 12u $(FinishPage_RegisterAll)\n";
cont += "    Pop $RadioButtonAdvanced\n";
cont += "    ${NSD_Check} $RadioButtonBasic\n";
cont += "    ${NSD_OnClick} $RadioButtonAdvanced FinalStepsDisEnable\n\n";

cont += "    ${NSD_CreateCheckbox} 0 64u 100% 12u $(FinishPage_RegisterPdfPs)\n";
cont += "    Pop $CheckboxPdfPs\n\n";

cont += "    ${NSD_CreateCheckbox} 0 77u 100% 12u $(FinishPage_RegisterPsdXcf)\n";
cont += "    Pop $CheckboxPsdXcf\n\n";

cont += "    ${NSD_CreateHLine} 0 99u 100% 1u HLineBeforeDesktop\n\n";

cont += "    ${NSD_CreateCheckbox} 0 109u 100% 12u $(FinishPage_DesktopIcon)\n";
cont += "    Pop $CheckboxDesktop\n";
cont += "    ${NSD_Check} $CheckboxDesktop\n\n";

cont += "    ${NSD_CreateCheckbox} 0 122u 100% 12u $(FinishPage_StartMenu)\n";
cont += "    Pop $CheckboxStartMenu\n";
cont += "    ${NSD_Check} $CheckboxStartMenu\n\n";


# Finally, show dialog
cont += "    nsDialogs::Show\n\n";

cont += "FunctionEnd\n\n";

cont += "Function FinalStepsDisEnable\n\n";

cont += "    ${NSD_GetState} $RadioButtonAdvanced $RadioButtonAdvanced_State\n";
cont += "    ${If} $RadioButtonAdvanced_State == ${BST_CHECKED}\n";
cont += "        EnableWindow $CheckboxPdfPs 1\n";
cont += "        EnableWindow $CheckboxPsdXcf 1\n";
cont += "    ${Else}\n";
cont += "        EnableWindow $CheckboxPdfPs 0\n";
cont += "        EnableWindow $CheckboxPsdXcf 0\n";
cont += "    ${EndIf}\n\n";

cont += "FunctionEnd\n\n";

cont += "Function FinalStepsLeave\n\n";

cont += "    SetShellVarContext all\n\n";

# Get checkbox states
cont += "    ${NSD_GetState} $RadioButtonBasic $RadioButtonBasic_State\n";
cont += "    ${NSD_GetState} $RadioButtonAdvanced $RadioButtonAdvanced_State\n";
cont += "    ${NSD_GetState} $CheckboxPdfPs $CheckboxPdfPs_State\n";
cont += "    ${NSD_GetState} $CheckboxPsdXcf $CheckboxPsdXcf_State\n";
cont += "    ${NSD_GetState} $CheckboxDesktop $CheckboxDesktop_State\n";
cont += "    ${NSD_GetState} $CheckboxStartMenu $CheckboxStartMenu_State\n\n";

# Register basic file types
cont += "    ${If} $RadioButtonBasic_State == ${BST_CHECKED}\n";
cont += "    ${OrIf} $RadioButtonAdvanced_State == ${BST_CHECKED}\n\n";

cont += "        WriteRegStr HKCU \"Software\\PhotoQt\" \"fileformats\" \"basic\"\n\n";

cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".bmp\" \"Microsoft Windows bitmap\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".bitmap\" \"Microsoft Windows bitmap\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".dds\" \"Direct Draw Surface\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".gif\" \"Graphics Interchange Format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".tif\" \"Tagged Image File Format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".tiff\" \"Tagged Image File Format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".jpeg2000\" \"JPEG-2000 image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".jp2\" \"JPEG-2000 image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".jpc\" \"JPEG-2000 image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".j2k\" \"JPEG-2000 image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".jpf\" \"JPEG-2000 image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".jpx\" \"JPEG-2000 image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".jpm\" \"JPEG-2000 image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".mj2\" \"JPEG-2000 image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".mng\" \"Multiple-image Network Graphics\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".ico\" \"Microsoft Icon\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".icns\" \"Microsoft Icon\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".jpeg\" \"JPEG image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".jpg\" \"JPEG image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".png\" \"Portable Network Graphics\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pbm\" \"Portable bitmap format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pgm\" \"Portable graymap format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".ppm\" \"Portable pixmap format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".svg\" \"Scalable Vector Graphics\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".svgz\" \"Scalable Vector Graphics\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".xbm\" \"X Windows system bitmap\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".wbmp\" \"Wireless bitmap\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".webp\" \"Wireless bitmap\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".xpm\" \"X Windows system pixmap\"\n\n";

cont += "    ${EndIf}\n\n";

# Register advanced file types
cont += "    ${If} $RadioButtonAdvanced_State == ${BST_CHECKED}\n\n";

cont += "        WriteRegStr HKCU \"Software\\PhotoQt\" \"fileformats\" \"advanced\"\n\n";

cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".avs\" \"AVS X image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".x\" \"AVS X image\"\n\n";

cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".cals\" \"Continuous Acquisition and Life-cycle Support Type 1 image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".cal\" \"Continuous Acquisition and Life-cycle Support Type 1 image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".dcl\" \"Continuous Acquisition and Life-cycle Support Type 1 image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".ras\" \"Continuous Acquisition and Life-cycle Support Type 1 image\"\n\n";

cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".cin\" \"Kodak Cineon\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".cut\" \"DR Halo\"\n\n";

cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".acr\" \"DICOM image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".dcm\" \"DICOM image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".dicom\" \"DICOM image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".dic\" \"DICOM image\"\n\n";

cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".dcx\" \"ZSoft IBM PC multi-page Paintbrush image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".dib\" \"Device Independent Bitmap\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".dpx\" \"Digital Moving Picture Exchange\"\n\n";

cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".fax\" \"Group 3 Fax\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".fits\" \"Flexible Image Transport System\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".fts\" \"Flexible Image Transport System\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".fit\" \"Flexible Image Transport System\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".fpx\" \"FlashPix Format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".jng\" \"JPEG Network Graphics\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".mat\" \"MATLAT image format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".miff\" \"Magick image file format\"\n\n";

cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".mono\" \"Bi-level bitmap in little-endian order\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".mtv\" \"MTV Raytracing image format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".otb\" \"On-the-air bitmap\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".p7\" \"Xv's Visual Schnauzer thumbnail format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".palm\" \"Palm pixmap\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pam\" \"Portable Arbitrary Map format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pcd\" \"Photo CD\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pcds\" \"Photo CD\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pcx\" \"ZSoft IBM PC Paintbrush file\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pdb\" \"Palm Database ImageViewer format\"\n\n";

cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pict\" \"Apple Macintosh QuickDraw/PICT file\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pct\" \"Apple Macintosh QuickDraw/PICT file\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pic\" \"Apple Macintosh QuickDraw/PICT file\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pix\" \"Alias/Wavefront RLE image format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pal\" \"Alias/Wavefront RLE image format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pnm\" \"Portable anymap\"\n\n";

cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".ptif\" \"Pyramid encoded TIFF\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".ptiff\" \"Pyramid encoded TIFF\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".sfw\" \"Seattle File Works image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".sgi\" \"Irix RGB image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".sun\" \"SUN Rasterfile\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".tga\" \"Truevision Targe image\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".vicar\" \"VICAR rasterfile format\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".viff\" \"Khoros Visualization image file format\"\n\n";

cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".wpg\" \"Word Perfect Graphics file\"\n";
cont += "        !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".xwd\" \"X Windows system window dump\"\n\n";


cont += "        ${If} $CheckboxPdfPs_State == ${BST_CHECKED}\n\n";

cont += "            WriteRegStr HKCU \"Software\\PhotoQt\" \"fileformats_pdfps\" \"registered\"\n\n";

cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".epdf\" \"Encapsulated PDF\"\n";
cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".epi\" \"Encapsulated PostScript Interchange format\"\n";
cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".epsi\" \"Encapsulated PostScript Interchange format\"\n";
cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".eps\" \"Encapsulated PostScript\"\n";
cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".epsf\" \"Encapsulated PostScript\"\n";
cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".eps2\" \"Level II Encapsulated PostScript\"\n";
cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".eps3\" \"Level III Encapsulated PostScript\"\n";
cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".ept\" \"Encapsulated PostScript Interchange format (TIFF preview)\"\n";
cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".pdf\" \"Portable Document Format\"\n";
cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".ps\" \"PostScript\"\n";
cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".ps2\" \"Level II PostScript\"\n";
cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".ps3\" \"Level III PostScript\"\n\n";

cont += "        ${EndIf}\n\n";

cont += "        ${If} $CheckboxPsdXcf_State == ${BST_CHECKED}\n\n";

cont += "            WriteRegStr HKCU \"Software\\PhotoQt\" \"fileformats_psdxcf\" \"registered\"\n\n";

cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".psb\" \"Large Photoshop Document\"\n";
cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".psd\" \"Photoshop Document\"\n";
cont += "            !insertmacro RegisterExtensionCall \"$INSTDIR\\photoqt.exe\" \".xcf\" \"Gimp image\"\n\n";

cont += "        ${EndIf}\n\n";

cont += "    ${EndIf}\n\n";


# Create desktop icon
cont += "     ${If} $CheckboxDesktop_State == ${BST_CHECKED}\n\n";

cont += "         CreateShortcut \"$desktop\\PhotoQt.lnk\" \"$instdir\\photoqt.exe\" \"\" \"$INSTDIR\\icon.ico\" 0\n\n";

cont += "     ${EndIf}\n\n";

# Create startmenu entry
cont += "     ${If} $CheckboxStartMenu_State == ${BST_CHECKED}\n\n";

cont += "         CreateDirectory \"$SMPROGRAMS\\PhotoQt\"\n";
cont += "         CreateShortcut \"$SMPROGRAMS\\PhotoQt\\Uninstall.lnk\" \"$INSTDIR\\uninstall.exe\" \"\" \"\" 0\n";
cont += "         CreateShortcut \"$SMPROGRAMS\\PhotoQt\\PhotoQt.lnk\" \"$INSTDIR\\photoqt.exe\" \"\" \"\" 0\n";
cont += "         CreateShortcut \"$SMPROGRAMS\\PhotoQt\\Readme.lnk\" \"$INSTDIR\\html\photoqt_en.htm\" \"\" \"\" 0\n\n";

cont += "     ${EndIf}\n\n";

# Update icons
cont += "     System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'\n\n";

cont += " FunctionEnd\n\n";


#--------------------------------
# UNINSTALLER SECTION

cont += "Section \"Uninstall\"\n\n";

cont += "    SetShellVarContext all\n\n";

# De-register file types

cont += "    Var /GLOBAL fileformats\n";
cont += "    Var /GLOBAL fileformats_pdfps\n";
cont += "    Var /GLOBAL fileformats_psdxcf\n";
cont += "    ReadRegStr $fileformats HKCU \"Software\PhotoQt\" \"fileformats\"\n";
cont += "    ReadRegStr $fileformats_pdfps HKCU \"Software\PhotoQt\" \"fileformats_pdfps\"\n";
cont += "    ReadRegStr $fileformats_psdxcf HKCU \"Software\PhotoQt\" \"fileformats_psdxcf\"\n\n";

cont += "    !insertmacro UnRegisterExtensionCall \".bmp\" \"Microsoft Windows bitmap\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".bitmap\" \"Microsoft Windows bitmap\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".dds\" \"Direct Draw Surface\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".gif\" \"Graphics Interchange Format\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".tif\" \"Tagged Image File Format\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".tiff\" \"Tagged Image File Format\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".jpeg2000\" \"JPEG-2000 image\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".jp2\" \"JPEG-2000 image\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".jpc\" \"JPEG-2000 image\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".j2k\" \"JPEG-2000 image\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".jpf\" \"JPEG-2000 image\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".jpx\" \"JPEG-2000 image\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".jpm\" \"JPEG-2000 image\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".mj2\" \"JPEG-2000 image\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".mng\" \"Multiple-image Network Graphics\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".ico\" \"Microsoft Icon\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".icns\" \"Microsoft Icon\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".jpeg\" \"JPEG image\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".jpg\" \"JPEG image\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".png\" \"Portable Network Graphics\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".pbm\" \"Portable bitmap format\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".pgm\" \"Portable graymap format\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".ppm\" \"Portable pixmap format\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".svg\" \"Scalable Vector Graphics\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".svgz\" \"Scalable Vector Graphics\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".xbm\" \"X Windows system bitmap\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".wbmp\" \"Wireless bitmap\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".webp\" \"Wireless bitmap\"\n";
cont += "    !insertmacro UnRegisterExtensionCall \".xpm\" \"X Windows system pixmap\"\n\n";

cont += "    ${If} $fileformats == \"advanced\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".avs\" \"AVS X image\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".x\" \"AVS X image\"\n\n";

cont += "        !insertmacro UnRegisterExtensionCall \".cals\" \"Continuous Acquisition and Life-cycle Support Type 1 image\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".cal\" \"Continuous Acquisition and Life-cycle Support Type 1 image\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".dcl\" \"Continuous Acquisition and Life-cycle Support Type 1 image\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".ras\" \"Continuous Acquisition and Life-cycle Support Type 1 image\"\n\n";

cont += "        !insertmacro UnRegisterExtensionCall \".cin\" \"Kodak Cineon\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".cut\" \"DR Halo\"\n\n";

cont += "        !insertmacro UnRegisterExtensionCall \".acr\" \"DICOM image\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".dcm\" \"DICOM image\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".dicom\" \"DICOM image\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".dic\" \"DICOM image\"\n\n";

cont += "        !insertmacro UnRegisterExtensionCall \".dcx\" \"ZSoft IBM PC multi-page Paintbrush image\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".dib\" \"Device Independent Bitmap\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".dpx\" \"Digital Moving Picture Exchange\"\n\n";

cont += "        !insertmacro UnRegisterExtensionCall \".fax\" \"Group 3 Fax\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".fits\" \"Flexible Image Transport System\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".fts\" \"Flexible Image Transport System\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".fit\" \"Flexible Image Transport System\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".fpx\" \"FlashPix Format\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".jng\" \"JPEG Network Graphics\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".mat\" \"MATLAT image format\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".miff\" \"Magick image file format\"\n\n";

cont += "        !insertmacro UnRegisterExtensionCall \".mono\" \"Bi-level bitmap in little-endian order\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".mtv\" \"MTV Raytracing image format\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".otb\" \"On-the-air bitmap\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".p7\" \"Xv's Visual Schnauzer thumbnail format\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".palm\" \"Palm pixmap\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".pam\" \"Portable Arbitrary Map format\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".pcd\" \"Photo CD\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".pcds\" \"Photo CD\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".pcx\" \"ZSoft IBM PC Paintbrush file\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".pdb\" \"Palm Database ImageViewer format\"\n\n";

cont += "        !insertmacro UnRegisterExtensionCall \".pict\" \"Apple Macintosh QuickDraw/PICT file\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".pct\" \"Apple Macintosh QuickDraw/PICT file\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".pic\" \"Apple Macintosh QuickDraw/PICT file\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".pix\" \"Alias/Wavefront RLE image format\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".pal\" \"Alias/Wavefront RLE image format\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".pnm\" \"Portable anymap\"\n\n";

cont += "        !insertmacro UnRegisterExtensionCall \".ptif\" \"Pyramid encoded TIFF\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".ptiff\" \"Pyramid encoded TIFF\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".sfw\" \"Seattle File Works image\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".sgi\" \"Irix RGB image\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".sun\" \"SUN Rasterfile\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".tga\" \"Truevision Targe image\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".vicar\" \"VICAR rasterfile format\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".viff\" \"Khoros Visualization image file format\"\n\n";

cont += "        !insertmacro UnRegisterExtensionCall \".wpg\" \"Word Perfect Graphics file\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".xwd\" \"X Windows system window dump\"\n";
cont += "    ${EndIf}\n\n";

cont += "    ${If} $fileformats_pdfps == \"registered\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".epdf\" \"Encapsulated PDF\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".epi\" \"Encapsulated PostScript Interchange format\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".epsi\" \"Encapsulated PostScript Interchange format\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".eps\" \"Encapsulated PostScript\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".epsf\" \"Encapsulated PostScript\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".eps2\" \"Level II Encapsulated PostScript\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".eps3\" \"Level III Encapsulated PostScript\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".ept\" \"Encapsulated PostScript Interchange format (TIFF preview)\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".pdf\" \"Portable Document Format\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".ps\" \"PostScript\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".ps2\" \"Level II PostScript\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".ps3\" \"Level III PostScript\"\n";
cont += "    ${EndIf}\n\n";

cont += "    ${If} $fileformats_psdxcf == \"registered\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".psb\" \"Large Photoshop Document\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".psd\" \"Photoshop Document\"\n";
cont += "        !insertmacro UnRegisterExtensionCall \".xcf\" \"Gimp image\"\n";
cont += "    ${EndIf}\n\n";

cont += deletecont + "\n";
cont += "Delete \"$INSTDIR\\uninstall.exe\"\n\n";

def deleteDirectory(direct):
    global cont
    for f in listdir(direct):
        if not isfile(join(direct, f)):
            deleteDirectory(join(direct, f))
    cont += "    RMDir \"$INSTDIR\\" + (direct[len(directory):]).replace("/", "\\") + "\"\n";

cont += "    Delete \"$desktop\\PhotoQt.lnk\"\n";
cont += "    Delete \"$SMPROGRAMS\\PhotoQt\\PhotoQt.lnk\"\n";
cont += "    Delete \"$SMPROGRAMS\\PhotoQt\\Uninstall.lnk\"\n";
cont += "    Delete \"$SMPROGRAMS\\PhotoQt\\Readme.lnk\"\n";
cont += "    RMDir \"$SMPROGRAMS\\PhotoQt\"\n\n";

cont += "    DeleteRegKey \"HKLM\" \"Software\\PhotoQt\"\n";
cont += "    DeleteRegKey \"HKLM\" \"${UNINST_KEY}\"\n";
cont += "    DeleteRegKey \"HKCU\" \"Software\\PhotoQt\"\n\n";

deleteDirectory(directory)

cont += "\n";

# Update icons
cont += "    System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'\n\n";

cont += "SectionEnd\n\n";


#--------------------------------
# Uninstaller Functions

cont += "Function un.onInit\n";
cont += "  !insertmacro MUI_UNGETLANGUAGE\n";
cont += "FunctionEnd\n\n";


filename = "photoqt-" + version + "_" + architecture + "bit.nsi";
f = open(filename, "w")
f.write(cont);

print("Success! NSIS script written to " + filename)
