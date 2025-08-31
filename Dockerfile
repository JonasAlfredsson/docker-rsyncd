FROM alpine:3.22
LABEL maintainer="Jonas Alfredsson <jonas.alfredsson@protonmail.com>"

# Make it possible to specify which version of rsync to install. If this is
# omitted the latest available will be used.
# NOTE: You will need to provide the strictness operator as well, like this:
#  - RSYNC_VERSION="=3.4.1-r0"
#  - RSYNC_VERSION=">3.4"
#  - RSYNC_VERSION="~3"
ARG RSYNC_VERSION

RUN apk add --no-cache \
        "rsync${RSYNC_VERSION}" \
    && \
# Create some useful folders.
    mkdir /entrypoint.d && \
    mkdir /etc/rsyncd.d

# Overwrite the default config file with our custom one.
COPY rsyncd.conf /etc/rsyncd.conf

# Include the entrypoint script and set it as such.
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

# Easy to overwrite the verbosity and logging format by just updating the CMD.
# Formatting: https://dev.to/m4r4v/rsync-10-examples-in-11-days-day-11-69
CMD [ "-v", "--log-file-format='%o %h [%a] %m (%u) %f %l'" ]

# This is just the default port used by rsync.
EXPOSE 873
