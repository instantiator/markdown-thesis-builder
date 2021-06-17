FROM pandoc/latex

RUN apk update && apk upgrade
RUN apk add bash
RUN apk add poppler-utils

COPY scripts/build.sh /build.sh

ENTRYPOINT [ "/build.sh" ]
