#lang racket/base

(provide ci-service^)

(require racket/unit racket/contract/base)

(define-signature ci-service^
  ((contracted
    ;; The Service's query string based on the environment
    [query (-> (listof (cons/c symbol? (or/c string? #f))))])))
