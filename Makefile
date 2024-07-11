PROJECT = binkli

DEPS = cowboy
dep_cowboy = git https://github.com/ninenines/cowboy 2.11.0

include erlang.mk
include extra.mk
