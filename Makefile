METALINTER_CONCURRENCY ?= 10

BASEDIR := $(shell echo $${PWD})

setup:
	go get -v -u github.com/alecthomas/gometalinter
	gometalinter --install --update

build: *.go fmt
	go build .

fmt:
	gofmt -w=true -s $$(find . -type f -name '*.go' -not -path "./vendor/*")
	goimports -w=true -d $$(find . -type f -name '*.go' -not -path "./vendor/*")

test:
	go test $$(glide nv)

test-race:
	go test -race $$(glide nv)

cover:
	./cover.sh
	go tool cover -func=coverage.out
	go tool cover -html=coverage.out

coveralls:
	./cover.sh
	goveralls -coverprofile=coverage.out -service=travis-ci

junit-test: build
	go test -v $$(glide nv) | go-junit-report > test-report.xml

check:
	go install
	go install ./examples/...
	gometalinter --concurrency=$(METALINTER_CONCURRENCY) --deadline=180s ./... --vendor --linter='errcheck:errcheck:-ignore=net:Close' --cyclo-over=25 \
		--linter='vet:go tool vet -composites=false {paths}:PATH:LINE:MESSAGE' --disable=interfacer --dupl-threshold=65 --exclude=helloworld.pb.go

watch:
	CompileDaemon -color=true -build "make test"

protobuf:
	@docker run --rm -v $(BASEDIR):/app -v $(GOPATH):/go -w /app znly/protoc --go_out=plugins=grpc:examples/grpc/helloworld -I examples/grpc/helloworld examples/grpc/helloworld/*.proto
