FROM golang AS build

ENV CGO_ENABLED=0

COPY ./ /scrape

WORKDIR /scrape

RUN go build -ldflags '-extldflags=-static' -o app

FROM zenika/alpine-chrome

COPY --from=build /scrape/app /app/bin
COPY top1000jp.json /app/top1000jp.json
RUN ls -la /app

ENTRYPOINT []
CMD ["/app/bin", "/app/top1000jp.json"]

