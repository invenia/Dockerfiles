FROM amazonlinux:2
# Originally based off of: https://github.com/docker-library/julia/blob/master/Dockerfile-debian.template

# Use ARG to allow customization via `--build-arg` and ENV to retain the information after
# the build
ARG JULIA_VERSION=1.6.6
ENV JULIA_VERSION $JULIA_VERSION

# Support limited semantic version forms including pre-release metadata.
RUN if [[ ! "$JULIA_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9](\-[0-9A-Za-z-]+)?$ ]] && [[ "$JULIA_VERSION" != "nightly" ]]; then \
       echo "JULIA_VERSION ${JULIA_VERSION} does not match the expected MAJOR.MINOR.PATCH semver format" >&2; \
       exit 1; \
    fi

ENV JULIA_PATH /usr/local/julia

# Get security updates
RUN yum -y -d1 update-minimal && \
    yum -y clean all && \
    rm -rf /var/cache/yum

# Install Julia release GPG key (https://julialang.org/downloads/#Download%20verification)
# Repo copy created via: `curl -sSL "https://julialang.org/juliareleases.asc" -o juliareleases.gpg`
# The fingerprint can be created from the GPG key with: `gpg --list-keys --fingerprint`
ENV GPG_FINGERPRINT 3673DF529D9049477F76B37566E3C7DC03D6E495
COPY juliareleases.gpg .
RUN gpg --import juliareleases.gpg && \
    echo "${GPG_FINGERPRINT}:6:" | gpg --import-ownertrust && \
    rm juliareleases.gpg

# Note: The nightly releases are not signed with GPG: https://github.com/JuliaLang/julia/issues/31052
# Permanently install packages which are needed for the Julia runtime
ENV PINNED_PKGS \
    libgfortran \
    curl \
    which \
    tar \
    gzip
RUN yum -y -d1 install $PINNED_PKGS && \
    echo $PINNED_PKGS | tr -s '\t ' '\n' > /etc/yum/protected.d/julia.conf && \
    arch=$(uname --hardware-platform) && \
    case "$arch" in \
        x86_64) tar_arch="x86_64"; dir_arch="x64" ;; \
        aarch64) tar_arch="aarch64"; dir_arch="aarch64" ;; \
        i386) tar_arch="i686"; dir_arch="x86" ;; \
        *) echo "error: current architecture ($arch) does not have a corresponding Julia binary release" >&2; exit 1 ;; \
    esac && \
    mkdir -p $JULIA_PATH && \
    if [[ "$JULIA_VERSION" == "nightly" ]]; then \
        url="https://julialangnightlies-s3.julialang.org/bin/linux/${tar_arch}/julia-latest-linux-${tar_arch}.tar.gz"; \
    else \
        url="https://julialang-s3.julialang.org/bin/linux/${dir_arch}/${JULIA_VERSION%\.*}/julia-${JULIA_VERSION}-linux-${tar_arch}.tar.gz"; \
    fi; \
    status=$(curl --head -sSLw '%{http_code}\n' "$url" -o /dev/null) && \
    if [[ $status -ne 200 ]]; then \
        echo -e "HTTP status $status returned when attempting to validate existence of: $url" >&2 && \
        exit 1; \
    fi; \
    # Note: Using `-L` when attempting to download a non-existent S3 file will result in an HTTP 200 response containing "NoSuchKey"
    curl -sSL "$url" -o julia.tar.gz && \
    if [[ "$JULIA_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]$ ]]; then \
        curl -sSL "${url}.asc" -o julia.tar.gz.asc && \
        gpg --batch --verify julia.tar.gz.asc julia.tar.gz && \
        rm julia.tar.gz.asc; \
    fi; \
    tar -xzf julia.tar.gz -C $JULIA_PATH --strip-components 1 && \
    rm julia.tar.gz

# Copy the Make.user file to JULIA_PATH for downstream dockerfiles to create system images
COPY Make.user "$JULIA_PATH/"
RUN arch=$(uname --hardware-platform) && \
    case "$arch" in \
        x86_64) MARCH=core-avx2 ;; \
        aarch64) MARCH=armv8.2-a ;; \
        *) echo "error: current architecture ($arch) does not have a corresponding MARCH defined" >&2; exit 1 ;; \
    esac && \
    echo "MARCH=$MARCH" >> $JULIA_PATH/Make.user

ENV PATH $JULIA_PATH/bin:$PATH
ENV JULIA_PKGDIR /root/.julia

# Disable using the Julia package server for now as it can be out-of-sync with registries
ENV JULIA_PKG_SERVER ""

RUN julia -e 'using InteractiveUtils; versioninfo()' && \
    julia -e 'using Pkg; Pkg.update()'

CMD ["julia"]
