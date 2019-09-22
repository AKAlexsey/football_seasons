FROM bitwalker/alpine-elixir:1.8.2 as build
COPY . .

ENV MIX_ENV=prod
ENV DATABASE_URL=ecto://postgres:postgres@localhost/football_seasons_dev
ENV SECRET_KEY_BASE='VTV4aa/E4tW6qqoBOGcrh+ECR4zL+8OMa8U0Y69kb10CAD4VDIdNxCrvEqVjr2zR'

RUN apk update && \
    apk add -u make musl musl-dev musl-utils nodejs-npm build-base

RUN rm -Rf _build && \
    mix deps.get &&\
    mix compile

RUN cd assets && \
    npm install && \
    cd .. && \
    mix phx.digest

RUN mix release

RUN APP_NAME="football_seasons" && \
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
    mkdir /export && \
    tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export

FROM pentacent/alpine-erlang-base:latest
COPY --from=build /export/ .
USER default

ENTRYPOINT ["/opt/app/bin/football_seasons"]
CMD ["foreground"]
