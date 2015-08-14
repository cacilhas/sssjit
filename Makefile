LUAJIT= luajit
SHARE_DIR := $(shell $(LUAJIT) find_lua_path.lua)
LUA := LUA_PATH="./?.lua;$$LUA_PATH" $(LUAJIT)
CC= moonc
MD= mkdir -p
DEST= $(SHARE_DIR)/
INSTALL= cp -rf
RM= rm -rf

SRC= sss.moon
TARGET= $(SRC:.moon=.lua)

#-------------------------------------------------------------------------------
all: $(TARGET)


.PHONY: install uninstall clean


%.lua: %.moon
	$(CC) $<


$(DEST):
	$(MD) $(DEST)


install: $(TARGET) $(DEST)
	$(INSTALL) $?


uninstall:
	$(RM) $(DEST)


clean:
	$(RM) $(TARGET) $(TESTS)
