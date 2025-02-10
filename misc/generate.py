##########################################################################
##                                                                      ##
## Copyright (C) 2011-2023 Lukas Spies                                  ##
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

known_args = np.array(['all', 'filetypecolors', 'filetypes', 'cmake', 'windowsrc', 'nsi'])

if len(sys.argv) != 2 or sys.argv[1] not in known_args:

    print("""
One of the following flags is required:

 all\t\tGenerate all items
 filetypecolors\tCHeck filetype colors and add any new/missing ones
 filetypes\tGenerate filetype icons
 cmake\t\tGenerate CMake desktop file creation
 windowsrc\tGenerate windows resource file
 nsi\t\tGenerate nsi entries
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
                        
            if e == "svg" or e == "svgz":
                category = "svg"
            
            fname_large = f"output/svg/large/{e}.svg"
            fname_small = f"output/svg/small/{e}.svg"
            fname_squared = f"output/svg/squared/{e}.svg"
            
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

    print("Generating additions to FileAssociation.nsh...")
    
    conn2 = sqlite3.connect('icons/iconcolors.db')
    c2 = conn2.cursor()

    c2.execute("SELECT endings FROM colors ORDER BY endings")
    data2 = c2.fetchall()

    # FileAssociation.nsh

    cont = ""

    iF = 1
    for row in data2:

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
    
    # create database connection
    conn = sqlite3.connect('imageformats.db')
    c = conn.cursor()

    # get all data
    c.execute('SELECT * FROM imageformats ORDER BY endings')
    data = c.fetchall()

    # register file extensions in install script

    cont = ""
    pdfcont = ""
    psdcont = ""

    un_cont = ""
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

            line = f"${{RegisterExtension}} \"$INSTDIR\\photoqt.exe\" \".{e}\" \"{desc}\"\n"
            un_line = f"${{UnRegisterExtension}} \".{e}\" \"{desc}\"\n"

            if endings[0] in ["eps", "pdf", "ps"]:
                pdfcont += line
                un_pdfcont += un_line
            elif endings[0] in ["psd", "xcf"]:
                psdcont += line
                un_psdcont += un_line
            elif row[5] == 1:
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

