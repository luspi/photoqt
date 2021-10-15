import numpy as np

f_formats = open("formats", "r")
formats = f_formats.read().split("\n")

cont = "IDI_ICON1               ICON    DISCARDABLE     \"windows/icon.ico\"\n";

iF = 2
for f in formats:

    if f == "":
        continue

    cont += f"IDI_ICON{iF}               ICON    DISCARDABLE     \"windows/filetypes/{f}.ico\"\n";

    iF += 1

f_new = open("windowsicons.rc", "w")
f_new.write(cont)
f_new.close()

f_formats.close()
