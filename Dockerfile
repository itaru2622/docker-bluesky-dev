# golang@1.26 for social-app, indigo, and others.
ARG base=golang:1.26-trixie
FROM ${base}

# pnpm@11 + nodejs@24 for social-app, atproto, and others.
ARG pnpm_ver=11
ARG node_ver=24
RUN curl -fsSL https://deb.nodesource.com/setup_${node_ver}.x | sh -; \
    apt install -y nodejs; \
    npm install -g pnpm@${pnpm_ver};

# semgrep for social-app rebranding test
RUN apt install -y python3-pip jq; \
    pip install semgrep --break-system-packages;

# add an account in container to keep uid/gid with docker host.
ARG gid=1000
ARG uid=1000
ARG uname=user
RUN addgroup --system  --gid ${gid} ${uname}; \
    adduser  --system --gid ${gid} --uid ${uid} --shell /bin/bash --home /home/${uname} ${uname} ; \
    echo "${uname}:${uname}" | chpasswd; \
    (cd /etc/skel; find . -type f -print | tar cf - -T - | tar xvf - -C/home/${uname} ) ; \
    mkdir -p /home/${uname}/.ssh ;\
    echo "set mouse-=a" > /home/${uname}/.vimrc; \
    chown -R ${uname}:${uname} /home/${uname} ${workdir};

# install sudo
RUN apt install -y sudo; \
    echo "${uname} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/local-user;
RUN chown root:${gid} /opt; chmod g+w /opt

WORKDIR /
