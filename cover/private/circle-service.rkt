#lang racket/base

;; CODECOV_TOKEN - project identifier
;; CODECOV_ACCESS_TOKEN - for private repositories
;; CODECOV_UPLOAD_NAME - for giving a coverage report a custom name
;; CODECOV_COVERAGE_FLAGS - for coverage flags, see codecov docs at
;;   https://docs.codecov.io/v4.3.6/docs/flags

(provide circle-service@ circle-ci?)

(require "ci-service.rkt" racket/unit racket/list racket/string)

(define (circle-ci?) (and (getenv "CI") (getenv "CIRCLECI")))

(define-unit circle-service@
  (import)
  (export ci-service^)

  (define (query)
    ;; codecov query param docs: https://docs.codecov.io/v4.3.6/reference#upload
    ;; circleci env docs: https://circleci.com/docs/2.0/env-vars/#circleci-built-in-environment-variables
    (list (cons 'commit (getenv/log-when-missing "CIRCLE_SHA1"))
          (cons 'token (getenv/log-when-missing "CODECOV_TOKEN"))
          (cons 'access_token (getenv "CODECOV_ACCESS_TOKEN"))
          (cons 'branch (getenv/log-when-missing "CIRCLE_BRANCH"))
          (cons 'build (getenv/log-when-missing "CIRCLE_BUILD_NUM"))
          (cons 'job (getenv/log-when-missing "CIRCLE_NODE_INDEX"))
          (cons 'build_url (getenv/log-when-missing "CIRCLE_BUILD_URL"))
          (cons 'name (getenv "CODECOV_UPLOAD_NAME"))
          (cons 'slug (get-circle-slug-env))
          (cons 'service "circleci")
          (cons 'flags (getenv "CODECOV_COVERAGE_FLAGS"))
          (cons 'pr (getenv "CIRCLE_PR_NUMBER")))))

(define (get-circle-slug-env)
  (define user-part (getenv/log-when-missing "CIRCLE_PROJECT_USERNAME"))
  (define repo-part (getenv/log-when-missing "CIRCLE_PROJECT_REPONAME"))
  (and user-part repo-part (format "~a/~a" user-part repo-part)))

;; logger name chosen to identify the source collection module
(define-logger cover/private/circle-service)

(define (getenv/log-when-missing env)
  (define env-value (getenv env))
  (unless env-value
    (log-cover/private/circle-service-warning
     "unexpectedly missing environment variable: ~a" env))
  env-value)
