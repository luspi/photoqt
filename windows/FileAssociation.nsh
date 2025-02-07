/*
_____________________________________________________________________________

                       File Association
_____________________________________________________________________________

 Based on code taken from http://nsis.sourceforge.net/File_Association

 Usage in script:
 1. !include "FileAssociation.nsh"
 2. [Section|Function]
      ${FileAssociationFunction} "Param1" "Param2" "..." $var
    [SectionEnd|FunctionEnd]

 FileAssociationFunction=[RegisterExtension|UnRegisterExtension]

_____________________________________________________________________________

 ${RegisterExtension} "[executable]" "[extension]" "[description]"

"[executable]"     ; executable which opens the file format
                   ;
"[extension]"      ; extension, which represents the file format to open
                   ;
"[description]"    ; description for the extension. This will be display in Windows Explorer.
                   ;


 ${UnRegisterExtension} "[extension]" "[description]"

"[extension]"      ; extension, which represents the file format to open
                   ;
"[description]"    ; description for the extension. This will be display in Windows Explorer.
                   ;

_____________________________________________________________________________

                         Macros
_____________________________________________________________________________

 Change log window verbosity (default: 3=no script)

 Example:
 !include "FileAssociation.nsh"
 !insertmacro RegisterExtension
 ${FileAssociation_VERBOSE} 4   # all verbosity
 !insertmacro UnRegisterExtension
 ${FileAssociation_VERBOSE} 3   # no script
*/


!ifndef FileAssociation_INCLUDED
!define FileAssociation_INCLUDED

!include Util.nsh
!include LogicLib.nsh

!verbose push
!verbose 3
!ifndef _FileAssociation_VERBOSE
  !define _FileAssociation_VERBOSE 3
!endif
!verbose ${_FileAssociation_VERBOSE}
!define FileAssociation_VERBOSE `!insertmacro FileAssociation_VERBOSE`
!verbose pop

!macro FileAssociation_VERBOSE _VERBOSE
  !verbose push
  !verbose 3
  !undef _FileAssociation_VERBOSE
  !define _FileAssociation_VERBOSE ${_VERBOSE}
  !verbose pop
!macroend



!macro RegisterExtensionCall _EXECUTABLE _EXTENSION _DESCRIPTION
  !verbose push
  !verbose ${_FileAssociation_VERBOSE}
  Push `${_DESCRIPTION}`
  Push `${_EXTENSION}`
  Push `${_EXECUTABLE}`
  ${CallArtificialFunction} RegisterExtension_
  !verbose pop
!macroend

!macro UnRegisterExtensionCall _EXTENSION _DESCRIPTION
  !verbose push
  !verbose ${_FileAssociation_VERBOSE}
  Push `${_EXTENSION}`
  Push `${_DESCRIPTION}`
  ${CallArtificialFunction} UnRegisterExtension_
  !verbose pop
!macroend



!define RegisterExtension `!insertmacro RegisterExtensionCall`
!define un.RegisterExtension `!insertmacro RegisterExtensionCall`

!macro RegisterExtension
!macroend

!macro un.RegisterExtension
!macroend

