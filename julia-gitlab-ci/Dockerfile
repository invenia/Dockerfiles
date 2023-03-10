ARG BASE_IMAGE=111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-baked:1.6.6
FROM ${BASE_IMAGE}

# Code coverage analysis requirements
# lcov: a modern version from https://github.com/linux-test-project/lcov/releases
# perl-Digest-MD5: required to run lcov, and rsync is used  to copy coverage files into the
# artifact directory (see julia-coverage).
# Validate lcov is installed to avoid a re-occurrence of: https://gitlab.invenia.ca/invenia/Dockerfiles/issues/24
# latest lcov is incompatible with current RPM so use previous version
ENV PKGS \
    jq
ENV PINNED_PKGS \
    perl-Digest-MD5 \
    rsync
RUN yum -y -d1 install $PKGS && \
    lcov_url="https://github.com/linux-test-project/lcov/releases/download/v1.15/lcov-1.15-1.noarch.rpm" && \
    echo "Downloading LCOV from: $lcov_url" && \
    curl -sL $lcov_url -o lcov.rpm && \
    yum -y -d1 install lcov.rpm $PINNED_PKGS && \
    echo lcov $PINNED_PKGS > /etc/yum/protected.d/julia-coverage.conf && \
    genhtml --version && \
    for p in $PKGS; do yum -y autoremove $p &>/dev/null && echo "Removed $p" || echo "Skipping removal of $p"; done && \
    yum -y clean all && \
    rm -rf /var/cache/yum

COPY julia-coverage /usr/local/bin/

# Install the gitlab-ci-credential helper which allows clone operations using `git` or Julia >=0.7
# when executed within a GitLab CI runner to happen transparently.
ENV PKGS \
    git
RUN yum -y -d1 install $PKGS && \
    git clone --depth 1 git@gitlab.invenia.ca:infrastructure/gitlab-ci-helper.git && \
    mv gitlab-ci-helper/gitlab-ci-credential /usr/local/bin && \
    rm -rf gitlab-ci-helper && \
    git config --global credential.https://gitlab.invenia.ca.helper /usr/local/bin/gitlab-ci-credential && \
    # Validate the credential helper is installed. An invalid installation will result in `fatal: could not read Password ...`
    echo -e "protocol=https\nhost=gitlab.invenia.ca\nusername=gitlab-ci-token\n\n" | CI_JOB_TOKEN=1234 CI_PROJECT_URL=https://gitlab.invenia.ca git credential fill > /dev/null && \
    for p in $PKGS; do yum -y autoremove $p &>/dev/null && echo "Removed $p" || echo "Skipping removal of $p"; done && \
    yum -y clean all && \
    rm -rf /var/cache/yum

# Install entry-point script
COPY entry-point /usr/local/bin/

# Add the private metadata credentials, then run Julia.
ENTRYPOINT ["/usr/local/bin/entry-point"]
CMD ["julia"]
