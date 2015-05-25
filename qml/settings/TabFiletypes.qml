import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import "../elements"


Rectangle {

	id: tab

	color: "#00000000"

	anchors {
		fill: parent
		leftMargin: 20
		rightMargin: 20
		topMargin: 15
		bottomMargin: 5
	}

	Flickable {

		id: flickable

		clip: true

		anchors.fill: parent

		contentHeight: contentItem.childrenRect.height+50
		contentWidth: tab.width

		boundsBehavior: Flickable.StopAtBounds

		Column {

			id: maincol

			spacing: 30

			/**********
			* HEADER *
			**********/

			Rectangle {
				id: header
				width: flickable.width
				height: childrenRect.height
				color: "#00000000"
				Text {
					color: "white"
					font.pointSize: 18
					font.bold: true
					text: qsTr("Filetypes")
					anchors.horizontalCenter: parent.horizontalCenter
				}
			}


			/*******************
			* FILE TYPES - QT *
			*******************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("File Types - Qt") + "</h2><br>" + qsTr("These are the file types natively supported by Qt. Make sure, that you'll have the required libraries installed (e.g., qt5-imageformats), otherwise some of them might not work on your system.<br>If a file ending for one of the formats is missing, you can add it below, formatted like '*.ending' (without single quotation marks), multiple entries seperated by commas.")

			}

			GridView {
				width: parent.width
				boundsBehavior: GridView.StopAtBounds
				height: childrenRect.height
				model: ListModel { id: modelqt}
				delegate: TabFiletypesTiles { text: _labelling; checked: _checked }
			}


			Rectangle {

				width: parent.width
				height: childrenRect.height
				color: "#00000000"

				Text {
					id: extralabel
					y: (extrasQt.height-height)/2
					color: "white"
					text: qsTr("Extra File Types:")
					anchors.left: parent.left
				}

				CustomTextEdit {
					id: extrasQt
					anchors.left: extralabel.right
					anchors.leftMargin: 5
					border.width: 1
					width: 400
					border.color: colour_fadein_border
				}

				CustomButton {
					id: marknoneqt
					y: (extrasQt.height-height)/2
					text: qsTr("Mark None")
					anchors.right: parent.right
					onClickedButton: setModel(false,"qt")
				}
				CustomButton {
					id: markallqt
					text: qsTr("Mark All")
					y: (extrasQt.height-height)/2
					anchors.right: marknoneqt.left
					anchors.rightMargin: 5
					onClickedButton: setModel(true,"qt")
				}

			}


			/*******************
			* FILE TYPES - GM *
			*******************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("File Types - GraphicsMagick") + "</h2><br>" + qsTr("PhotoQt makes use of GraphicsMagick for support of many different image formats. The list below are all those formats, that were successfully displayed using test images. If you prefer not to have one or the other enabled in PhotoQt, you can simply disable individual formats below.<br>There are a few formats, that were not tested in PhotoQt (due to lack of a test image). You can find those in the 'Untested' category below.")

			}

			GridView {
				boundsBehavior: GridView.StopAtBounds
				width: parent.width
				height: childrenRect.height
				model: ListModel { id: modelgm}
				delegate: TabFiletypesTiles { text: _labelling; checked: _checked }
			}

			Rectangle {

				width: parent.width
				height: childrenRect.height
				color: "#00000000"

				CustomButton {
					id: marknonegm
					text: qsTr("Mark None")
					anchors.right: parent.right
					onClickedButton: setModel(false,"gm")
				}
				CustomButton {
					id: markallgm
					text: qsTr("Mark All")
					anchors.right: marknonegm.left
					anchors.rightMargin: 5
					onClickedButton: setModel(true,"gm")
				}

			}


			/****************************
			* FILE TYPES - GHOSTSCRIPT *
			****************************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("File Types - GraphicsMagick (requires Ghostscript)") + "</h2><br>" + qsTr("The following file types are supported by GraphicsMagick, and they have been tested and work. However, they require Ghostscript to be installed on the system.")

			}

			GridView {
				boundsBehavior: GridView.StopAtBounds
				width: parent.width
				height: childrenRect.height
				model: ListModel { id: modelgs}
				delegate: TabFiletypesTiles { text: _labelling; checked: _checked }
			}

			Rectangle {

				width: parent.width
				height: childrenRect.height
				color: "#00000000"

				CustomButton {
					id: marknoneghostscript
					text: qsTr("Mark None")
					anchors.right: parent.right
					onClickedButton: setModel(false,"gs")
				}
				CustomButton {
					id: markallghostscript
					text: qsTr("Mark All")
					anchors.right: marknoneghostscript.left
					anchors.rightMargin: 5
					onClickedButton: setModel(true,"gs")
				}

			}



			/*************************
			* FILE TYPES - EXTERNAL *
			*************************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("File Types - Other tools required") + "</h2><br>" + qsTr("The following filetypes are supported by means of other third party tools. You first need to install them before you can use them.") + "<br><br><b>" + qsTr("Note") + "</b>: " + qsTr("If an image format is also provided by GraphicsMagick/Qt, then PhotoQt first chooses the external tool (if enabled).")

			}

			Rectangle {

				color: "#00000000"
				x: (parent.width-width)/2

				width: childrenRect.width
				height: childrenRect.height

				Column {

					spacing: 10

					Row {

					spacing: 10

						TabFiletypesTiles {
							id: xcftools
							text: "*.xcf"
						}

						Text {

							y: (xcftools.height-height)/2

							color: "white"
							//: 'Makes use of' is in connection with an external tool (i.e., it 'makes use of' tool abc)
							text: qsTr("Gimp's XCF file format.") + "<br><br>" + qsTr("Makes use of") + ": xcftools - https://github.com/j-jorge/xcftools"

						}

					}


					Row {

						spacing: 10

						TabFiletypesTiles {
							id: libqpsd
							text: "*.psb, *psd"
						}

						Text {

							y: (libqpsd.height-height)/2

							color: "white"
							text: qsTr("Adobe Photoshop PSD and PSB.") + "<br><br>" + qsTr("Makes use of") + ": libqpsd - https://github.com/Code-ReaQtor/libqpsd"

						}

					}

				}

			}



			/*************************
			* FILE TYPES - UNTESTED *
			*************************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("File Types - GraphicsMagick (Untested)") + "</h2><br>" + qsTr("The following file types are generally supported by GraphicsMagick, but I wasn't able to test them in PhotoQt (due to lack of test images). They might very well be working, but I simply can't say. If you decide to enable some of the, the worst that could happen ist, that you see an error image instead of the actual image.") + "<br><br><i>" + qsTr("If you happen to have an image in one of those formats and don't mind sending it to me, that'd be really cool...") + "</i>"

			}

			GridView {
				boundsBehavior: GridView.StopAtBounds
				width: parent.width
				height: childrenRect.height
				model: ListModel { id: modeluntested}
				delegate: TabFiletypesTiles { text: _labelling; checked: _checked }
			}

			Rectangle {

				width: parent.width
				height: childrenRect.height
				color: "#00000000"

				CustomButton {
					id: marknoneuntested
					text: qsTr("Mark None")
					anchors.right: parent.right
					onClickedButton: setModel(false,"untested")
				}
				CustomButton {
					id: markalluntested
					text: qsTr("Mark All")
					anchors.right: marknoneuntested.left
					anchors.rightMargin: 5
					onClickedButton: setModel(true,"untested")
				}

			}

		}

	}

	function setData() {
		setModel(true,"default")
	}

	function setModel(mark, cat) {

		if(cat === "default" || cat === "qt") {

			modelqt.clear()

			var qt = ["Bitmap", "*.bmp, *.bitmap",
				"Direct Draw Surface", "*.dds",
				"Graphics Interchange Format (GIF)", "*.gif",
				"Microsoft Icon", "*.ico, *.icns",
				"Joint Photographic Experts Group (JPEG)", "*.jpg, *.jpeg",
				"JPEG-2000", "*.jpeg2000, *.jp2, *.jpc, *.j2k, *.jpf, *.jpx, *.jpm, *.mj2",
				"Multiple-image Network Graphics", "*.mng",
				"Portable Network Graphics (PNG)", "*.png",
				"Portable bitmap", "*.pbm",
				"*.pgm", "Portable graymap", "*.pgm",
				"Portable pixmap", "*.ppm",
				"Scalable Vector Graphics (SVG)", "*.svg, *.svgz",
				"Tagged Image File Format (TIF)", "*.tif, *.tiff",
				"Wireless bitmap", "*.wbmp, *.webp",
				"X Windows system bitmap", "*.xbm",
				"X Windows system pixmap", "*.xpm"]

			for(var i = 0; i < qt.length; i+=2)
				modelqt.append({"_labelling" : qt[i], "_checked" : mark })

		}

		if(cat === "default" || cat === "gm") {

			modelgm.clear()

			var gm = ["AVS X image", "__*.avs, *.x",
				"Continuous Acquisition and Life-cycle Support Type 1", "*.cals, *.cal, *.dcl, *.ras",
				"Kodak Cineon", "*.cin",
				"Dr Halo", "*.cut",
				"Digital Imaging and Communications in Medicine (DICOM)", "*.acr, *.dcm, *.dicom, *.dic",
				"ZSoft IBM PC multi-page Paintbrush image", "*.dcx",
				"Microsoft Windows Device Independent Bitmap", "*.dib",
				"Digital Moving Picture Exchange", "*.dpx",
				"Encapsulated PDF", "*.epdf",
				"Group 3 FAX", "*.fax",
				"Flexible Image Transport System", "*.fits, *.fts, *.fit",
				"FlashPix Format", "*.fpx",
				"JPEG Network Graphics", "*.jng",
				"MATLAB image format", "*.mat",
				"Magick image file format", "*.miff",
				"Bi-level bitmap in least-significant-byte first order", "*.mono",
				"MTV Raytracing image format", "*.mtv",
				"On-the-air Bitmap", "*.otb",
				"Xv's Visual Schnauzer thumbnail format", "*.p7",
				"Palm pixmap", "*.palm",
				"Portable Arbitrary Map", "*.pam",
				"Photo CD", "*.pcd, *.pcds",
				"ZSoft IBM PC Paintbrush file", "*.pcx",
				"Palm Database ImageViewer Format", "*.pdb",
				"Apple Macintosh QuickDraw/PICT file", "*.pict, *.pct, *.pic",
				"Alias/Wavefront RLE image format", "*.pix, *.pal",
				"Portable anymap", "*.pnm",
				"Adobe Photoshop bitmap file", "*.psd",
				"Pyramid encoded TIFF", "*.ptif, *.ptiff",
				"Seattle File Works image", "*.sfw",
				"Irix RGB image", "*.sgi",
				"SUN Rasterfile", "*.sun",
				"Truevision Targa image", "*.tga",
				"Text files", "*.txt",
				"VICAR rasterfile format", "*.vicar",
				"Khoros Visualization Image File Format", "*.viff",
				"Word Perfect Graphics File", "*.wpg",
				"X Windows system window dump", "*.xwd"]

			for(var j = 0; j < gm.length; j+=2)
				modelgm.append({"_labelling" : gm[j], "_checked" : mark })

		}

		if(cat === "default" || cat === "gs") {

			modelgs.clear()

			var gs = ["Encapsulated PostScript","*.eps, *.epsf",
				"Encapsulated PostScript Interchange","*.epi, *.epsi, *.ept",
				"Level II Encapsulated PostScript","*.eps2",
				"Level III Encapsulated PostScript","*.eps3",
				"Portable Document Format","*.pdf",
				"Adobe PostScript","*.ps",
				"Adobe Level II PostScript","*.ps2",
				"Adobe Level III PostScript","*.ps3"]

			for(var k = 0; k < gs.length; k+=2)
				modelgs.append({"_labelling" : gs[k], "_checked" : mark })

		}

		if(cat === "default" || cat === "untested") {

			if(cat === "default") mark = false

			modeluntested.clear()

			var untested = ["HP-GL plotter language","*.hp, *.hpgl",
					"Joint Bi-level Image experts Group file interchange format","*.jbig, *.jbg",
					"Seattle File Works multi-image file","*.pwp",
					"Sun Raster Image","*.rast",
					"Alias/Wavefront image","*.rla",
					"Utah Run length encoded image","*.rle",
					"Scitex Continuous Tone Picture","*.sct",
					"PSX TIM file","*.tim"]

			for(var l = 0; l < untested.length; l+=2)
				modeluntested.append({"_labelling" : untested[l], "_checked" : mark })

		}

	}

}
