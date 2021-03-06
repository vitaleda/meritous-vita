TARGET		:= meritous
TITLE	    := MERITOUS1
SOURCES		:= src
			
INCLUDES	:= src

LIBS = -lSDL_mixer -lSDL_image -lmikmod -lvorbisfile -lvorbis -logg -lsndfile -lSceLibKernel_stub -lScePvf_stub \
	-lSceAppMgr_stub -lSceCtrl_stub -lSceTouch_stub -lm -lSceAppUtil_stub -lScePgf_stub -ljpeg \
	-lfreetype -lc -lScePower_stub -lSceCommonDialog_stub -lpng16 -lz -lSceAudio_stub -lSceGxm_stub \
	-lSceDisplay_stub -lSceSysmodule_stub -lSDL -lvitaGL -lSceHid_stub -limgui

CFILES   := $(foreach dir,$(SOURCES), $(wildcard $(dir)/*.c))
CPPFILES   := $(foreach dir,$(SOURCES), $(wildcard $(dir)/*.cpp))
BINFILES := $(foreach dir,$(DATA), $(wildcard $(dir)/*.bin))
OBJS     := $(addsuffix .o,$(BINFILES)) $(CFILES:.c=.o) $(CPPFILES:.cpp=.o) 

export INCLUDE	:= $(foreach dir,$(INCLUDES),-I$(CURDIR)/$(dir))

PREFIX  = arm-vita-eabi
CC      = $(PREFIX)-gcc
CXX      = $(PREFIX)-g++
CFLAGS  = $(INCLUDE) -g -Wl,-q -O3
CXXFLAGS  = $(CFLAGS) -fno-exceptions -std=gnu++11 -fpermissive
ASFLAGS = $(CFLAGS)

all: $(TARGET).vpk

$(TARGET).vpk: $(TARGET).velf
	vita-make-fself -s $< build/eboot.bin
	vita-mksfoex -s TITLE_ID=$(TITLE) "$(TARGET)" param.sfo
	cp -f param.sfo build/sce_sys/param.sfo
	
	#------------ Comment this if you don't have 7zip ------------------
	7z a -tzip ./$(TARGET).vpk -r ./build/sce_sys ./build/eboot.bin
	#-------------------------------------------------------------------

%.velf: %.elf
	cp $< $<.unstripped.elf
	$(PREFIX)-strip -g $<
	vita-elf-create $< $@

$(TARGET).elf: $(OBJS)
	$(CXX) $(CXXFLAGS) $^ $(LIBS) -o $@

clean:
	@rm -rf $(TARGET).velf $(TARGET).elf $(OBJS)
