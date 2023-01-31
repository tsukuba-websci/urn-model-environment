FROM python:3.9-bullseye

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root

# General dependencies
RUN apt-get update && apt-get install -y \
  zip unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Juia installation 
# from: https://github.com/jupyter/docker-stacks/blob/main/datascience-notebook/Dockerfile
# - Copyright (c) 2001-2015, IPython Development Team
# - Copyright (c) 2015-, Jupyter Development Team
ARG julia_version="1.8.5"
ENV JULIA_DEPOT_PATH=/opt/julia \
  JULIA_PKGDIR=/opt/julia \
  JULIA_VERSION="${julia_version}"
WORKDIR /tmp
RUN set -x && \
  julia_arch=$(uname -m) && \
  julia_short_arch="${julia_arch}" && \
  if [ "${julia_short_arch}" == "x86_64" ]; then \
  julia_short_arch="x64"; \
  fi; \
  julia_installer="julia-${JULIA_VERSION}-linux-${julia_arch}.tar.gz" && \
  julia_major_minor=$(echo "${JULIA_VERSION}" | cut -d. -f 1,2) && \
  mkdir "/opt/julia-${JULIA_VERSION}" && \
  wget -q "https://julialang-s3.julialang.org/bin/linux/${julia_short_arch}/${julia_major_minor}/${julia_installer}" && \
  tar xzf "${julia_installer}" -C "/opt/julia-${JULIA_VERSION}" --strip-components=1 && \
  rm "${julia_installer}" && \
  ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# PyCall installation
RUN julia -e 'using Pkg; Pkg.add("PyCall")'

# Rust installation
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > install-rust.sh
RUN sh install-rust.sh -y

WORKDIR /
CMD [ "/bin/bash" ]
