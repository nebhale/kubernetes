FROM golang:1.18.2 as build

WORKDIR /go/src/github.com/nebhale/kubernetes
COPY . /go/src/github.com/nebhale/kubernetes

RUN go get -d -v ./...
RUN go build -o /go/bin/build cmd/build/main.go

FROM paketobuildpacks/run:1.3.50-tiny
COPY --from=build /go/bin/build /
ENTRYPOINT ["/build"]
