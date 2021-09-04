FROM alpine:3.12 AS build

ENV TERRAFORM_VERSION 1.0.5
ENV TERRAFORM_VERSION_SHA256SUM 7ce24478859ab7ca0ba4d8c9c12bb345f52e8efdc42fa3ef9dd30033dbf4b561

RUN apk update && apk add --no-cache \
  wget \
  && wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && apk del wget

RUN echo "${TERRAFORM_VERSION_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > checksum && sha256sum -c checksum
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip


FROM gcr.io/cloud-builders/gcloud

COPY --from=build terraform /usr/bin/terraform
COPY entrypoint.bash /builder/entrypoint.bash
ENTRYPOINT ["/builder/entrypoint.bash"]