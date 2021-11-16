FROM golang AS build

COPY ./coredns /coredns
COPY ./plugins/dcache /usr/local/go/src/dcache
COPY Corefile /coredns/Corefile

RUN sed -i '1s/^/dcache:dcache\n/' /coredns/plugin.cfg

WORKDIR /coredns

RUN make

FROM gcr.io/distroless/static

COPY --from=build /coredns/coredns /coredns
COPY Corefile /

EXPOSE 53/udp 53

CMD ["/coredns"]

