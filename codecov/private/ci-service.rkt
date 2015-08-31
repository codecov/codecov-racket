#lang racket/base

(provide ci-service^)
(require racket/unit)


(define-signature ci-service^
  ((contracted
    ;; Return Git Branch that is being tested
    [branch (-> string?)]
    ;; The commit that the code is on
    [commit (-> string?)]
    ;; The Service Job identifier
    [job (-> string?)]
    ;; The codecov token
    [token (-> string?)])))
