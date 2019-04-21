#lang racket/base
(provide generate-codecov-coverage)
(require
  racket/file
  racket/function
  racket/list
  racket/string
  racket/unit
  json
  net/http-client
  net/uri-codec
  cover/private/file-utils
  setup/getinfo
  racket/match
  racket/contract
  "ci-service.rkt")

(module+ test
  (require rackunit cover racket/runtime-path))

;; ->
;; Submit cover information to Codecov
(define (generate-codecov-coverage coverage files [_dir "coverage"])
  (define json (codecov-json coverage files))
  (define-values (status resp port) (send-codecov! json))
  (displayln status)
  (displayln resp)
  (displayln "Coverage information sent to Codecov."))

(define (codecov-json coverage files)
  (hasheq 'messages (hasheq)
          'coverage (calculate-line-coverage coverage files)))

(define (calculate-line-coverage coverage files)
  (for/hasheq ([file (in-list files)])
    (define local-file (string->symbol (path->string (->relative file))))
    (values local-file (line-coverage coverage file))))

;; Coverage PathString Covered? -> [Listof CoverallsCoverage]
;; Get the line coverage for the file to generate a coverage report
(define (line-coverage coverage file)
  (define covered? (curry coverage file))
  (define split-src (string-split (file->string file) "\n"))
  (define (process-coverage value rst-of-line)
    (case (covered? value)
      ['covered (if (equal? 'uncovered rst-of-line) rst-of-line 'covered)]
      ['uncovered 'uncovered]
      [else rst-of-line]))

  (define-values (line-cover _)
    (for/fold ([coverage `(,(json-null))] [count 1]) ([line (in-list split-src)])
      (cond [(zero? (string-length line)) (values (cons (json-null) coverage) (add1 count))]
            [else (define nw-count (+ count (string-length line) 1))
                  (define all-covered (foldr process-coverage 'irrelevant (range count nw-count)))
                  (values (cons (process-coverage-value all-covered) coverage) nw-count)])))
  (reverse line-cover))

(module+ test
  (define-runtime-path path "tests/test-not-run.rkt")
  (let ()
    (parameterize ([current-cover-environment (make-cover-environment)])
      (define file (path->string (simplify-path path)))
      (test-files! file)
      (check-equal? (line-coverage (get-test-coverage) file) `(,(json-null) 1 0)))))

;; CoverageData -> [Or Number json-null]
;; Converts CoverageData to coverage value recognized by Codecov
(define (process-coverage-value value)
  (case value
    ['covered 1]
    ['uncovered 0]
    [else (json-null)]))

;; Send Codecov data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define services
  (for*/hash ([p (find-relevant-directories '(cover-build-services))]
              [x (in-value ((get-info/full p) 'cover-build-services))]
              #:when (unless (list? x)
                       (error 'cover-codecov
                              "Error loading cover services from ~a, expected a list, got ~a"
                              p
                              x))
              [l (in-list x)])
    
    (match l
      [(list name loc pred unit@)
       (define ?
         (contract (-> any/c)
                   (dynamic-require loc pred)
                   'cover/codecov
                   p))
       (define @
         (contract (unit/c (import) (export ci-service^))
                   (dynamic-require loc unit@)
                   'cover/codecov
                   p))
       (values ? @)]
       
      [e
       (error 'cover-codecov
              "Error loading cover services from ~a, expected four element list, got ~a"
              p
              e)])))

(define CODECOV_HOST "codecov.io")

(define (send-codecov! json)
  (define service (for/first ([(pred unit) services] #:when (pred)) unit))
  (cond [(not service) (error "Failed to find a service.")]
        [else
          (define-values/invoke-unit service (import) (export ci-service^))
          (define raw-params (filter cdr (query)))
          (define params (alist->form-urlencoded raw-params))
          (http-sendrecv CODECOV_HOST
                         (string-append "/upload/v1?" params)
                         #:method "POST"
                         #:ssl? #t
                         #:data (jsexpr->bytes json)
                         #:headers '("Accept: application/json" "Content-Type: application/json"))]))
