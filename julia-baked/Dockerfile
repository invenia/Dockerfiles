ARG BASE_IMAGE=111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-bin:1.6.7
FROM ${BASE_IMAGE}

# The behaviour of JULIA_NUM_THREADS has changed a few times across julia minor releases.
#
# - 1.3 .. 1.5 we could select all available cpus with `JULIA_NUM_THREADS=1024`
# - 1.6 the specified value would be used regardless of available cpus
# - 1.7 we'll be able to supply `auto` to get the same behaviour from before on 1.3 .. 1.5.
#
# For simplicity we've just gone with 4 threads and folks can always change this in the entrypoint script.
ENV JULIA_NUM_THREADS=4

# Get security updates
RUN yum -y -d1 update-minimal && \
    yum -y clean all && \
    rm -rf /var/cache/yum

# Install Gitlab deploy key. Allows access to private GitLab repos
# Note: Public key shouldn't be needed but Julia wants it for some strange reason
# Note: Julia doesn't read the ssh config which makes it rather pointless...
ENV HOME /root
RUN [ ! -d $HOME/.ssh ] && mkdir -m 400 $HOME/.ssh
COPY julia-deploy $HOME/.ssh/id_rsa
COPY julia-deploy.pub $HOME/.ssh/id_rsa.pub

# Setup our ssh key and config.
# The config should be only user readable and writable while the key should be only
# user readable.
RUN chmod 400 $HOME/.ssh/id_rsa*
COPY ssh_config $HOME/.ssh/config
RUN chmod 600 $HOME/.ssh/config

# Disable SSH host key checking in Julia (same as `StrictHostKeyChecking no` in ssh_config)
ENV JULIA_SSH_NO_VERIFY_HOSTS "gitlab.invenia.ca"

# Install Invenia private package registry and default to cloning via SSH
ENV PKGS \
    git
RUN yum -y -d1 install $PKGS && \
    git clone git@gitlab.invenia.ca:invenia/PackageRegistry.git ~/.julia/registries/Invenia && \
    julia -e 'using Pkg; Pkg.update()' && \
    git config --global --add url."git@gitlab.invenia.ca:".insteadOf  https://gitlab.invenia.ca/ && \
    for p in $PKGS; do yum -y autoremove $p &>/dev/null && echo "Removed $p" || echo "Skipping removal of $p"; done && \
    yum -y clean all && \
    rm -rf /var/cache/yum

# Install AWS CLI. Do not use `yum install aws-cli` as that version is typically out of date.
ENV PKGS \
    python3-pip
ENV PINNED_PKGS \
    python3
RUN yum -y -d1 install $PKGS $PINNED_PKGS && \
    echo $PINNED_PKGS | tr -s '\t ' '\n' > /etc/yum/protected.d/awscli.conf && \
    pip3 install --upgrade awscli && \
    for p in $PKGS; do yum -y autoremove $p &>/dev/null && echo "Removed $p" || echo "Skipping removal of $p"; done && \
    yum -y clean all && \
    rm -rf /var/cache/yum

# Install cloudspy
ENV PKGS \
    gcc \
    python3-pip \
    python3-devel
ENV PINNED_PKGS \
    python3
RUN yum -y -d1 install $PKGS $PINNED_PKGS && \
    echo $PKGS | tr -s '\t ' '\n' > /etc/yum/protected.d/cloudspy.conf && \
    pip3 install git+ssh://gitlab.invenia.ca/invenia/invenia-cli-utils.git#egg=invenia-cli-utils && \
    pip3 install git+ssh://gitlab.invenia.ca/infrastructure/cloudspy.git#egg=cloudspy && \
    for p in $PKGS; do yum -y autoremove $p &>/dev/null && echo "Removed $p" || echo "Skipping removal of $p"; done && \
    yum -y clean all && \
    rm -rf /var/cache/yum

# Install `iproute` so we can use `ip` in the Julia `--bind-to` flag for use by AWSClusterManager's node workers.
ENV PINNED_PKGS \
    iproute
RUN yum -y -d1 install $PINNED_PKGS && \
    echo $PINNED_PKGS | tr -s '\t ' '\n' > /etc/yum/protected.d/awsclustermanagers.conf

# Install permanent system image creation requirements.
# Note: Need to have libc to avoid: "/usr/bin/ld: cannot find crti.o: No such file or directory"
# https://docs.julialang.org/en/v1.0/devdocs/sysimg/#Building-the-Julia-system-image-1
# TODO: Verify this requirement is still needed once we drop support for PackageCompiler 0.6
ENV PINNED_PKGS \
    glibc
RUN yum -y -d1 install $PINNED_PKGS && \
    echo $PINNED_PKGS | tr -s '\t ' '\n' > /etc/yum/protected.d/julia-sysimg.conf

# Install Cbc and Clp via coinbrew (Cgl is installed as a dependency)
# Required to override artifacts in julia-baked/scripts/set_preferences.jl
WORKDIR $HOME/coinbrew
ENV PKGS \
    make \
    git \
    wget \
    tar \
    patch \
    dos2unix \
    pkg-config \
    gcc-c++ \
    gfortran
RUN yum -y -d1 install $PKGS && \
    wget https://raw.githubusercontent.com/coin-or/coinbrew/master/coinbrew && \
    chmod u+x coinbrew && \
    # - Can't specify a commit SHA but can specify the timestamp of the commit
    # This will also grab dependencies @ master during that time
    # https://github.com/coin-or/coinbrew/discussions/77#discussioncomment-3602942
    # - Clp needs to be installed explicitly before Cbc to avoid hitting a "no solver available"
    # error when installing the Osi dependency for Cbc
    # https://github.com/coin-or/Osi/issues/139
    ./coinbrew build Clp@master --tests none --no-third-party --time "Fri Aug 26 11:42:30 2022" && \
    ./coinbrew build Cbc@master --tests none --no-third-party --time "Mon Sep 5 22:18:39 2022" && \
    # Clean up
    rm coinbrew && \
    rm -rf Cbc Cgl Clp CoinUtils Data Osi ThirdParty build && \
    for p in $PKGS; do yum -y autoremove $p &>/dev/null && echo "Removed $p" || echo "Skipping removal of $p"; done && \
    yum -y clean all && \
    rm -rf /var/cache/yum

COPY scripts/*.jl $JULIA_PATH/
COPY scripts/*.sh scripts/env-split $HOME/
