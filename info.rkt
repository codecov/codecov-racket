#lang setup/infotab

(define name "cover-codecov")
(define collection 'multi)

(define version "0.2.0")

(define deps '(
  ("base" #:version "6.1.1")
  "cover"))

(define build-deps '("rackunit-lib"))