!macro RegisterExtension_
  !verbose push
  !verbose ${_FileAssociation_VERBOSE}

  Exch $R2 ;exe
  Exch
  Exch $R1 ;ext
  Exch
  Exch 2
  Exch $R0 ;desc
  Exch 2
  Push $0
  Push $1
  Push $3

  ${If} $R1 == ".3fr"
    StrCpy $3 "1"
  ${ElseIf} $R1 == ".3fr"
    StrCpy $3 "2"
  ${ElseIf} $R1 == ".fff"
    StrCpy $3 "3"
  ${ElseIf} $R1 == ".3gp"
    StrCpy $3 "4"
  ${ElseIf} $R1 == ".3g2"
    StrCpy $3 "5"
  ${ElseIf} $R1 == ".7z"
    StrCpy $3 "6"
  ${ElseIf} $R1 == ".aai"
    StrCpy $3 "7"
  ${ElseIf} $R1 == ".ai"
    StrCpy $3 "8"
  ${ElseIf} $R1 == ".amv"
    StrCpy $3 "9"
  ${ElseIf} $R1 == ".ani"
    StrCpy $3 "10"
  ${ElseIf} $R1 == ".apng"
    StrCpy $3 "11"
  ${ElseIf} $R1 == ".ari"
    StrCpy $3 "12"
  ${ElseIf} $R1 == ".art"
    StrCpy $3 "13"
  ${ElseIf} $R1 == ".arw"
    StrCpy $3 "14"
  ${ElseIf} $R1 == ".asf"
    StrCpy $3 "15"
  ${ElseIf} $R1 == ".avi"
    StrCpy $3 "16"
  ${ElseIf} $R1 == ".avif"
    StrCpy $3 "17"
  ${ElseIf} $R1 == ".avifs"
    StrCpy $3 "18"
  ${ElseIf} $R1 == ".avs"
    StrCpy $3 "19"
  ${ElseIf} $R1 == ".x"
    StrCpy $3 "20"
  ${ElseIf} $R1 == ".mbfavs"
    StrCpy $3 "21"
  ${ElseIf} $R1 == ".bay"
    StrCpy $3 "22"
  ${ElseIf} $R1 == ".bmp"
    StrCpy $3 "23"
  ${ElseIf} $R1 == ".dib"
    StrCpy $3 "24"
  ${ElseIf} $R1 == ".bmq"
    StrCpy $3 "25"
  ${ElseIf} $R1 == ".bpg"
    StrCpy $3 "26"
  ${ElseIf} $R1 == ".cals"
    StrCpy $3 "27"
  ${ElseIf} $R1 == ".ct1"
    StrCpy $3 "28"
  ${ElseIf} $R1 == ".ct2"
    StrCpy $3 "29"
  ${ElseIf} $R1 == ".ct3"
    StrCpy $3 "30"
  ${ElseIf} $R1 == ".ct4"
    StrCpy $3 "31"
  ${ElseIf} $R1 == ".c4"
    StrCpy $3 "32"
  ${ElseIf} $R1 == ".cal"
    StrCpy $3 "33"
  ${ElseIf} $R1 == ".nif"
    StrCpy $3 "34"
  ${ElseIf} $R1 == ".ras"
    StrCpy $3 "35"
  ${ElseIf} $R1 == ".cap"
    StrCpy $3 "36"
  ${ElseIf} $R1 == ".eip"
    StrCpy $3 "37"
  ${ElseIf} $R1 == ".liq"
    StrCpy $3 "38"
  ${ElseIf} $R1 == ".cap"
    StrCpy $3 "39"
  ${ElseIf} $R1 == ".eip"
    StrCpy $3 "40"
  ${ElseIf} $R1 == ".liq"
    StrCpy $3 "41"
  ${ElseIf} $R1 == ".iiq"
    StrCpy $3 "42"
  ${ElseIf} $R1 == ".cb7"
    StrCpy $3 "43"
  ${ElseIf} $R1 == ".cbr"
    StrCpy $3 "44"
  ${ElseIf} $R1 == ".cbt"
    StrCpy $3 "45"
  ${ElseIf} $R1 == ".cbz"
    StrCpy $3 "46"
  ${ElseIf} $R1 == ".cg3"
    StrCpy $3 "47"
  ${ElseIf} $R1 == ".g3"
    StrCpy $3 "48"
  ${ElseIf} $R1 == ".cg4"
    StrCpy $3 "49"
  ${ElseIf} $R1 == ".g4"
    StrCpy $3 "50"
  ${ElseIf} $R1 == ".cine"
    StrCpy $3 "51"
  ${ElseIf} $R1 == ".crw"
    StrCpy $3 "52"
  ${ElseIf} $R1 == ".crr"
    StrCpy $3 "53"
  ${ElseIf} $R1 == ".cr2"
    StrCpy $3 "54"
  ${ElseIf} $R1 == ".cr3"
    StrCpy $3 "55"
  ${ElseIf} $R1 == ".cs1"
    StrCpy $3 "56"
  ${ElseIf} $R1 == ".cube"
    StrCpy $3 "57"
  ${ElseIf} $R1 == ".cur"
    StrCpy $3 "58"
  ${ElseIf} $R1 == ".cut"
    StrCpy $3 "59"
  ${ElseIf} $R1 == ".pal"
    StrCpy $3 "60"
  ${ElseIf} $R1 == ".dcr"
    StrCpy $3 "61"
  ${ElseIf} $R1 == ".kdc"
    StrCpy $3 "62"
  ${ElseIf} $R1 == ".drf"
    StrCpy $3 "63"
  ${ElseIf} $R1 == ".k25"
    StrCpy $3 "64"
  ${ElseIf} $R1 == ".dcs"
    StrCpy $3 "65"
  ${ElseIf} $R1 == ".dcr"
    StrCpy $3 "66"
  ${ElseIf} $R1 == ".kdc"
    StrCpy $3 "67"
  ${ElseIf} $R1 == ".drf"
    StrCpy $3 "68"
  ${ElseIf} $R1 == ".k25"
    StrCpy $3 "69"
  ${ElseIf} $R1 == ".dcs"
    StrCpy $3 "70"
  ${ElseIf} $R1 == ".dc2"
    StrCpy $3 "71"
  ${ElseIf} $R1 == ".kc2"
    StrCpy $3 "72"
  ${ElseIf} $R1 == ".dcx"
    StrCpy $3 "73"
  ${ElseIf} $R1 == ".dds"
    StrCpy $3 "74"
  ${ElseIf} $R1 == ".dfont"
    StrCpy $3 "75"
  ${ElseIf} $R1 == ".dic"
    StrCpy $3 "76"
  ${ElseIf} $R1 == ".dcm"
    StrCpy $3 "77"
  ${ElseIf} $R1 == ".djvu"
    StrCpy $3 "78"
  ${ElseIf} $R1 == ".djv"
    StrCpy $3 "79"
  ${ElseIf} $R1 == ".dng"
    StrCpy $3 "80"
  ${ElseIf} $R1 == ".dpx"
    StrCpy $3 "81"
  ${ElseIf} $R1 == ".dxo"
    StrCpy $3 "82"
  ${ElseIf} $R1 == ".epi"
    StrCpy $3 "83"
  ${ElseIf} $R1 == ".eps"
    StrCpy $3 "84"
  ${ElseIf} $R1 == ".epsf"
    StrCpy $3 "85"
  ${ElseIf} $R1 == ".epsi"
    StrCpy $3 "86"
  ${ElseIf} $R1 == ".ept"
    StrCpy $3 "87"
  ${ElseIf} $R1 == ".erf"
    StrCpy $3 "88"
  ${ElseIf} $R1 == ".exr"
    StrCpy $3 "89"
  ${ElseIf} $R1 == ".ff"
    StrCpy $3 "90"
  ${ElseIf} $R1 == ".fits"
    StrCpy $3 "91"
  ${ElseIf} $R1 == ".fit"
    StrCpy $3 "92"
  ${ElseIf} $R1 == ".fts"
    StrCpy $3 "93"
  ${ElseIf} $R1 == ".fl32"
    StrCpy $3 "94"
  ${ElseIf} $R1 == ".flv"
    StrCpy $3 "95"
  ${ElseIf} $R1 == ".f4v"
    StrCpy $3 "96"
  ${ElseIf} $R1 == ".ftx"
    StrCpy $3 "97"
  ${ElseIf} $R1 == ".gif"
    StrCpy $3 "98"
  ${ElseIf} $R1 == ".gpr"
    StrCpy $3 "99"
  ${ElseIf} $R1 == ".heif"
    StrCpy $3 "100"
  ${ElseIf} $R1 == ".heic"
    StrCpy $3 "101"
  ${ElseIf} $R1 == ".hrz"
    StrCpy $3 "102"
  ${ElseIf} $R1 == ".icns"
    StrCpy $3 "103"
  ${ElseIf} $R1 == ".ico"
    StrCpy $3 "104"
  ${ElseIf} $R1 == ".iff"
    StrCpy $3 "105"
  ${ElseIf} $R1 == ".jbig"
    StrCpy $3 "106"
  ${ElseIf} $R1 == ".jbg"
    StrCpy $3 "107"
  ${ElseIf} $R1 == ".bie"
    StrCpy $3 "108"
  ${ElseIf} $R1 == ".jfif"
    StrCpy $3 "109"
  ${ElseIf} $R1 == ".jng"
    StrCpy $3 "110"
  ${ElseIf} $R1 == ".jpeg"
    StrCpy $3 "111"
  ${ElseIf} $R1 == ".jpg"
    StrCpy $3 "112"
  ${ElseIf} $R1 == ".jpe"
    StrCpy $3 "113"
  ${ElseIf} $R1 == ".jif"
    StrCpy $3 "114"
  ${ElseIf} $R1 == ".jpeg2000"
    StrCpy $3 "115"
  ${ElseIf} $R1 == ".j2k"
    StrCpy $3 "116"
  ${ElseIf} $R1 == ".jp2"
    StrCpy $3 "117"
  ${ElseIf} $R1 == ".jpc"
    StrCpy $3 "118"
  ${ElseIf} $R1 == ".jpx"
    StrCpy $3 "119"
  ${ElseIf} $R1 == ".jxl"
    StrCpy $3 "120"
  ${ElseIf} $R1 == ".jxr"
    StrCpy $3 "121"
  ${ElseIf} $R1 == ".hdp"
    StrCpy $3 "122"
  ${ElseIf} $R1 == ".wdp"
    StrCpy $3 "123"
  ${ElseIf} $R1 == ".koa"
    StrCpy $3 "124"
  ${ElseIf} $R1 == ".gg"
    StrCpy $3 "125"
  ${ElseIf} $R1 == ".gig"
    StrCpy $3 "126"
  ${ElseIf} $R1 == ".kla"
    StrCpy $3 "127"
  ${ElseIf} $R1 == ".kra"
    StrCpy $3 "128"
  ${ElseIf} $R1 == ".lbm"
    StrCpy $3 "129"
  ${ElseIf} $R1 == ".mat"
    StrCpy $3 "130"
  ${ElseIf} $R1 == ".mdc"
    StrCpy $3 "131"
  ${ElseIf} $R1 == ".mef"
    StrCpy $3 "132"
  ${ElseIf} $R1 == ".mef"
    StrCpy $3 "133"
  ${ElseIf} $R1 == ".mfw"
    StrCpy $3 "134"
  ${ElseIf} $R1 == ".miff"
    StrCpy $3 "135"
  ${ElseIf} $R1 == ".mif"
    StrCpy $3 "136"
  ${ElseIf} $R1 == ".mkv"
    StrCpy $3 "137"
  ${ElseIf} $R1 == ".mng"
    StrCpy $3 "138"
  ${ElseIf} $R1 == ".mos"
    StrCpy $3 "139"
  ${ElseIf} $R1 == ".mov"
    StrCpy $3 "140"
  ${ElseIf} $R1 == ".qt"
    StrCpy $3 "141"
  ${ElseIf} $R1 == ".mp4"
    StrCpy $3 "142"
  ${ElseIf} $R1 == ".m4v"
    StrCpy $3 "143"
  ${ElseIf} $R1 == ".mpc"
    StrCpy $3 "144"
  ${ElseIf} $R1 == ".mpg"
    StrCpy $3 "145"
  ${ElseIf} $R1 == ".mp2"
    StrCpy $3 "146"
  ${ElseIf} $R1 == ".mpeg"
    StrCpy $3 "147"
  ${ElseIf} $R1 == ".mpe"
    StrCpy $3 "148"
  ${ElseIf} $R1 == ".mpv"
    StrCpy $3 "149"
  ${ElseIf} $R1 == ".m2v"
    StrCpy $3 "150"
  ${ElseIf} $R1 == ".mts"
    StrCpy $3 "151"
  ${ElseIf} $R1 == ".m2ts"
    StrCpy $3 "152"
  ${ElseIf} $R1 == ".ts"
    StrCpy $3 "153"
  ${ElseIf} $R1 == ".mtv"
    StrCpy $3 "154"
  ${ElseIf} $R1 == ".pic"
    StrCpy $3 "155"
  ${ElseIf} $R1 == ".mvg"
    StrCpy $3 "156"
  ${ElseIf} $R1 == ".mxf"
    StrCpy $3 "157"
  ${ElseIf} $R1 == ".nef"
    StrCpy $3 "158"
  ${ElseIf} $R1 == ".nrw"
    StrCpy $3 "159"
  ${ElseIf} $R1 == ".obm"
    StrCpy $3 "160"
  ${ElseIf} $R1 == ".ogg"
    StrCpy $3 "161"
  ${ElseIf} $R1 == ".ogv"
    StrCpy $3 "162"
  ${ElseIf} $R1 == ".ora"
    StrCpy $3 "163"
  ${ElseIf} $R1 == ".orf"
    StrCpy $3 "164"
  ${ElseIf} $R1 == ".orf"
    StrCpy $3 "165"
  ${ElseIf} $R1 == ".ori"
    StrCpy $3 "166"
  ${ElseIf} $R1 == ".otb"
    StrCpy $3 "167"
  ${ElseIf} $R1 == ".otf"
    StrCpy $3 "168"
  ${ElseIf} $R1 == ".otc"
    StrCpy $3 "169"
  ${ElseIf} $R1 == ".ttf"
    StrCpy $3 "170"
  ${ElseIf} $R1 == ".ttc"
    StrCpy $3 "171"
  ${ElseIf} $R1 == ".p7"
    StrCpy $3 "172"
  ${ElseIf} $R1 == ".palm"
    StrCpy $3 "173"
  ${ElseIf} $R1 == ".pam"
    StrCpy $3 "174"
  ${ElseIf} $R1 == ".pbm"
    StrCpy $3 "175"
  ${ElseIf} $R1 == ".pcd"
    StrCpy $3 "176"
  ${ElseIf} $R1 == ".pcds"
    StrCpy $3 "177"
  ${ElseIf} $R1 == ".pcx"
    StrCpy $3 "178"
  ${ElseIf} $R1 == ".pdb"
    StrCpy $3 "179"
  ${ElseIf} $R1 == ".pdd"
    StrCpy $3 "180"
  ${ElseIf} $R1 == ".pdf"
    StrCpy $3 "181"
  ${ElseIf} $R1 == ".pef"
    StrCpy $3 "182"
  ${ElseIf} $R1 == ".ptx"
    StrCpy $3 "183"
  ${ElseIf} $R1 == ".pes"
    StrCpy $3 "184"
  ${ElseIf} $R1 == ".pfb"
    StrCpy $3 "185"
  ${ElseIf} $R1 == ".pfm"
    StrCpy $3 "186"
  ${ElseIf} $R1 == ".afm"
    StrCpy $3 "187"
  ${ElseIf} $R1 == ".inf"
    StrCpy $3 "188"
  ${ElseIf} $R1 == ".pfa"
    StrCpy $3 "189"
  ${ElseIf} $R1 == ".ofm"
    StrCpy $3 "190"
  ${ElseIf} $R1 == ".pfm"
    StrCpy $3 "191"
  ${ElseIf} $R1 == ".pgm"
    StrCpy $3 "192"
  ${ElseIf} $R1 == ".pgx"
    StrCpy $3 "193"
  ${ElseIf} $R1 == ".phm"
    StrCpy $3 "194"
  ${ElseIf} $R1 == ".pic"
    StrCpy $3 "195"
  ${ElseIf} $R1 == ".picon"
    StrCpy $3 "196"
  ${ElseIf} $R1 == ".pict"
    StrCpy $3 "197"
  ${ElseIf} $R1 == ".pct"
    StrCpy $3 "198"
  ${ElseIf} $R1 == ".pic"
    StrCpy $3 "199"
  ${ElseIf} $R1 == ".pix"
    StrCpy $3 "200"
  ${ElseIf} $R1 == ".als"
    StrCpy $3 "201"
  ${ElseIf} $R1 == ".alias"
    StrCpy $3 "202"
  ${ElseIf} $R1 == ".png"
    StrCpy $3 "203"
  ${ElseIf} $R1 == ".ppm"
    StrCpy $3 "204"
  ${ElseIf} $R1 == ".pnm"
    StrCpy $3 "205"
  ${ElseIf} $R1 == ".ps"
    StrCpy $3 "206"
  ${ElseIf} $R1 == ".ps2"
    StrCpy $3 "207"
  ${ElseIf} $R1 == ".ps3"
    StrCpy $3 "208"
  ${ElseIf} $R1 == ".psd"
    StrCpy $3 "209"
  ${ElseIf} $R1 == ".psb"
    StrCpy $3 "210"
  ${ElseIf} $R1 == ".psd"
    StrCpy $3 "211"
  ${ElseIf} $R1 == ".psb"
    StrCpy $3 "212"
  ${ElseIf} $R1 == ".psdt"
    StrCpy $3 "213"
  ${ElseIf} $R1 == ".ptiff"
    StrCpy $3 "214"
  ${ElseIf} $R1 == ".ptif"
    StrCpy $3 "215"
  ${ElseIf} $R1 == ".pxn"
    StrCpy $3 "216"
  ${ElseIf} $R1 == ".pxr"
    StrCpy $3 "217"
  ${ElseIf} $R1 == ".qoi"
    StrCpy $3 "218"
  ${ElseIf} $R1 == ".qtk"
    StrCpy $3 "219"
  ${ElseIf} $R1 == ".r3d"
    StrCpy $3 "220"
  ${ElseIf} $R1 == ".raf"
    StrCpy $3 "221"
  ${ElseIf} $R1 == ".rar"
    StrCpy $3 "222"
  ${ElseIf} $R1 == ".raw"
    StrCpy $3 "223"
  ${ElseIf} $R1 == ".rwl"
    StrCpy $3 "224"
  ${ElseIf} $R1 == ".rdc"
    StrCpy $3 "225"
  ${ElseIf} $R1 == ".rgba"
    StrCpy $3 "226"
  ${ElseIf} $R1 == ".rgb"
    StrCpy $3 "227"
  ${ElseIf} $R1 == ".sgi"
    StrCpy $3 "228"
  ${ElseIf} $R1 == ".bw"
    StrCpy $3 "229"
  ${ElseIf} $R1 == ".rgbe"
    StrCpy $3 "230"
  ${ElseIf} $R1 == ".hdr"
    StrCpy $3 "231"
  ${ElseIf} $R1 == ".rad"
    StrCpy $3 "232"
  ${ElseIf} $R1 == ".rgf"
    StrCpy $3 "233"
  ${ElseIf} $R1 == ".rla"
    StrCpy $3 "234"
  ${ElseIf} $R1 == ".rle"
    StrCpy $3 "235"
  ${ElseIf} $R1 == ".rm"
    StrCpy $3 "236"
  ${ElseIf} $R1 == ".rw2"
    StrCpy $3 "237"
  ${ElseIf} $R1 == ".rwz"
    StrCpy $3 "238"
  ${ElseIf} $R1 == ".scr"
    StrCpy $3 "239"
  ${ElseIf} $R1 == ".sct"
    StrCpy $3 "240"
  ${ElseIf} $R1 == ".ch"
    StrCpy $3 "241"
  ${ElseIf} $R1 == ".ct"
    StrCpy $3 "242"
  ${ElseIf} $R1 == ".sfw"
    StrCpy $3 "243"
  ${ElseIf} $R1 == ".alb"
    StrCpy $3 "244"
  ${ElseIf} $R1 == ".pwm"
    StrCpy $3 "245"
  ${ElseIf} $R1 == ".pwp"
    StrCpy $3 "246"
  ${ElseIf} $R1 == ".sixel"
    StrCpy $3 "247"
  ${ElseIf} $R1 == ".srf"
    StrCpy $3 "248"
  ${ElseIf} $R1 == ".mrw"
    StrCpy $3 "249"
  ${ElseIf} $R1 == ".sr2"
    StrCpy $3 "250"
  ${ElseIf} $R1 == ".srf"
    StrCpy $3 "251"
  ${ElseIf} $R1 == ".mrw"
    StrCpy $3 "252"
  ${ElseIf} $R1 == ".sr2"
    StrCpy $3 "253"
  ${ElseIf} $R1 == ".arq"
    StrCpy $3 "254"
  ${ElseIf} $R1 == ".srw"
    StrCpy $3 "255"
  ${ElseIf} $R1 == ".sti"
    StrCpy $3 "256"
  ${ElseIf} $R1 == ".sun"
    StrCpy $3 "257"
  ${ElseIf} $R1 == ".ras"
    StrCpy $3 "258"
  ${ElseIf} $R1 == ".sr"
    StrCpy $3 "259"
  ${ElseIf} $R1 == ".im1"
    StrCpy $3 "260"
  ${ElseIf} $R1 == ".im24"
    StrCpy $3 "261"
  ${ElseIf} $R1 == ".im32"
    StrCpy $3 "262"
  ${ElseIf} $R1 == ".im8"
    StrCpy $3 "263"
  ${ElseIf} $R1 == ".rast"
    StrCpy $3 "264"
  ${ElseIf} $R1 == ".rs"
    StrCpy $3 "265"
  ${ElseIf} $R1 == ".scr"
    StrCpy $3 "266"
  ${ElseIf} $R1 == ".svg"
    StrCpy $3 "267"
  ${ElseIf} $R1 == ".svgz"
    StrCpy $3 "268"
  ${ElseIf} $R1 == ".tar"
    StrCpy $3 "269"
  ${ElseIf} $R1 == ".tga"
    StrCpy $3 "270"
  ${ElseIf} $R1 == ".icb"
    StrCpy $3 "271"
  ${ElseIf} $R1 == ".vda"
    StrCpy $3 "272"
  ${ElseIf} $R1 == ".vst"
    StrCpy $3 "273"
  ${ElseIf} $R1 == ".tiff"
    StrCpy $3 "274"
  ${ElseIf} $R1 == ".tif"
    StrCpy $3 "275"
  ${ElseIf} $R1 == ".tim"
    StrCpy $3 "276"
  ${ElseIf} $R1 == ".ttf"
    StrCpy $3 "277"
  ${ElseIf} $R1 == ".unknown"
    StrCpy $3 "278"
  ${ElseIf} $R1 == ".vicar"
    StrCpy $3 "279"
  ${ElseIf} $R1 == ".vic"
    StrCpy $3 "280"
  ${ElseIf} $R1 == ".img"
    StrCpy $3 "281"
  ${ElseIf} $R1 == ".viff"
    StrCpy $3 "282"
  ${ElseIf} $R1 == ".xv"
    StrCpy $3 "283"
  ${ElseIf} $R1 == ".vob"
    StrCpy $3 "284"
  ${ElseIf} $R1 == ".vtf"
    StrCpy $3 "285"
  ${ElseIf} $R1 == ".wbmp"
    StrCpy $3 "286"
  ${ElseIf} $R1 == ".webm"
    StrCpy $3 "287"
  ${ElseIf} $R1 == ".webp"
    StrCpy $3 "288"
  ${ElseIf} $R1 == ".wmf"
    StrCpy $3 "289"
  ${ElseIf} $R1 == ".wmz"
    StrCpy $3 "290"
  ${ElseIf} $R1 == ".apm"
    StrCpy $3 "291"
  ${ElseIf} $R1 == ".wmv"
    StrCpy $3 "292"
  ${ElseIf} $R1 == ".wpg"
    StrCpy $3 "293"
  ${ElseIf} $R1 == ".x3f"
    StrCpy $3 "294"
  ${ElseIf} $R1 == ".xbm"
    StrCpy $3 "295"
  ${ElseIf} $R1 == ".bm"
    StrCpy $3 "296"
  ${ElseIf} $R1 == ".xcf"
    StrCpy $3 "297"
  ${ElseIf} $R1 == ".xpm"
    StrCpy $3 "298"
  ${ElseIf} $R1 == ".pm"
    StrCpy $3 "299"
  ${ElseIf} $R1 == ".xwd"
    StrCpy $3 "300"
  ${ElseIf} $R1 == ".zip"
    StrCpy $3 "301"
  ${Else}
    StrCpy $3 "302"
  ${EndIf}

  ReadRegStr $1 HKCR $R1 ""  ; read current file association
  StrCmp "$1" "" NoBackup  ; is it empty
  StrCmp "$1" "$R0" NoBackup  ; is it our own
    WriteRegStr HKCR $R1 "backup_val" "$1"  ; backup current value
