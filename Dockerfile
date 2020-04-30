FROM adoptopenjdk/openjdk11:x86_64-centos-jdk11u-nightly-slim as build
WORKDIR /app
RUN yum -y --setopt=tsflags=nodocs update && yum install -y  curl maven git wget  && curl -sL https://rpm.nodesource.com/setup_12.x | bash - && yum install -y nodejs && npm install -g lerna  yarn
RUN echo "clone code" &&  git clone https://github.com/dbeaver/cloudbeaver.git  /app/cloudbeaver
COPY build.sh /app/cloudbeaver/deploy/build.sh
RUN ls -sailh && cd /app/cloudbeaver/deploy && ./build.sh

FROM  openjdk:11-stretch 
LABEL EMAIL="1141591465@qq.com"
LABEL AUTHOR="dalongrong"
ENV VERSION=1.0
WORKDIR /app
COPY --from=build /app/cloudbeaver/deploy/cloudbeaver  /app
COPY run-server.sh /app/run-server.sh
EXPOSE 8978
CMD ["sh","/app/run-server.sh"]