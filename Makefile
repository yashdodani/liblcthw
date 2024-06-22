CFLAGS=-g -O2 -Wall -Wextra -Isrc -rdynamic -DNDEBUG $(OPTFLAGS)
# these options are used when linking a library.
LIBS=-ldl $(OPTLIBS)
# optional variable, "make PREFIX=/tmp" can be set manually
PREFIX?=/usr/local

# wildcard search for C files
SOURCES=$(wildcard src/**/*.c src/*.c)
# take C files and make a new list of Object files
OBJECTS=$(patsubst %.c, %.o, $(SOURCES))

# wildcard to find all test files
TEST_SRC=$(wildcard tests/*_tests.c)
# get all test programs (TEST)
TESTS=$(patsubst %.c, %, $(TEST_SRC))

# the target library you are trying to build.
TARGET=build/liblcthw.a
SO_TARGET=$(patsubst %.a, %.so, $(TARGET))

# The target build
all: $(TARGET) $(SO_TARGET) tests

# a dev build
dev: CFLAGS=-g -Wall -Isrc -Wextra $(OPTFLAGS)
dev: all

# "$@ $(OBJECTS)", put the target Makefile source here and all the OBJECTS after that.
# $@ maps to $(TARGET)
$(TARGET): CFLAGS += -fPIC
$(TARGET): build $(OBJECTS)
	ar rcs $@ $(OBJECTS)
	ranlib $@
$(SO_TARGET): $(TARGET) $(OBJECTS)
	$(CC) -shared -o $@ $(OBJECTS) -Wl,-rpath=build

build:
	@mkdir -p build
	@mkdir -p bin

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# the unit tests
# make will ignore this
.PHONY: tests

# test programs linked with the TARGET library.
tests: export LD_LIBRARY_PATH=build
tests: CFLAGS += -Lbuild -llcthw

# Make, use what you know about building programs and current CFLAGS settings to build each program in TESTS.
tests: $(TESTS)
	sh ./tests/runtests.sh 

# the cleaner
clean: 
	rm -rf build $(OBJECTS) $(TESTS)
	rm -f tests/tests.log
	find . -name "*.gc" -exec rm {} \;
	rm -rf `find . -name "*.dSYM" -print`

# the install
# DESTDIR handed to make by installers
# done as sudo, "make && sudo make install"
install: all
	install -d $(DESTDIR)/$(PREFIX)/lib/
	install $(TARGET) $(DESTDIR)/$(PREFIX)/lib/

# the checker
check:
	@echo Files with potentially dangerous functions.
	@egrep '[^_.>a-zA-ZO-9] (str(n?cpy|n?cat|xfrm|n?dup|str|pbrk|tok|_)\
		|stpn?cpy|a?sn?printf|byte_)' $(SOURCES) || 