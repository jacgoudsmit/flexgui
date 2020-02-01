#
# Makefile for flexgui
#
# Options:
# make install INSTALL=dir
#    Makes for Linux or Mac; requires Tcl/Tk to already be installed
# make zip SIGN=sign_script
#    Makes for Windows, linking against prebuild Tcl/Tk libraries in $(TCLROOT)
#    Final output is in flexgui.zip
#

default: errmessage
zip: flexgui.zip

# where to install: default is $(HOME)/flexgui
INSTALL ?= $(HOME)/flexgui

# detect OS
ifndef OS
	UNAME := $(shell uname)
	ifeq ($(UNAME),Darwin)
		OS := macosx
	endif
	ifeq ($(UNAME),Linux)
		OS := linux
	endif
	ifndef OS
		OS := unix
	endif
endif

ifndef OPENSPIN
	OPENSPIN := $(shell which openspin)
endif

errmessage:
	@echo
	@echo "Usage:"
	@echo "  make install"
	@echo "  make zip SIGN=signscript"
	@echo
	@echo "make install copies flexgui to the INSTALL directory (default is $(HOME)/flexgui)"
	@echo "for example to install in /opt/flexgui do:"
	@echo "    make install INSTALL=/opt/flexgui"
	@echo
	@echo "make zip creates a flexgui.zip for Windows"
	@echo "    This requires cross tools and is probably not what you want"
	@echo
ifndef OPENSPIN
	@echo "Note that the P1 version of flexgui depends on openspin being installed; if it is not,"
	@echo "  then only P2 support is enabled"
endif

#
# binaries to make
#

EXEBINFILES=bin/fastspin.exe bin/loadp2.exe bin/fastspin.mac bin/loadp2.mac bin/mac_terminal.sh
EXEFILES=flexgui.exe $(EXEBINFILES)

ifdef OPENSPIN
WIN_BINARIES=$(EXEFILES) bin/proploader.exe
NATIVE_BINARIES=bin/fastspin bin/loadp2 bin/proploader
else
WIN_BINARIES=$(EXEFILES)
NATIVE_BINARIES=bin/fastspin bin/loadp2
endif

