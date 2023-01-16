FROM ubuntu:20.04 AS base

ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV PATH="/opt/pyenv/shims:/opt/pyenv/bin:$PATH"
ENV PYENV_ROOT="/opt/pyenv"
ENV PYENV_SHELL="bash"

# runtime dependencies
RUN apt-get update --quiet && \
    apt-get install -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        curl \
        git \
        libexpat1 \
        libffi7 \
        libmpdec2 \
        libncursesw5 \
        libncursesw6 \
        libreadline5 \
        libsqlite3-0 \
        libssl1.1 \
        lzma \
        zlib1g

RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash && \
    git clone https://github.com/momo-lab/xxenv-latest $PYENV_ROOT/plugins/xxenv-latest && \
    pyenv update

# ---

FROM base as build

# builder dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libbz2-dev \
    libffi-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    zlib1g-dev

RUN pyenv install 3.6 && \
    pyenv install 3.7 && \
    pyenv install 3.8 && \
    pyenv install 3.9 && \
    pyenv install 3.10 && \
    pyenv global $(pyenv versions --bare | tac) && \
    pyenv versions && \
    find ${PYENV_ROOT}/versions -depth \
        \( \
            \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
            -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
            -o \( -type f -a -name 'wininst-*.exe' \) \
        \) -exec rm -rf '{}' +  && \
    pip install tox tox-pyenv

# ---

FROM base

COPY --from=build ${PYENV_ROOT}/versions/ ${PYENV_ROOT}/versions/

RUN pyenv rehash && \
    pyenv global $(pyenv versions --bare | tac) && \
    pyenv versions
