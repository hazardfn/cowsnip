.PHONY: all test eunit check ct compile sh clean

REBAR=./rebar3

all: compile test

test: check unit ct

run:
	./_build/default/rel/erws/bin/erws console

compile:
	$(REBAR) compile

rel:
	$(REBAR) release

ct:
	$(REBAR) ct --config .ct_spec -c true

unit:
	$(REBAR) eunit -c true

check:
	$(REBAR) dialyzer

sh:
	$(REBAR) shell

clean:
	$(REBAR) clean
