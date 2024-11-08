# Start from an official miniconda base image
FROM continuumio/miniconda3

# Set a working directory
WORKDIR /app

# Install required system libraries
RUN apt-get update && apt-get install -y libgl1 && rm -rf /var/lib/apt/lists/*

# Copy your environment file (environment.yml) to the container
COPY environment.yml .

# Install dependencies from the Conda environment file
RUN conda env create -f environment.yml

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
