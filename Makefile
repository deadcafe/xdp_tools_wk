
# SPDX-License-Identifier: GPL-2.0
# Top level Makefile for xdp-tools

export XDP_TOOLS_TOP_DIR=$(CURDIR)
OUTPUT_DIR=$(XDP_TOOLS_TOP_DIR)/output

ifeq ("$(origin V)", "command line")
VERBOSE = $(V)
endif
ifndef VERBOSE
VERBOSE = 0
endif

ifeq ($(VERBOSE),0)
MAKEFLAGS += --no-print-directory
endif

include version.mk

UTILS := xdp-filter xdp-loader xdp-dump
SUBDIRS := lib $(UTILS)
.PHONY: check_submodule help clobber distclean clean install test libxdp $(SUBDIRS)

all: $(SUBDIRS)

lib: config.mk check_submodule
	@echo; echo $@; $(MAKE) -C $@ OBJDIR=$(OUTPUT_DIR)/$@

libxdp: config.mk check_submodule
	@echo; echo lib; $(MAKE) -C lib $@ OBJDIR=$(OUTPUT_DIR)/lib

libxdp_install: libxdp
	@$(MAKE) -C lib $@ OBJDIR=$(OUTPUT_DIR)/lib

$(UTILS): lib
	@echo; echo $@; $(MAKE) -C $@ OBJDIR=$(OUTPUT_DIR)/$@

help:
	@echo "Make Targets:"
	@echo " all                 - build binaries"
	@echo " clean               - remove products of build"
	@echo " distclean           - remove configuration and build"
	@echo " install             - install binaries on local machine"
	@echo " test                - run test suite"
	@echo " archive             - create tarball of all sources"
	@echo ""
	@echo "Make Arguments:"
	@echo " V=[0|1]             - set build verbosity level"

config.mk: configure
	sh configure --obj_dir=$(OUTPUT_DIR)

check_submodule:
	@if [ -d .git ] && `git submodule status lib/libbpf | grep -q '^+'`; then \
		echo "" ;\
		echo "** WARNING **: git submodule SHA-1 out-of-sync" ;\
		echo " consider running: git submodule update"  ;\
		echo "" ;\
	fi\

clobber:
	touch config.mk
	$(MAKE) clean
	rm -f config.mk cscope.* compile_commands.json

distclean: clobber

clean: check_submodule
	@for i in $(SUBDIRS); \
	do $(MAKE) -C $$i clean OBJDIR=$(OUTPUT_DIR)/$$i ; done

install: all
	@for i in $(SUBDIRS); \
	do $(MAKE) -C $$i install OBJDIR=$(OUTPUT_DIR)/$$i ; done

test: all
	@for i in lib/libxdp $(UTILS); do \
		echo; echo test $$i; $(MAKE) -C $$i test OBJDIR=$(OUTPUT_DIR)/$$i ; \
		if [ $$? -ne 0 ]; then failed="y"; fi; \
	done; \
	if [ ! -z $$failed ]; then exit 1; fi


archive: xdp-tools-$(TOOLS_VERSION).tar.gz

.PHONY: xdp-tools-$(TOOLS_VERSION).tar.gz
xdp-tools-$(TOOLS_VERSION).tar.gz:
	@./mkarchive.sh "$(TOOLS_VERSION)"

compile_commands.json: clean
	compiledb make V=1
