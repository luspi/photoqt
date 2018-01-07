##############################################################################
#
#  PROJECT:     Multi Theft Auto v1.0
#  LICENSE:     See LICENSE in the top level directory
#  FILE:        utils/build_gettext_catalog.py
#  PURPOSE:     Build a multi-language .NSI script based upon input PO files
#  DEVELOPERS:  Dan Chowdhury <>
#
#  Multi Theft Auto is available from http://www.multitheftauto.com/
#
#
#  Below script adjusted to fit PhotoQt's needs by: Lukas Spies
#
##############################################################################
import collections
import os
import polib
from optparse import OptionParser

options_input = "photoqt-32bit.nsi"
options_output = "photoqt_multilang-32bit.nsi"
options_podir = "" + os.getcwd() + "/lang/" + ""
options_lang = "English"

# Define a dict to convert locale names to language names
localeToName = {
	"af" : "Afrikaans",
	"sq" : "Albanian",
	"ar" : "Arabic",
	"hy" : "Armenian",
	"eu" : "Basque",
	"be" : "Belarusian",
	"bs" : "Bosnian",
	"br" : "Breton",
	"bg" : "Bulgarian",
	"ca" : "Catalan",
	"bem" : "Cibemba",
	"hr" : "Croatian",
	"cs" : "Czech",
	"da" : "Danish",
	"nl" : "Dutch",
	"efi" : "Efik",
	"en" : "English",
	"eo" : "Esperanto",
	"et" : "Estonian",
	"fa" : "Farsi",
	"fi" : "Finnish",
	"fr" : "French",
	"gl" : "Galician",
	"ka" : "Georgian",
	"de" : "German",
	"el" : "Greek",
	"he" : "Hebrew",
	"hi" : "Hindi",
	"hu" : "Hungarian",
	"is" : "Icelandic",
	"ig" : "Igbo",
	"id" : "Indonesian",
	"ga" : "Irish",
	"it" : "Italian",
	"ja" : "Japanese",
	"km" : "Khmer",
	"ko" : "Korean",
	"ku" : "Kurdish",
	"lv" : "Latvian",
	"lt" : "Lithuanian",
	"lb" : "Luxembourgish",
	"mk" : "Macedonian",
	"mg" : "Malagasy",
	"ms" : "Malay",
	"mn" : "Mongolian",
	"nb" : "Norwegian",
	"nn" : "NorwegianNynorsk",
	"ps" : "Pashto",
	"pl" : "Polish",
	"pt" : "Portuguese",
	"pt_BR" : "PortugueseBR",
	"ro" : "Romanian",
	"ru" : "Russian",
	"sr" : "Serbian",
	"sr_sp" : "SerbianLatin",
	"st" : "Sesotho",
	"sn" : "Shona",
	"zh_CN" : "SimpChinese",
	"sk" : "Slovak",
	"sl" : "Slovenian",
	"es" : "Spanish",
	"es_AR" : "SpanishInternational",
	"sw" : "Swahili",
	"sv" : "Swedish",
	"ta" : "Tamil",
	"th" : "Thai",
	"zh_HK" : "TradChinese",
	"tr" : "Turkish",
	"tw" : "Twi",
	"uk" : "Ukrainian",
	"ug" : "Uyghur",
	"uz" : "Uzbek",
	"ca@valencia" : "Valencian",
	"vi" : "Vietnamese",
	"cy" : "Welsh",
	"yo" : "Yoruba",
	"zu" : "Zulu",
}

def escapeNSIS(st):
	return st.replace('\\', r'$\\')\
			.replace('\t', r'$\t')\
			.replace('\r', r'\r')\
			.replace('\n', r'\n')\
			.replace('\"', r'$\"')\
			.replace('$$\\', '$\\')

translationCache = {}

# The purpose of this loop is to go to the podir scanning for PO files for each locale name
# Once we've found a PO file, we use PO lib to read every translated entry
# Using this, for each each language, we store a dict of entries - { nsilabel (comment) : translation (msgstr) }
# For untranslated entries, we use msgid instead of msgstr (i.e. default English string)
for root,dirs,files in os.walk(options_podir):
	for file in files:
		filename,ext = os.path.splitext(file)
		if ext == ".po":
			# Valid locale filename (fr.po, de.po etc)?
			if filename in localeToName:
				language = localeToName[filename]
				translationCache[language] = collections.OrderedDict()

				# Let's add a default LANGUAGE_CODE LangString to be read
				translationCache[language]["LANGUAGE_CODE"] = filename

				po = polib.pofile(os.path.join(root,file))
				for entry in po.translated_entries():
					# Loop through all our labels and add translation (each translation may have multiple labels)
					for label in entry.comment.split():
						translationCache[language][label] = escapeNSIS(entry.msgstr)
				# For untranslated strings, let's add the English entry
				for entry in po.untranslated_entries():
					for label in entry.comment.split():
						print("Warning: Label '%s' for language '%s' remains untranslated"%(label,language))
						translationCache[language][label] = escapeNSIS(entry.msgid)


# Open our source NSI, dump it to a list and close it
NSISourceFile = open(options_input,"r")
NSISourceLines = NSISourceFile.readlines()
NSISourceFile.close()
NSINewLines = []

def tostr(obj):
	if type(obj) == unicode:
		return obj.encode("utf-8")
	else:
		return obj

# Here we scan for ";@INSERT_TRANSLATIONS@" in the NSIS, and add MUI_LANGUAGE macros and LangString's for translation languages
lineNo = 1
for line in NSISourceLines:
	if line.strip().find(";@INSERT_TRANSLATIONS@") == 0:
		for language,translations in translationCache.iteritems():
			count = 0
			# if the language isn't the default, we add our MUI_LANGUAGE macro
			if language.upper() != options_lang.upper():
				NSINewLines.append('!insertmacro MUI_LANGUAGE "' + language + '"\n')
			# For every translation we grabbed from the .po, let's add our LangString
			for label,value in translations.iteritems():
				NSINewLines.append( 'LangString ' + label + ' ${LANG_' + language + '} "' + value + '"\n')
				count += 1
			print ( "%i translations merged for language '%s'"%(count,language) )
	else:
		NSINewLines.append ( line )

# Finally, let's write our new .nsi to the desired target file
NSIWorkingFile = open(options_output,"w")
for newline in NSINewLines:
	NSIWorkingFile.write(newline.encode('utf-8'))
NSIWorkingFile.close()

print("\n\nNSI Localization Operation Complete\n")
