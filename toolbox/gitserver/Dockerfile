FROM alpine:latest

RUN apk --no-cache add git git-daemon

WORKDIR /git

EXPOSE 9418

CMD ["git", "daemon", "--verbose", "--export-all", "--base-path=.", "--reuseaddr", "."]