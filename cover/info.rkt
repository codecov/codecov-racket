#lang setup/infotab

(define cover-formats '(("codecov" cover/codecov generate-codecov-coverage)))
(define cover-build-services '(("gitlab-service" cover/private/gitlab-service
                                                 gitlab-service?
                                                 gitlab-service@)
                               ("travis-service" cover/private/travis-service
                                                 travis-service?
                                                 travis-service@)))