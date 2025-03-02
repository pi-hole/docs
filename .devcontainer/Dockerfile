FROM node:22-alpine

RUN apk add --no-cache \
    git \
    nano \
    openssh \
    py3-pip

ENV USER node
USER ${USER}

# python packages (as mkdocs) are installed in the user's home directory
# but we need them to be accessible from ${PATH}
ENV PATH="${PATH}:/home/${USER}/.local/bin"