install: flexgui_base $(NATIVE_BINARIES)
	mkdir -p $(INSTALL)
	mkdir -p flexgui/bin
	cp -r $(NATIVE_BINARIES) flexgui/bin
	cp -r mac_scripts/* flexgui/bin
	cp -r flexgui/* $(INSTALL)

# where the Tcl and Tk source code are checked out (side by side)
TCLROOT ?= /home/ersmith/src/Tcl

# if pandoc exists we can convert .md files to .pdf, but if it
# doesn't we want the build to still succeeed, just without
# the .pdfs
PANDOC := pandoc
PANDOC_EXISTS := $(shell $(PANDOC) --version 2>/dev/null)

WINGCC = i686-w64-mingw32-gcc
WINRC = i686-w64-mingw32-windres
WINCFLAGS = -Os -DUNICODE -D_UNICODE -D_ATL_XP_TARGETING -DSTATIC_BUILD=1 -DUSE_TCL_STUBS
WINLIBS = -lnetapi32 -lkernel32 -luser32 -ladvapi32 -luserenv -lws2_32 -lgdi32 -lcomdlg32 -limm32 -lcomctl32 -lshell32 -luuid -lole32 -loleaut32

RESDIR=src/rc
RES_RC=$(RESDIR)/wish.rc
RESOBJ=$(RESDIR)/wish.res.o

WINTK_INC = -I$(TCLROOT)/tk/xlib -I$(TCLROOT)/tcl/win -I$(TCLROOT)/tcl/generic -I$(TCLROOT)/tk/win -I$(TCLROOT)/tk/generic
WINTK_LIBS = $(TCLROOT)/tk/win/libtk87.a $(TCLROOT)/tk/win/libtkstub87.a $(TCLROOT)/tcl/win/libtcl90.a $(TCLROOT)/tcl/win/libtclstub90.a $(WINLIBS) $(RESOBJ) -mwindows -pipe -static-libgcc -municode

VPATH=.:spin2cpp/doc

ifdef PANDOC_EXISTS
PDFFILES=spin2cpp/Fastspin.pdf spin2cpp/doc/basic.pdf spin2cpp/doc/c.pdf spin2cpp/doc/spin.pdf
HTMLFILES=spin2cpp/Fastspin.html spin2cpp/doc/basic.html spin2cpp/doc/c.html spin2cpp/doc/spin.html
endif

#
# board support files (e.g. for flash programming)
#
BOARDFILES=board/P2ES_flashloader.bin board/P2ES_flashloader.spin2 board/P2ES_sdcard.bin

# the script used for signing executables:
#    $(SIGN) bin/foo
# produces bin/foo.signed.exe from bin/foo.exe
#
# to just do a regular build, do "make"
# for a signed build, do "make SIGN=my_signing_script"

SIGN ?= ./spin2cpp/sign.dummy.sh

flexgui.zip: flexgui_base $(WIN_BINARIES)
	cp -r flexgui.exe flexgui/
	cp -r $(EXEBINFILES) flexgui/bin
	rm -f flexgui.zip
	zip -r flexgui.zip flexgui

flexgui.exe: src/flexgui.c $(RESOBJ)
	$(WINGCC) $(WINCFLAGS) -o flexgui.exe src/flexgui.c $(WINTK_INC) $(WINTK_LIBS)
	$(SIGN) flexgui
	mv flexgui.signed.exe flexgui.exe

#
# be careful to leave samples/upython/upython.binary during make clean
# Also samples/proplisp/lisp.binary
#

SUBSAMPLES={LED_Matrix}

clean:
	rm -rf flexgui
	rm -rf *.exe *.zip
	rm -rf bin
	rm -rf board
	rm -rf $(BINFILES) $(PDFFILES) $(HTMLFILES)
	rm -rf spin2cpp/build*
	rm -rf proploader-*-build
	rm -rf loadp2/build*
	rm -rf loadp2/board/*.bin
	rm -rf samples/*.elf samples/*.binary samples/*~
	rm -rf samples/*.lst samples/*.pasm samples/*.p2asm
	rm -rf samples/*/*.lst samples/*/*.pasm samples/*/*.p2asm
	rm -rf samples/$(SUBSAMPLES)/*.binary
	rm -rf $(RESOBJ)
	rm -rf pandoc.yml

flexgui_base: src/version.tcl src/makepandoc.tcl $(BOARDFILES) $(PDFFILES) $(HTMLFILES)
	mkdir -p flexgui/bin
	mkdir -p flexgui/doc
	mkdir -p flexgui/board
	cp -r README.md License.txt samples src flexgui
ifdef PANDOC_EXISTS
	cp -r $(PDFFILES) flexgui/doc
	cp -r $(HTMLFILES) flexgui/doc
endif
	cp -r spin2cpp/doc/* flexgui/doc
	cp -r loadp2/README.md flexgui/doc/loadp2.md
	cp -r loadp2/LICENSE flexgui/doc/loadp2.LICENSE.txt
	cp -r spin2cpp/COPYING.LIB flexgui/doc/COPYING.LIB
	cp -r spin2cpp/include flexgui/
	cp -r doc/*.txt flexgui/doc
	cp -r board/* flexgui/board
	cp -r flexgui.tcl flexgui/

.PHONY: flexgui_base

# rules for building PDF files

%.pdf: %.md
	tclsh src/makepandoc.tcl $< > pandoc.yml
	$(PANDOC) --metadata-file=pandoc.yml -s --toc -f gfm -t latex -o $@ $<

# rules for building PDF files

%.html: %.md
	tclsh src/makepandoc.tcl $< > pandoc.yml
	$(PANDOC) --metadata-file=pandoc.yml -s --toc -f gfm -o $@ $<

# rules for native binaries

bin/fastspin: spin2cpp/build/fastspin
	mkdir -p bin
	cp $< $@

bin/proploader: proploader-$(OS)-build/bin/proploader
	mkdir -p bin
	cp $< $@

bin/loadp2: loadp2/build/loadp2
	mkdir -p bin
	cp $< $@

spin2cpp/build/fastspin:
	make -C spin2cpp

proploader-$(OS)-build/bin/proploader: bin/fastspin
	make -C PropLoader OS=$(OS) SPINCMP=$(OPENSPIN)

loadp2/build/loadp2: bin/fastspin
	make -C loadp2 P2ASM="`pwd`/bin/fastspin -2 -I`pwd`/spin2cpp/include"

# rules for Win32 binaries

bin/fastspin.exe: spin2cpp/build-win32/fastspin.exe
	mkdir -p bin
	cp $< $@
	$(SIGN) bin/fastspin
	mv bin/fastspin.signed.exe bin/fastspin.exe

bin/proploader.exe: proploader-msys-build/bin/proploader.exe
	mkdir -p bin
	cp $< $@

bin/loadp2.exe: loadp2/build-win32/loadp2.exe
	mkdir -p bin
	cp $< $@
	$(SIGN) bin/loadp2
	mv bin/loadp2.signed.exe bin/loadp2.exe

spin2cpp/build-win32/fastspin.exe:
	make -C spin2cpp CROSS=win32

proploader-msys-build/bin/proploader.exe:
	make -C PropLoader CROSS=win32

loadp2/build-win32/loadp2.exe:
	make -C loadp2 CROSS=win32

$(RESOBJ): $(RES_RC)
	$(WINRC) -o $@ --define STATIC_BUILD --include "$(TCLROOT)/tk/generic" --include "$(TCLROOT)/tcl/generic" --include "$(RESDIR)" "$<"


## Rules for Mac binaries
bin/mac_terminal.sh: mac_scripts/mac_terminal.sh
	cp $< $@

bin/loadp2.mac: loadp2/build-macosx/loadp2
	mkdir -p bin
	cp $< $@

bin/fastspin.mac: spin2cpp/build-macosx/fastspin
	mkdir -p bin
	cp $< $@

spin2cpp/build-macosx/fastspin:
	make -C spin2cpp CROSS=macosx

loadp2/build-macosx/loadp2:
	make -C loadp2 CROSS=macosx

## Other rules

src/version.tcl: version.inp spin2cpp/version.h
	cpp -xc++ -DTCL_SRC < version.inp > $@

docs: $(PDFFILES) $(HTMLFILES)

docker:
	docker build -t flexguibuilder .

board/P2ES_flashloader.bin: bin/fastspin board/P2ES_flashloader.spin2
	bin/fastspin -2 -o $@ board/P2ES_flashloader.spin2

board/P2ES_sdcard.bin: board/sdcard/sdboot.binary
	mv board/sdcard/sdboot.binary board/P2ES_sdcard.bin

board/sdcard/sdboot.binary: bin/fastspin board/sdcard
	(make -C board/sdcard P2CC="`pwd`/bin/fastspin -2 -I`pwd`/spin2cpp/include")
	rm -f board/sdcard/*.p2asm

board/P2ES_flashloader.spin2: loadp2/board/P2ES_flashloader.spin2
	mkdir -p board
	cp loadp2/board/P2ES_flashloader.spin2 $@

board/sdcard: loadp2/board/sdcard
	mkdir -p board
	cp -r loadp2/board/sdcard board
