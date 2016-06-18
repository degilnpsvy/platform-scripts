ifndef VERBOSE
  ifeq ("$(origin V)","command line")
    ifneq ($(V),)
      VERBOSE:=$(V)
    endif
  endif
endif

ifeq ($(subst s,2,$(VERBOSE)),2)
  quiet =
  Q =
else
  quiet=quiet_
  Q = @
endif

ifneq ($(VERBOSE),)
  define EXEC
    $(1) || exit $$?
  endef
  VERBOSE=$(subst 2,1,$(subst 1,0,$(V)))
else
  define EXEC
    $(1) > /dev/null || exit $$?
  endef
endif

QEMU_VERBOSE=
ifeq ($(VERBOSE),2)
  QEMU_VERBOSE=1
endif

export Q quiet VERBOSE QEMU_VERBOSE
