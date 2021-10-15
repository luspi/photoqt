import numpy as np
import math
import seaborn as sns

def rgb_to_hex(rgb):
    return '%02x%02x%02x' % (math.floor(rgb[0]*255), math.floor(rgb[1]*255), math.floor(rgb[2]*255))

f_col = open("color_codes", "r")
col = f_col.read().split("\n")

f_formats = open("formats", "r")
formats = f_formats.read().split("\n")

f_default = open("templ.ate", "r")
cont_default = f_default.read()

palette = sns.color_palette(None, len(formats))
#palette = sns.color_palette("cubehelix", as_cmap=True)


iF = 0
for f in formats:
#for code in col:

    if f == "":
        continue

    f_new = open(f"{f}.svg", "w")

    #cont = cont_default.replace("#MODMOD", f"#{col[iF]}")
    #print(iR, iG, iB, ":", RGB_tuples[iF])

    print(palette[iF])
    cont = cont_default.replace("#MODMOD", f"#{rgb_to_hex(palette[iF])}")
    cont = cont.replace("MOD", f.upper())

    if len(f) == 1:
        cont = cont.replace("76.761147", "117.5511")
        cont = cont.replace("249.28143", "249.31589")
        cont = cont.replace("70.5556", "70.5556")
    elif len(f) == 2:
        cont = cont.replace("76.761147", "98.809769")
        cont = cont.replace("249.28143", "249.78098")
        cont = cont.replace("70.5556", "70.5556")
    elif len(f) == 3:
        cont = cont.replace("76.761147", "76.761147")
        cont = cont.replace("249.28143", "249.28143")
        cont = cont.replace("70.5556", "70.5556")
    elif len(f) == 4:
        cont = cont.replace("76.761147", "55.212063")
        cont = cont.replace("249.28143", "249.31589")
        cont = cont.replace("70.5556", "70.5556")
    elif len(f) == 5:
        cont = cont.replace("76.761147", "34.076389")
        cont = cont.replace("249.28143", "248.81635")
        cont = cont.replace("70.5556", "70.5556")
    elif len(f) == 6:
        cont = cont.replace("76.761147", "25.339693")
        cont = cont.replace("249.28143", "246.65109")
        cont = cont.replace("70.5556", "63.5")
    elif len(f) == 7:
        cont = cont.replace("76.761147", "21.66")
        cont = cont.replace("249.28143", "244.17233")
        cont = cont.replace("70.5556", "56.4444")
    elif len(f) == 8:
        cont = cont.replace("76.761147", "21.401915")
        cont = cont.replace("249.28143", "241.57646")
        cont = cont.replace("70.5556", "49.3889")
    elif len(f) == 9:
        cont = cont.replace("76.761147", "25.856543")
        cont = cont.replace("249.28143", "238.77042")
        cont = cont.replace("70.5556", "42.3333")
    else:
        cont = cont.replace("76.761147", "22.909904")
        cont = cont.replace("249.28143", "237.724")
        cont = cont.replace("70.5556", "38.8056")

    f_new.write(cont)
    f_new.close()

    iF += 1

f_default.close()
