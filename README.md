# Cover Codecov

[![Build Status](https://travis-ci.org/codecov/codecov-racket.svg?branch=master)](https://travis-ci.org/codecov/codecov-racket)
[![codecov.io](https://codecov.io/github/codecov/codecov-racket/coverage.svg?branch=master)](https://codecov.io/github/codecov/codecov-racket?branch=master)

Adds [Codecov](https://codecov.io/) support to [Cover](https://github.com/florence/cover).

_Note_:  The currently supported methods of posting data to [Codecov](https://codecov.io/) are [Travis CI](https://travis-ci.org/), [Gitlab CI](https://about.gitlab.com/gitlab-ci/),
and [Circle CI](https://circleci.com/).

## Use with Travis CI
First enable your repository on Travis and Codecov.
Next add `cover-codecov` to the `build-deps` of your `info.rkt`.
Then create a `.travis.yml` in the root of your repository.

```yml
# .travis.yml
language: c
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
  - raco pkg install --deps search-auto cover cover-codecov
  - raco cover -f codecov -d $TRAVIS_BUILD_DIR/coverage . # generate coverage information for coveralls
```
The above Travis configuration will install any project dependencies, test your project, and report coverage information to Codecov.

For additional Travis configuration information look at [Travis Racket](https://github.com/greghendershott/travis-racket).

## Use with Gitlab-CI
Like with Travis, except that you should use the Gitlab format
of the CI configuration file:

```yml
image: frolvlad/alpine-glibc

variables:
  RACKET_DIR: "$HOME/racket"
  RACKET_VERSION: "6.8" # use the desired version of racket

before_script:
  - echo "ipv6" >> /etc/modules
  - apk update
  - apk add git curl bash openssl sqlite-libs
  - git clone https://github.com/greghendershott/travis-racket.git ~/ci-racket
  - cat ~/ci-racket/install-racket.sh | bash # pipe to bash not sh!
  - export PATH="$RACKET_DIR/bin:$PATH" #install-racket.sh can't set for us
  - raco pkg install --auto $CI_PROJECT_DIR

stages:
  - test
  - cover

test:
  stage: test
  script:
    - raco test $CI_PROJECT_DIR

cover:
  stage: cover
  script:
    - raco pkg install --auto cover cover-codecov
    - raco cover -f codecov $CI_PROJECT_DIR
```

## Use with CircleCI

*added in version 0.2.0*

CircleCI is (mostly) based on Docker, so you'll have to choose a Docker image to
use as your base Racket installation. Then in your `.circleci/config.yml`
configuration run the same cover commands as the Travis and Gitlab examples:

```yml
version: 2
jobs:
  build:
    docker:
      - image: jackfirth/racket:6.12 # or build your own image
    steps:
      - checkout
      - run:
          name: Install
          # install working directory (which is the repo root) as a package
          command: raco pkg install --auto --link --name my-package
      - run:
          name: Test
          command: raco test -p my-package
      - run:
          name: Install Cover
          command: raco pkg install --auto cover cover-codecov
      - run:
          name: Cover
          command: raco cover -f codecov -p my-package
          environment:
            COVER_TOKEN: ... # your codecov project UUID token
            COVER_ACCESS_TOKEN: ... # API token, only needed for private repos
```
