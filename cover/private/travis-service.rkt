#lang racket/base
(provide travis-service@ travis-ci?)

(require "ci-service.rkt" racket/unit racket/list racket/string)

(define (travis-ci?) (and (getenv "CI") (getenv "TRAVIS")))

(define-unit travis-service@
  (import)
  (export ci-service^)

  (define (query)
    (define repo-slug (getenv "TRAVIS_REPO_SLUG"))
    (list (cons 'service "travis")
          (cons 'token (getenv "CODECOV_TOKEN"))
          (cons 'branch (getenv "TRAVIS_BRANCH"))
          (cons 'pull_request (getenv "TRAVIS_PULL_REQUEST"))
          (cons 'job (getenv "TRAVIS_JOB_ID"))
          (cons 'slug (getenv "TRAVIS_REPO_SLUG"))
          (cons 'build (getenv "TRAVIS_JOB_NUMBER"))
          (cons 'commit (getenv "TRAVIS_COMMIT")))))
