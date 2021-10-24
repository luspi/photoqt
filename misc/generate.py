import numpy as np
import sys

known_args = np.array(['all', 'filetypes', 'cmake', 'windowsrc', 'nsi'])

if len(sys.argv) != 2 or sys.argv[1] not in known_args:

    print("""
One of the following flags is required:

 all\t\tGenerate all items
 filetypes\tGenerate filetype icons
 cmake\t\tGenerate CMake desktop file creation
 windowsrc\tGenerate windows resource file
 nsi\t\tGenerate nsi entries
""")

    exit()

import sqlite3

which = sys.argv[1]

# create database connection
conn = sqlite3.connect('imageformats.db')
c = conn.cursor()

# get all data
c.execute('SELECT * FROM imageformats ORDER BY endings')
data = c.fetchall()

import os
os.makedirs('output/', exist_ok=True)

#############################################################
#############################################################
# GENERATE FILETYPES IN SUBDIRECTORY
if which == 'all' or which == 'filetypes':

    import math
    import seaborn as sns
    import glob
    from wand.image import Image

    # remove all old data
    os.makedirs('output/svg', exist_ok=True)
    os.makedirs('output/ico', exist_ok=True)
    files = glob.glob('./output/svg/*')
    for f in files:
        os.remove(f)
    files = glob.glob('./output/ico/*')
    for f in files:
        os.remove(f)

    print("Generating filetype icons...")

    def rgb_to_hex(rgb):
        return '%02x%02x%02x' % (math.floor(rgb[0]*255), math.floor(rgb[1]*255), math.floor(rgb[2]*255))

    f_default = open("templ.ate", "r")
    cont_default = f_default.read()

    qrc_cont = "<RCC>\n    <qresource prefix=\"/\">\n"

    # we add a few extra as some cases have special handling below
    palette = sns.color_palette(None, len(data)+10)

    iF = 0
    for row in data:

        endng = row[0].split(',')

        for e in endng:

            f_new = open(f"output/svg/{e}.svg", "w")

            cont = cont_default.replace("#MODMOD", f"#{rgb_to_hex(palette[iF])}")
            cont = cont.replace("MOD", endng[0].upper())

            if len(endng[0]) == 1:
                cont = cont.replace("76.761147", "117.5511")
                cont = cont.replace("249.28143", "249.31589")
                cont = cont.replace("70.5556", "70.5556")
            elif len(endng[0]) == 2:
                cont = cont.replace("76.761147", "98.809769")
                cont = cont.replace("249.28143", "249.78098")
                cont = cont.replace("70.5556", "70.5556")
            elif len(endng[0]) == 3:
                cont = cont.replace("76.761147", "76.761147")
                cont = cont.replace("249.28143", "249.28143")
                cont = cont.replace("70.5556", "70.5556")
            elif len(endng[0]) == 4:
                cont = cont.replace("76.761147", "55.212063")
                cont = cont.replace("249.28143", "249.31589")
                cont = cont.replace("70.5556", "70.5556")
            elif len(endng[0]) == 5:
                cont = cont.replace("76.761147", "34.076389")
                cont = cont.replace("249.28143", "248.81635")
                cont = cont.replace("70.5556", "70.5556")
            elif len(endng[0]) == 6:
                cont = cont.replace("76.761147", "25.339693")
                cont = cont.replace("249.28143", "246.65109")
                cont = cont.replace("70.5556", "63.5")
            elif len(endng[0]) == 7:
                cont = cont.replace("76.761147", "21.66")
                cont = cont.replace("249.28143", "244.17233")
                cont = cont.replace("70.5556", "56.4444")
            elif len(endng[0]) == 8:
                cont = cont.replace("76.761147", "21.401915")
                cont = cont.replace("249.28143", "241.57646")
                cont = cont.replace("70.5556", "49.3889")
            elif len(endng[0]) == 9:
                cont = cont.replace("76.761147", "25.856543")
                cont = cont.replace("249.28143", "238.77042")
                cont = cont.replace("70.5556", "42.3333")
            else:
                cont = cont.replace("76.761147", "22.909904")
                cont = cont.replace("249.28143", "237.724")
                cont = cont.replace("70.5556", "38.8056")

            f_new.write(cont)
            f_new.close()

            # also convert to ico
            with Image(filename=f"output/svg/{e}.svg") as img:
                img.format = 'ico'
                img.resize(256,256)
                img.save(filename=f"output/ico/{e}.ico")


            qrc_cont += f"        <file>filetypes/{e}.ico</file>\n"

        iF += 1

    # add on the unknown filetype
    f_new = open(f"output/svg/unknown.svg", "w")
    cont = cont_default.replace("#MODMOD", f"#ffffff")
    cont = cont.replace("MOD", "?")
    cont = cont.replace("76.761147", "117.5511")
    cont = cont.replace("249.28143", "249.31589")
    cont = cont.replace("70.5556", "70.5556")
    f_new.write(cont)
    f_new.close()
    # also convert to ico
    with Image(filename=f"output/svg/unknown.svg") as img:
        img.format = 'ico'
        img.resize(256,256)
        img.save(filename=f"output/ico/unknown.ico")

    f_default.close()

    # save qrc file
    qrc_cont += "    </qresource>\n"
    qrc_cont += "</RCC>\n"

    f_qrc = open("output/filetypes.qrc", "w")
    f_qrc.write(qrc_cont)
    f_qrc.close()

