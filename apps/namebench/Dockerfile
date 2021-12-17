FROM python:2

ENV VERSION 1.3.1

WORKDIR /namebench
RUN curl -LO https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/namebench/namebench-${VERSION}-source.tgz \
  && tar xzf namebench-${VERSION}-source.tgz \
  && rm namebench-${VERSION}-source.tgz \
  && mv namebench-${VERSION}/* . \
  && rm -r namebench-${VERSION}/ \
  && chmod +x namebench.py

ENTRYPOINT ["./namebench.py"]
