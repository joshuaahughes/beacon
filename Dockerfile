FROM ubuntu:20.04 as build-env

RUN apt-get update && \
       apt-get install -y --no-install-recommends apt-utils && \
       apt-get -y install sudo


## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

## preesed tzdata, update package index, upgrade packages and install needed software
RUN echo "tzdata tzdata/Areas select US" > /tmp/preseed.txt; \
    echo "tzdata tzdata/Zones/US select Colorado" >> /tmp/preseed.txt; \
    debconf-set-selections /tmp/preseed.txt && \
    apt-get update && \
    apt-get install tzdata -y && \
    apt-get upgrade -y && \
    apt-get install curl git wget psmisc unzip libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 python3 nginx nano vim -y

RUN apt-get clean

RUN apt-get install -y curl git wget unzip libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 python3 nginx nano vim

RUN apt-get clean
ARG CACHEBUST=1
# Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/
RUN cd /app/

# Configure nginx and remove secret files
RUN mv /app/build/web/ /var/www/html/meshager
RUN cd /etc/nginx/sites-enabled
RUN cp -f /app/default /etc/nginx/sites-enabled/default

# Record the exposed port

FROM scratch
COPY --from=build-env / /

EXPOSE 5000 

# Start the python server
RUN ["chmod", "+x", "/app/server/server.sh"]
ENTRYPOINT [ "/app/server/server.sh"]