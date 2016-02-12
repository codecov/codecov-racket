# Cover Codecov

[![Build Status](https://travis-ci.org/rpless/cover-codecov.svg?branch=master)](https://travis-ci.org/rpless/cover-codecov)
[![codecov.io](https://codecov.io/github/rpless/cover-codecov/coverage.svg?branch=master)](https://codecov.io/github/rpless/cover-codecov?branch=master)

Adds [Codecov](https://codecov.io/) support to [Cover](https://github.com/florence/cover).

_Note_: [Travis CI](https://travis-ci.org/) is currently the only supported method of posting data to [Codecov](https://codecov.io/).

## Use with TravisCI
First enable your repository on Travis and Codecov.
Next add `cover-codecov` to the `build-deps` of your `info.rkt`.
Then create a `.travis.yml` in the root of your repository.

```yml
# .travis.yml
langauge: c
sudo: false
env:
  global:
    - RACKET_DIR=~/racket
  matrix:
    - RACKET_VERSION=6.2 # Set this to the version of racket you use

before_install: # Install Racket
  - git clone https://github.com/greghendershott/travis-racket.git ../travis-racket
  - cat ../travis-racket/install-racket.sh | bash
  - export PATH="${RACKET_DIR}/bin:${PATH}"

install: raco pkg install --deps search-auto $TRAVIS_BUILD_DIR # install dependencies

script:
  - raco test $TRAVIS_BUILD_DIR # run tests. you wrote tests, right?

after_success:
  - raco cover -f codecov -d $TRAVIS_BUILD_DIR/coverage . # generate coverage information for coveralls
```
The above Travis configuration will install any project dependencies, test your project, and report coverage information to Codecov.

For additional Travis configuration information look at [Travis Racket](https://github.com/greghendershott/travis-racket).
