FROM golang AS build

COPY ./coredns /coredns
COPY ./plugins/dcache /usr/local/go/src/dcache
COPY Corefile /coredns/Corefile

RUN echo "dcache:dcache" >> /coredns/plugin.cfg

WORKDIR /coredns

RUN make

FROM gcr.io/distroless/static

COPY --from=build /coredns/coredns /coredns
COPY Corefile /

CMD ["/coredns"]

