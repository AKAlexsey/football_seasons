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

# RUN cd assets
# RUN npm install
# RUN cd ..

RUN rm -Rf _build && \
    mix deps.get && \
    mix compile

RUN npm install --prefix ./assets
RUN npm run deploy --prefix ./assets
RUN mix phx.digest

RUN rm -Rf _build

RUN mix release

RUN APP_NAME="football_seasons"
RUN rm -rf /export
RUN mkdir /export
RUN cp -rf ./_build/prod/rel/football_seasons/ ./export


# Release container
FROM elixir:1.13.4-otp-25-alpine
RUN mkdir /opt/app &&\
    mkdir /opt/app/priv &&\
    mkdir /opt/app/priv/protobuf

WORKDIR "/opt/app"

COPY --from=build /export/football_seasons/ .
COPY --from=build /priv/protobuf/game.proto ./priv/protobuf
# not sure if it necessary
RUN chmod +x /opt/app/bin/football_seasons

ENTRYPOINT ["/opt/app/bin/football_seasons"]
CMD ["foreground"]
