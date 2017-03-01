#lang racket/base
(provide gitlab-service@ gitlab-ci?)

(require "ci-service.rkt" racket/unit racket/list racket/string)

(define (gitlab-ci?) (and (getenv "CI") (getenv "GITLAB_CI")))

(define-unit gitlab-service@
  (import)
  (export ci-service^)

  (define (query)
    (define project-url (getenv "CI_PROJECT_URL"))
    (define branch (getenv "CI_BUILD_REF_NAME"))
    (list (cons 'service "gitlab")
          (cons 'token (getenv "CODECOV_TOKEN"))
          (cons 'branch branch)
          (cons 'job (getenv "CI_PIPELINE_ID"))
          (cons 'slug (getenv "CI_PROJECT_PATH"))
          (cons 'tag (getenv "CI_BUILD_TAG"))
          (cons 'build (getenv "CI_BUILD_ID"))
          (cons 'build_url (and project-url branch (format "~a/tree/~a" project-url branch)))
          (cons 'commit (getenv "CI_BUILD_REF")))))
