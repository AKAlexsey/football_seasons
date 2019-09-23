FROM qixxit/elixir-centos as build
COPY . .

ENV MIX_ENV=prod

RUN yum install -y gcc-c++ make epel-release
RUN yum install nodejs
RUN npm install yarn -g

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

FROM qixxit/elixir-centos
RUN mkdir /opt/app &&\
    mkdir /opt/app/priv &&\
    mkdir /opt/app/priv/protobuf

WORKDIR "/opt/app"

COPY --from=build /export/ .
COPY --from=build /priv/protobuf/game.proto ./priv/protobuf

ENTRYPOINT ["/opt/app/bin/football_seasons"]
CMD ["foreground"]
