import sqlite3
import numpy as np
import math
import seaborn as sns
import os
import glob
from wand.image import Image

# create database connection
conn = sqlite3.connect('../../misc/imageformats.db')
c = conn.cursor()

# get all data
c.execute('SELECT * FROM imageformats ORDER BY endings')
data = c.fetchall()

# remove all old data
os.makedirs('output/', exist_ok=True)
os.makedirs('output/svg', exist_ok=True)
os.makedirs('output/ico', exist_ok=True)
files = glob.glob('./output/svg/*')
for f in files:
    os.remove(f)
files = glob.glob('./output/ico/*')
for f in files:
    os.remove(f)
files = glob.glob('./output/*')
for f in files:
    if os.path.isfile(f):
        os.remove(f)


#############################################################
# GENERATE FILETYPES IN SUBDIRECTORY

print("Generating filetype icons...")

def rgb_to_hex(rgb):
    return '%02x%02x%02x' % (math.floor(rgb[0]*255), math.floor(rgb[1]*255), math.floor(rgb[2]*255))

f_default = open("templ.ate", "r")
cont_default = f_default.read()

# we add a few extra as some cases have special handling below
palette = sns.color_palette(None, len(data)+10)

iF = 0
for row in data:
    
    endng = [row[0].split(',')[0]]

    # comic book archives are treated seperately
    if endng[0] == "cb7":
        endng = row[0].split(",")

    for e in endng:

        f_new = open(f"output/svg/{e}.svg", "w")

        cont = cont_default.replace("#MODMOD", f"#{rgb_to_hex(palette[iF])}")
        cont = cont.replace("MOD", e.upper())

        if len(e) == 1:
            cont = cont.replace("76.761147", "117.5511")
            cont = cont.replace("249.28143", "249.31589")
            cont = cont.replace("70.5556", "70.5556")
        elif len(e) == 2:
            cont = cont.replace("76.761147", "98.809769")
            cont = cont.replace("249.28143", "249.78098")
            cont = cont.replace("70.5556", "70.5556")
        elif len(e) == 3:
            cont = cont.replace("76.761147", "76.761147")
            cont = cont.replace("249.28143", "249.28143")
            cont = cont.replace("70.5556", "70.5556")
        elif len(e) == 4:
            cont = cont.replace("76.761147", "55.212063")
            cont = cont.replace("249.28143", "249.31589")
            cont = cont.replace("70.5556", "70.5556")
        elif len(e) == 5:
            cont = cont.replace("76.761147", "34.076389")
            cont = cont.replace("249.28143", "248.81635")
            cont = cont.replace("70.5556", "70.5556")
        elif len(e) == 6:
            cont = cont.replace("76.761147", "25.339693")
            cont = cont.replace("249.28143", "246.65109")
            cont = cont.replace("70.5556", "63.5")
        elif len(e) == 7:
            cont = cont.replace("76.761147", "21.66")
            cont = cont.replace("249.28143", "244.17233")
            cont = cont.replace("70.5556", "56.4444")
        elif len(e) == 8:
            cont = cont.replace("76.761147", "21.401915")
            cont = cont.replace("249.28143", "241.57646")
            cont = cont.replace("70.5556", "49.3889")
        elif len(e) == 9:
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


#############################################################
# GENERATE WINDOWS RESOURCE FILE

print("Generating windows resource file...")

cont = "IDI_ICON1               ICON    DISCARDABLE     \"windows/icon.ico\"\n";

iF = 2
for row in data:
    
    endng = [row[0].split(',')[0]]

    # comic book archives are treated seperately
    if endng[0] == "cb7":
        endng = row[0].split(",")

    for e in endng:

        cont += f"IDI_ICON{iF}               ICON    DISCARDABLE     \"windows/filetypes/{e}.ico\"\n";

        iF += 1

cont += f"IDI_ICON{iF}               ICON    DISCARDABLE     \"windows/filetypes/unknown.ico\"\n";

f_new = open("output/windowsicons.rc", "w")
f_new.write(cont)
f_new.close()


#############################################################
# GENERATE NSI ENTRIES

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

        if endings[0] == "cb7":
            iF += 1

    if endings[0] != "cb7":
        iF += 1

cont += "  ${Else}\n"
cont += f"    StrCpy $3 \"{iF}\"\n";
cont += "  ${EndIf}\n"

f_new = open("output/add_to_FileAssociation.nsh", "w")
f_new.write(cont)
f_new.close()


#############################################################
# GENERATE NSI ENTRIES

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
    
    for e in endings:

        line = ""
        un_line = ""
        
        if endings[0] == "cb7":
            line = f"${{RegisterExtension}} \"$INSTDIR\photoqt.exe\" \".{e}\" \"pqt.{e}file\"\n"
            un_line = f"${{UnRegisterExtension}} \".{e}\" \"pqt.{endings[0]}file\"\n"
        else:
            line = f"${{RegisterExtension}} \"$INSTDIR\photoqt.exe\" \".{e}\" \"pqt.{endings[0]}file\"\n"
            un_line = f"${{UnRegisterExtension}} \".{e}\" \"pqt.{endings[0]}file\"\n"
        
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

