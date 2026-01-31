PROJECT = binkli
PROJECT_DESCRIPTION = binkli
PROJECT_VERSION = 3.0

DEPS = cowboy
REL_DEPS += relx

dep_cowboy = git https://github.com/ninenines/cowboy 2.14.2

include erlang.mk
include extra.mk

