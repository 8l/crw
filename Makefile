SRC_FILES = $(wildcard src/*.d)

all:
	dmd ${SRC_FILES}