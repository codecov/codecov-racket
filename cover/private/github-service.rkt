#lang racket/base
(provide github-service@ github-ci?)

(require "ci-service.rkt" racket/unit racket/list racket/string)

(define (github-ci?) (and (getenv "GITHUB_REPOSITORY") (getenv "CODECOV_TOKEN")))

(define-unit github-service@
  (import)
  (export ci-service^)

  (define (query)
    (define repo-slug (getenv "GITHUB_REPOSITORY"))
    (list (cons 'service "custom")
          (cons 'token (getenv "CODECOV_TOKEN"))
          ;; TODO: this won't work for tags
          (cons 'branch (substring (getenv "GITHUB_REF") (string-length "refs/heads/")))
          (cons 'job (getenv "GITHUB_JOB"))
          (cons 'slug (getenv "GITHUB_REPOSITORY"))
          (cons 'build (getenv "GITHUB_RUN_ID"))
          (cons 'commit (getenv "GITHUB_SHA")))))
