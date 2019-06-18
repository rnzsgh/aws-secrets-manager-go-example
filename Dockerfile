FROM golang:1.11.11 as builder

ENV GO111MODULE on

RUN mkdir -p /build
WORKDIR /build
RUN useradd -u 10001 app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o aws-secrets-manager-env main.go

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o test test.go

RUN chmod ugo+x execute.sh

FROM alpine
RUN apk update && apk add bash

COPY --from=builder /build/aws-secrets-manager-env /aws-secrets-manager-env
COPY --from=builder /build/test /test
COPY --from=builder /build/execute.sh /execute.sh
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
USER app

CMD [ "/execute.sh" ]
