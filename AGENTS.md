# AGENTS.md

* work in English

## Dev environment tips

* use `fish` as your default shell for development and testing ;
* when working with `fish` projects,
  * use `fisher` to manage fish plugins ;
  * use `fishtape` as test runner.
  * When tests pass, run them again in `purefish/docker-fish` container to ensure compatibility ;

## Setup commands

* use `make` tasks to dev on the project, so local and CI environments are similar ;
* use `docker` container to isolate from host environment and have consistent testing environment ;

## Code style

* follow KISS principles ;
* Avoid external dependencies where possible
* use commit conventions to generate changelogs and releases
* write tests for new features and bug fixes
* use [clean code principles](https://gist.github.com/wojteklu/73c6914cc446146b8b533c0988cf8d29#file-clean_code-md)
