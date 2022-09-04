FROM docker:20.10.17-dind
RUN printenv
RUN apk update && apk add --no-cache nodejs npm
RUN npm install -g serverless@3.22.0
RUN mkdir /opt/sls
WORKDIR /opt/sls
COPY sls .
RUN npm install