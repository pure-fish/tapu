.PHONY: test install clean help

help:
	@echo "tap.fish - TAP reporter for fish shell"
	@echo ""
	@echo "Available targets:"
	@echo "  test      Run all tests"
	@echo "  install   Install dependencies (fishtape)"
	@echo "  clean     Remove any temporary files"
	@echo "  help      Display this help message"

SHELL := /usr/bin/env fish
test:
	fishtape tests/*.fish

install:
	fisher install jorgebucaran/fishtape

clean:
	@rm -f *.swp *.swo *~
	@find . -name "*.local.fish" -delete
	@echo "Cleanup complete"
