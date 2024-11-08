# Start from a CUDA-compatible Miniconda base image
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# Update and prepare OS base
RUN apt-get update && apt-get upgrade -y && apt-get install -y wget git libgl1 g++ build-essential ninja-build && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda init bash

# Set PATH to use Conda
ENV PATH /opt/conda/bin:$PATH

# Set a working directory
WORKDIR /app

# Copy your environment file (environment.yml) to the container
COPY environment.yml .

# Install dependencies from the Conda environment file and add cuda-toolkit
RUN conda env create -f environment.yml && \
    conda install -n 3dtopia -c conda-forge cudatoolkit=11.8

# Make sure Conda environment is activated in subsequent commands
SHELL ["conda", "run", "-n", "3dtopia", "/bin/bash", "-c"]

RUN pip freeze

# Copy the rest of your application code
COPY . .

# Get the 3DTopia model from Huggingface
RUN wget https://huggingface.co/hongfz16/3DTopia/blob/main/3dtopia_diffusion_state_dict.ckpt

# Set the CMD in JSON format with each argument as a separate item 
# CMD ["conda", "run", "-n", "3dtopia", "python", "-u",                     \
#     "sample_stage1.py", "--text=a robot", "--samples=1",                 \
#     "--sampler=ddim", "--steps=200", "--cfg_scale=7.5", "--seed=0",      \
#     "--ckkt=3dtopia_diffusion_state_dict.ckpt"]
CMD ["conda", "run", "-n", "3dtopia", "python", "gradio_demo.py"]
