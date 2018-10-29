CC=go
RM=rm
MV=mv


SOURCEDIR=.
SOURCES := $(shell find $(SOURCEDIR) -name '*.go')
GOOS=linux
GOARCH=amd64

VERSION:=1.0.0
PREVIOUS_VERSION=$(shell echo $$((${VERSION} - 1)))
APP=sql-tx

BUILD_TIME=`date +%FT%T%z`
PACKAGES := 

LIBS=

LDFLAGS=-ldflags  

.DEFAULT_GOAL:=test

help:
		@echo ""
		@echo "***********************************************************"
		@echo "******** makefile's help, possible actions: ***************"
		@echo "*** test : execute test on the project"
		@echo "*** package : package the application"
		@echo "*** coverage-display : execute tests and display code coverage in your navigator"
		@echo "*** coverage : execute test and gets the code coverage on the project"
		@echo "*** fmt : execute go fmt on the project"
		@echo "*** audit : execute static audit on source code."
		@echo "*** deps : get the dependencies of the project"
		@echo "*** init : initialise the project"
		@echo "*** clean : clean binaries and project structure"
		@echo ""


package: ${APP}
		@tar -cvzf ${APP}-${GOOS}-${GOARCH}-${VERSION}.tar.gz ${APP}-${VERSION} dbconfig.json appconfig.json InterfaceContract_${APP}-${VERSION}.json
		@echo "    Archive ${APP}-${GOOS}-${GOARCH}-${VERSION}.tar.gz created"

test: $(APP) 
		@GOOS=${GOOS} GOARCH=${GOARCH} go test -cover ./...
		@echo " Tests OK."

coverage-display:
		$(shell ls -d */ | while read d; do d_=`echo $$d | tr -d '/'`;go test -coverprofile=$$d_.out gitlab.axione.fr/axione/netdesigner-lib/$$d_; go tool cover -html=$$d_.out; done 1>/dev/null)
		@echo " Tests executed and results will be displayed in your navigator."

coverage: 
		@go get github.com/axw/gocov/gocov
		@gocov test ./... | gocov report

$(APP): fmt $(SOURCES)
		@echo "    Compilation des sources ${BUILD_TIME}"
		@echo ""
		@GOOS=${GOOS} GOARCH=${GOARCH} go build ${LDFLAGS} -o ${APP}-${VERSION} $(SOURCEDIR)/main.go
		@echo "    ${APP}-${VERSION} generated."

build: 
		@echo "    Compilation des sources ${BUILD_TIME}"
		@echo ""
		@GOOS=${GOOS} GOARCH=${GOARCH} go build ${LDFLAGS} -o ${APP}-${VERSION} $(SOURCEDIR)/main.go
		@echo "    ${APP}-${VERSION} generated."

fmt: audit
		@echo "    Go FMT"
		@$(foreach element,$(SOURCES),go fmt $(element);)

audit: deps
		@go tool vet -all . 2> audit.log &
		@echo "    Audit effectue"

deps: init
		@echo "    Download packages"		
		dep ensure -update -v
		#@$(foreach element,$(PACKAGES),go get -d -u -v -insecure $(element);)

init: clean
		@echo "    Init of the project"
		@echo "    Version :: ${VERSION}"

clean:
		@if [ -f "${APP}-${VERSION}" ] ; then rm ${APP}-${VERSION} ; fi
		@if [ -f "${APP}-linux-amd64-${VERSION}.tar.gz" ] ; then rm ${APP}-linux-amd64-${VERSION}.tar.gz ; fi
		@rm -f *.out
		@echo "    Nettoyage effectuee"

execute: 
		@./${APP}-${VERSION}

package-zip:  ${APP}
		@zip -r ${APP}-${GOOS}-${GOARCH}-${VERSION}.zip ./${APP}-${VERSION}
		@echo "    Archive ${APP}-${GOOS}-${GOARCH}-${VERSION}.zip created"