NoBackup:
  WriteRegStr HKCR $R1 "" "$R0"  ; set our file association

  ReadRegStr $0 HKCR $R0 ""
  StrCmp $0 "" 0 Skip
    WriteRegStr HKCR "$R0" "" "$R0"
    WriteRegStr HKCR "$R0\shell" "" "open"
    WriteRegStr HKCR "$R0\DefaultIcon" "" "$R2,$3"
Skip:
  WriteRegStr HKCR "$R0\shell\open\command" "" '"$R2" "%1"'

  Pop $3
  Pop $1
  Pop $0
  Pop $R2
  Pop $R1
  Pop $R0

  !verbose pop
!macroend



!define UnRegisterExtension `!insertmacro UnRegisterExtensionCall`
!define un.UnRegisterExtension `!insertmacro UnRegisterExtensionCall`

!macro UnRegisterExtension
!macroend

!macro un.UnRegisterExtension
!macroend

!macro UnRegisterExtension_
  !verbose push
  !verbose ${_FileAssociation_VERBOSE}

  Exch $R1 ;desc
  Exch
  Exch $R0 ;ext
  Exch
  Push $0
  Push $1

  ReadRegStr $1 HKCR $R0 ""
  StrCmp $1 $R1 0 NoOwn ; only do this if we own it
  ReadRegStr $1 HKCR $R0 "backup_val"
  StrCmp $1 "" 0 Restore ; if backup="" then delete the whole key
  DeleteRegKey HKCR $R0
  Goto NoOwn

Restore:
  WriteRegStr HKCR $R0 "" $1
  DeleteRegValue HKCR $R0 "backup_val"
  DeleteRegKey HKCR $R1 ;Delete key with association name settings

NoOwn:

  Pop $1
  Pop $0
  Pop $R1
  Pop $R0

  !verbose pop
!macroend

!endif # !FileAssociation_INCLUDED
