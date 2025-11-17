FROM node:24-alpine3.22

RUN apk add --no-cache \
    git \
    nano \
    openssh \
    py3-pip \
    tzdata

ENV USER node
USER ${USER}

# python packages (as zensical) are installed in the user's home directory
# but we need them to be accessible from ${PATH}
ENV PATH="${PATH}:/home/${USER}/.local/bin"
