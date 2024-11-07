# Start from an official miniconda base image
FROM continuumio/miniconda3

# Set a working directory
WORKDIR /app

# Copy your environment file (environment.yml) to the container
COPY environment.yml .

# Install dependencies from the Conda environment file
RUN conda env create -f environment.yml

# Make sure Conda environment is activated in subsequent commands
# Here, replace 'myenv' with the name of your Conda environment in environment.yml
SHELL ["conda", "run", "-n", "myenv", "/bin/bash", "-c"]

RUN conda activate 3dtopia

# Copy the rest of your application code
COPY . .

# Get the 3DTopia model from Huggingface
RUN wget https://huggingface.co/hongfz16/3DTopia/blob/main/3dtopia_diffusion_state_dict.ckpt

# Set the command to run your application
# Update this based on your application entry point
CMD ["python", "-u sample_stage1.py", "--text "a robot"",  "--samples 1", "--sampler ddim", "--steps 200", "--cfg_scale 7.5", "--seed 0"]
