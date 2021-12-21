FROM ubuntu:20.04

ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV PATH="/opt/pyenv/shims:/opt/pyenv/bin:$PATH"
ENV PYENV_ROOT="/opt/pyenv"
ENV PYENV_SHELL="bash"

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libbz2-dev \
    libffi-dev \
    libreadline-dev \
    libssl-dev \
    zlib1g-dev

RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash && \
    git clone https://github.com/momo-lab/xxenv-latest $PYENV_ROOT/plugins/xxenv-latest && \
    pyenv update

RUN pyenv latest install 3.6 && \
    pyenv latest install 3.7 && \
    pyenv latest install 3.8 && \
    pyenv latest install 3.9
RUN pyenv global $(pyenv versions --bare | tac)

RUN pip install tox tox-pyenv
