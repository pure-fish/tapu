# tap.fish

A TAP (Test Anything Protocol) reporter for fish shell, fully written in fish.

This is a fish plugin that can be installed via [fisher](https://github.com/jorgebucaran/fisher).

## Features

- Full compliance with [TAP version 14 specification](https://testanything.org/tap-version-14-specification.html)
- Easy integration with fish shell test suites
- Compatible with [fishtape](https://github.com/jorgebucaran/fishtape) test framework

## Installation

Install with [fisher](https://github.com/jorgebucaran/fisher):

```fish
fisher install pure-fish/tap.fish
```

## Usage

Add usage documentation here.

## Development

### Running Tests

Run the test suite with:

```fish
fishtape tests/*.fish
```

### Test Files

Tests are located in the `tests/` directory and follow the fishtape testing convention.

## License

MIT
