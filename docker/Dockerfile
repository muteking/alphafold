# Copyright 2021 DeepMind Technologies Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM nvidia/cuda:13.2.0-cudnn-devel-ubuntu24.04

# Use bash to support string substitution.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    cmake \
    git \
    kalign \
    unzip \
    zip \
    wget \
    ca-certificates

# Install Miniforge (open-source, no ToS issue) instead of Miniconda
RUN wget -q -P /tmp \
  https://github.com/conda-forge/miniforge/releases/download/24.3.0-0/Miniforge3-Linux-aarch64.sh \
    && bash /tmp/Miniforge3-Linux-aarch64.sh -b -p /opt/conda \
    && rm /tmp/Miniforge3-Linux-aarch64.sh

# Install Conda packages.
ENV PATH="/opt/conda/bin:$PATH"
ENV LD_LIBRARY_PATH="/opt/conda/lib:$LD_LIBRARY_PATH"
RUN conda install --quiet --yes --channel conda-forge conda==24.3.0 pip python=3.12 libstdcxx-ng>=12.1.0 openmm=8.5.0 pdbfixer \
    && conda clean --all --force-pkgs-dirs --yes

# Install TensorFlow (tested with 2.11.0)
RUN python3 -m pip install --upgrade pip setuptools wheel
RUN pip install tensorflow==2.21.0

COPY . /app/alphafold
RUN wget -q -P /app/alphafold/alphafold/common/ \
  https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt

# Install HH-suite (hhblits, hhsearch) with HMMER support via prebuilt ARM64 binary
# Download precompiled ARM64 package from dev.mmseqs.com
RUN mkdir -p /opt/hhsuite \
  && wget -q -P /tmp \
    https://dev.mmseqs.com/hhsuite/hhsuite-linux-arm64.tar.gz \
  && tar -xzf /tmp/hhsuite-linux-arm64.tar.gz -C /opt \
  && rm /tmp/hhsuite-linux-arm64.tar.gz \
  && ln -s /opt/hhsuite/bin/* /usr/bin

# Install other AlphaFold dependencies
RUN pip install --upgrade pip --no-cache-dir \
    && pip install -r /app/alphafold/requirements.txt --no-cache-dir \
    && pip install "jax[cuda13]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html

# Add SETUID bit to the ldconfig binary so that non-root users can run it.
RUN chmod u+s /sbin/ldconfig.real

# We need to run `ldconfig` first to ensure GPUs are visible, due to some quirk
# with Debian. See https://github.com/NVIDIA/nvidia-docker/issues/1399 for
# details.
# ENTRYPOINT does not support easily running multiple commands, so instead we
# write a shell script to wrap them up.
WORKDIR /app/alphafold
RUN echo $'#!/bin/bash\n\
ldconfig\n\
python /app/alphafold/run_alphafold.py "$@"' > /app/run_alphafold.sh \
  && chmod +x /app/run_alphafold.sh
ENTRYPOINT ["/app/run_alphafold.sh"]