#############################################################
#############################################################
# GENERATE CMAKE DESKTOP FILE CREATION
if which == 'all' or which == 'cmake':

    print("Generating addition to CMake ComposeDesktopFile()...")

    cont = "set(MIMETYPE \""
    i = 0
    for row in data:
        if row[1] != "":
            parts = row[1].split(",")
            for p in parts:
                if i%5 == 0 and i > 0:
                    cont += "\")\nset(MIMETYPE \"${MIMETYPE}"
                cont += f"{p};"
                i += 1
    cont += "\")\n\nfile(APPEND \"org.photoqt.photoqt.desktop\" \"MimeType=${MIMETYPE}\")\n"

    f_new = open("output/add_to_ComposeDesktopFile.cmake", "w")
    f_new.write(cont)
    f_new.close()

#############################################################
#############################################################
# GENERATE WINDOWS RESOURCE FILE
if which == 'all' or which == 'windowsrc':

    print("Generating windows resource file...")

    cont = "IDI_ICON1               ICON    DISCARDABLE     \"windows/icon.ico\"\n";

    iF = 2
    for row in data:

        endng = row[0].split(',')

        for e in endng:

            cont += f"{iF}               ICON    DISCARDABLE     \"img/filetypes/{e}.ico\"\n";

            iF += 1

    cont += f"{iF}               ICON    DISCARDABLE     \"img/filetypes/unknown.ico\"\n";

    f_new = open("output/windowsicons.rc", "w")
    f_new.write(cont)
    f_new.close()


#############################################################
#############################################################
# GENERATE NSI ENTRIES
if which == 'all' or which == 'nsi':

    print("Generating additions to FileAssociation.nsh...")

    # FileAssociation.nsh

    cont = ""

    iF = 1
    for row in data:

        endings = row[0].split(",")

        for e in endings:

            if iF == 1:
                cont += f"  ${{If}} $R1 == \".{e}\"\n"
            else:
                cont += f"  ${{ElseIf}} $R1 == \".{e}\"\n"
            cont += f"    StrCpy $3 \"{iF}\"\n"

            iF += 1

    cont += "  ${Else}\n"
    cont += f"    StrCpy $3 \"{iF}\"\n";
    cont += "  ${EndIf}\n"

    f_new = open("output/add_to_FileAssociation.nsh", "w")
    f_new.write(cont)
    f_new.close()

    #############################################################

    print("Generating additions to install script...")

    # register file extensions in install script

    cont = ""
    pdfcont = ""
    psdcont = ""

    un_cont = ""
    un_pdfcont = ""
    un_psdcont = ""

    for row in data:

        endings = row[0].split(",")
        
        desc = row[2]
        if ":" in desc:
            desc = desc.split(":")[1].strip()

        for e in endings:

            line = ""
            un_line = ""

            if endings[0] == "cb7":
                line = f"${{RegisterExtension}} \"$INSTDIR\photoqt.exe\" \".{e}\" \"{desc}\"\n"
                un_line = f"${{UnRegisterExtension}} \".{e}\" \"{desc}\"\n"
            else:
                line = f"${{RegisterExtension}} \"$INSTDIR\photoqt.exe\" \".{e}\" \"{desc}\"\n"
                un_line = f"${{UnRegisterExtension}} \".{e}\" \"{desc}\"\n"

            if endings[0] in ["eps", "pdf", "ps"]:
                pdfcont += line
                un_pdfcont += un_line
            elif endings[0] in ["psd", "xcf"]:
                psdcont += line
                un_psdcont += un_line
            elif row[4] == 1:
                cont += line
                un_cont += un_line

    f_new = open("output/register_extension", "w")
    f_new.write(cont)
    f_new.close()

    f_new = open("output/register_extension_pdf", "w")
    f_new.write(pdfcont)
    f_new.close()

    f_new = open("output/register_extension_psd", "w")
    f_new.write(psdcont)
    f_new.close()

    un_f_new = open("output/unregister_extension", "w")
    un_f_new.write(un_cont)
    un_f_new.close()

    un_f_new = open("output/unregister_extension_pdf", "w")
    un_f_new.write(un_pdfcont)
    un_f_new.close()

    un_f_new = open("output/unregister_extension_psd", "w")
    un_f_new.write(un_psdcont)
    un_f_new.close()

