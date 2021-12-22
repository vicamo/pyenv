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
        $(apt-cache search --names-only 'libffi[0-9]+$' 2>/dev/null | awk '{print $1}') \
        $(apt-cache search --names-only 'libmpdec[0-9]+$' 2>/dev/null | awk '{print $1}') \
        libncursesw5 \
        $(apt-cache show libncursesw6 >/dev/null 2>&1 && echo libncursesw6 || true) \
        $(apt-cache search --names-only 'libreadline[0-9]+$' 2>/dev/null | awk '{print $1}') \
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

RUN pyenv latest install 3.6 && \
    pyenv latest install 3.7 && \
    pyenv latest install 3.8 && \
    pyenv latest install 3.9 && \
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
