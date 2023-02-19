FROM elixir:1.13.4-otp-25-alpine as build
COPY . .

ENV MIX_ENV=prod
ENV ADMIN_PORT=4000
ENV API_PORT=4001

RUN apk update \
 && apk upgrade --no-cache
RUN apk add  --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/ nodejs=16.19.1-r0 npm 
RUN apk add --no-cache make

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix phx.digest

# RUN cd assets
# RUN npm install
# RUN cd ..

RUN rm -Rf _build && \
    mix deps.get && \
    mix compile

RUN mix release

RUN APP_NAME="football_seasons"
RUN RELEASE_DIR=`ls -d _build/prod/rel/`
RUN mkdir /export
RUN cp -rf ./_build/prod/rel/ ./export


FROM node:16.14.2-alpine as assets_builder

ARG app

WORKDIR /app

RUN apk add bash

COPY --from=build /app ./
COPY deploy/build_assets.sh ./

RUN ./build_assets.sh

FROM elixir:1.13.4-otp-25-alpine
RUN mkdir /opt/app &&\
    mkdir /opt/app/priv &&\
    mkdir /opt/app/priv/protobuf

WORKDIR "/opt/app"

COPY --from=build /export/ .
COPY --from=build /priv/protobuf/game.proto ./priv/protobuf

ENTRYPOINT ["/opt/app/bin/football_seasons"]
CMD ["foreground"]
