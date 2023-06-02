
LIBBPF_CFLAGS:=$(if $(CFLAGS),$(CFLAGS),-g -O2 -Werror -Wall) -fPIC

LIB_DIR = .
include defines.mk

SUBDIRS=util testing
.PHONY: $(SUBDIRS)

all: $(SUBDIRS) libxdp

util: libxdp
	@echo; echo "  xxx-1 $@"; $(MAKE) -C $@ OBJDIR=$(OBJDIR)/$@

testing: libxdp util
	@echo; echo "  xxx-2 $@"; $(MAKE) -C $@ OBJDIR=$(OBJDIR)/$@

.PHONY: libxdp
libxdp: $(OBJECT_LIBBPF)
	@echo; echo "  xxx-3 $@"; $(MAKE) -C $@ OBJDIR=$(OBJDIR)/$@

.PHONY: clean
clean: libbpf_clean
	@for i in $(SUBDIRS) libxdp; \
	do $(MAKE) -C $$i clean OBJDIR=$(OBJDIR)/$$i ; done

.PHONY: install
install: libxdp_install
	$(MAKE) -C testing install OBJDIR=$(OBJDIR)/testing

.PHONY: libxdp_install
libxdp_install: libxdp
	install -m 0755 -d $(DESTDIR)$(HDRDIR)
	$(MAKE) -C libxdp install OBJDIR=$(OBJDIR)/libxdp

libbpf: $(OBJECT_LIBBPF)

# Handle libbpf as git submodule
ifeq ($(SYSTEM_LIBBPF),n)
ifeq ($(VERBOSE),0)
P:= >/dev/null
endif

# Detect submodule libbpf source file changes
LIBBPF_SOURCES := $(wildcard libbpf/src/*.[ch])

.PHONY: libbpf_clean
libbpf/src/libbpf.a: $(LIBBPF_SOURCES)
	@echo ; echo "  libbpf"
	$(QUIET_CC)$(MAKE) -C libbpf/src CFLAGS="$(LIBBPF_CFLAGS)" $P OBJDIR=$(OBJDIR)/libbpf
	$(QUIET_INSTALL)$(MAKE) -C libbpf/src install_headers DESTDIR=root $P OBJDIR=$(OBJDIR)/libbpf

libbpf_clean:
	$(Q)$(MAKE) -C libbpf/src clean $P OBJDIR=$(OBJDIR)/libbpf

else

libbpf_clean:
	@echo -n
endif
