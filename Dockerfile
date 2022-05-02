# syntax=docker/dockerfile:1
FROM golang:1.18
WORKDIR /build
COPY main.go go.mod go.sum ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o go-hello-http .

FROM alpine:latest  
RUN apk --no-cache add ca-certificates tzdata
RUN mkdir /app
WORKDIR /app
COPY --from=0 /build/go-hello-http ./
COPY config.yaml ./
CMD ["/app/go-hello-http","config.yaml"]
