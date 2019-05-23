FROM golang:1.12 as builder

ENV AWR_VERSION="1.1.0"

WORKDIR /go/src/github.com/FXinnovation/alertmanager-webhook-rocketchat

RUN git clone https://github.com/FXinnovation/alertmanager-webhook-rocketchat.git . &&\
    git checkout ${AWS_VERSION} &&\
    make build

FROM ubuntu:18.04 

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ENV AWR_ENDPOINT_SCHEME="https" \
    AWR_ENDPOINT_HOST="rocketchat.example.com" \
    AWR_CREDENTIALS_NAME="awr" \
    AWR_CREDENTIALS_EMAIL="awr@example.com" \
    AWR_CREDENTIALS_PASSWORD="changeme" \
    AWR_SEVERITY_COLORS_WARNING="#ffa500" \
    AWR_SEVERITY_COLORS_CRITICAL="#ff0000" \
    AWR_CHANNEL_DEFAULT_CHANNEL_NAME="alerts-room" \
    CA_CERTIFICATES_VERSION="20180409" \
    AWR_VERSION="1.1.0" \
    CONFD_VERSION="0.16.0"

COPY --from=builder /go/src/github.com/FXinnovation/alertmanager-webhook-rocketchat/alertmanager-webhook-rocketchat /alertmanager-webhook-rocketchat

ADD ./resources /resources

RUN /resources/build && rm -rf /resources

USER awr

EXPOSE 9876

WORKDIR /opt/awr

ENTRYPOINT [ "/entrypoint" ]

LABEL "maintainer"="cloudsquad@fxinnovation.com" \
      "org.label-schema.name"="alertmanager-webhook-rocketchat" \
      "org.label-schema.base-image.name"="docker.io/library/alpine" \
      "org.label-schema.base-image.version"="3.9" \
      "org.label-schema.description"="alertmanager-webhook-rocketchat in a container" \
      "org.label-schema.url"="https://github.com/FXinnovation/alertmanager-webhook-rocketchat" \
      "org.label-schema.vcs-url"="https://github.com/FXinnovation/alertmanager-webhook-rocketchat" \
      "org.label-schema.vendor"="FXinnovation" \
      "org.label-schema.schema-version"="1.0.0-rc.1" \
      "org.label-schema.applications.alertmanager-webhook-rocketchat.version"="$ALERTMANAGER_WEBHOOK_ROCKETCHAT_VERSION" \
      "org.label-schema.applications.ca-certificates.version"="$CA_CERTIFICATES_VERSION" \
      "org.label-schema.vcs-ref"=$VCS_REF \
      "org.label-schema.version"=$VERSION \
      "org.label-schema.build-date"=$BUILD_DATE \
      "org.label-schema.usage"="Please see README.md"
