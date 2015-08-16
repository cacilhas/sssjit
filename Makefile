LUAJIT= luajit
SHARE_DIR := $(shell $(LUAJIT) find_lua_path.lua)
MOON= moon
CC= moonc
MD= mkdir -p
DEST= $(SHARE_DIR)/sss
INSTALL= cp -rf
RM= rm -rf

SRC= $(wildcard sss/*.moon)
TARGET= $(SRC:.moon=.lua)


#-------------------------------------------------------------------------------
.PHONY: install uninstall clean test echoserver


all: $(TARGET)


%.lua: %.moon
	$(CC) $<


$(DEST):
	$(MD) $(DEST)


install: $(TARGET) $(DEST)
	$(MD) $(DEST)
	$(INSTALL) $?


uninstall:
	$(RM) $(DEST)


clean:
	$(RM) $(TARGET)


test: tests.moon $(TARGET)
	$(MOON) $<


echoserver: echo.moon $(TARGET)
	$(MOON) $<