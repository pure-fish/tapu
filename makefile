.PHONY: test install clean help

help:
	@echo "tapu - TAP reporter for fish shell"
	@echo ""
	@echo "Available targets:"
	@echo "  test      Run all tests"
	@echo "  install   Install dependencies (fishtape)"
	@echo "  clean     Remove any temporary files"
	@echo "  help      Display this help message"

SHELL := /usr/bin/env fish
test:
	fishtape tests/*.fish

ci: passing-tests failing-tests

passing-tests:
	docker run \
		--rm \
		--volume=$$(pwd):/workspace \
		--workdir=/workspace \
		purefish/docker-fish:4.0.2 \
		fish -c 'fishtape tests/*.test.fish | ./functions/tapu.fish'
		
failing-tests:
	docker run \
		--rm \
		--volume=$$(pwd):/workspace \
		--workdir=/workspace \
		purefish/docker-fish:4.0.2 \
		fish -c 'fishtape tests/*.test-failure.fish | ./functions/tapu.fish'

install:
	fisher install jorgebucaran/fishtape

clean:
	@rm -f *.swp *.swo *~
	@find . -name "*.local.fish" -delete
	@echo "Cleanup complete"
