#lang setup/infotab

(define name "cover-codecov")
(define collection 'multi)

(define version "0.1.0")

(define deps '(
  ("base" #:version "6.1.1")
  "envy"
  "cover"))

(define build-deps '("rackunit-lib"))
