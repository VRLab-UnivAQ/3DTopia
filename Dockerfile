# Start from a CUDA-compatible Miniconda base image with development libraries
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# Update and prepare OS base
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y wget git libgl1 g++ build-essential ninja-build && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda init bash

# Set PATH to use Conda
ENV PATH /opt/conda/bin:$PATH

# Set CUDA environment variables
ENV CUDA_HOME /usr/local/cuda
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV PATH /usr/local/cuda/bin:$PATH

# Set a working directory
WORKDIR /app

# Copy your environment file (environment.yml) to the container
COPY environment.yml .

# Install dependencies from the Conda environment file and add cuda-toolkit
RUN conda env create -f environment.yml && \
    conda install -n 3dtopia -c conda-forge cudatoolkit=11.8

# Verify CUDA setup
RUN echo "Testing CUDA installation..." && \
    ls /usr/local/cuda/include/cuda_runtime.h && \
    conda run -n 3dtopia python -c "import torch; print(torch.cuda.is_available())"

# Create symbolic links for CUDA libraries
RUN ln -s /usr/local/cuda/include/* /opt/conda/envs/3dtopia/include/ && \
    ln -s /usr/local/cuda/lib64/* /opt/conda/envs/3dtopia/lib/

# Make sure Conda environment is activated in subsequent commands
SHELL ["conda", "run", "-n", "3dtopia", "/bin/bash", "-c"]

# Copy the rest of your application code
COPY . .

# Download the 3DTopia model from Hugging Face (direct download link)
RUN mkdir -p /models && \
    wget -O /models/3dtopia_diffusion_state_dict.ckpt https://huggingface.co/hongfz16/3DTopia/resolve/main/3dtopia_diffusion_state_dict.ckpt

# Set the CMD to run your application
CMD ["conda", "run", "-n", "3dtopia", "python", "gradio_demo.py"]
