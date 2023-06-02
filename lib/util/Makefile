include util.mk

LIB_DIR ?= ..
OBJDIR ?= .

include $(LIB_DIR)/defines.mk
include $(LIBXDP_DIR)/libxdp.mk

all: $(OBJDIR) $(UTIL_OBJS)

# Create expansions for dependencies
UTIL_H := ${UTIL_OBJS:.o=.h}

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJDIR)/%.o: %.h %.c $(LIBMK)
	$(QUIET_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -Wall -I../../headers -c $< -o $@

clean:
	$(Q)rm -f $(UTIL_OBJS)
