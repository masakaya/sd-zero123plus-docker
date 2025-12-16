FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone Zero123++ repository
RUN git clone https://github.com/SUDO-AI-3D/zero123plus.git /app/zero123plus

# Install Python dependencies
WORKDIR /app/zero123plus
RUN pip install --no-cache-dir -r requirements.txt

# Install additional dependencies
RUN pip install --no-cache-dir \
    rembg[gpu] \
    onnxruntime-gpu

# Downgrade packages for compatibility (MUST be after all pip installs)
# - numpy<2: PyTorch 2.1.0 was compiled against NumPy 1.x
# - huggingface_hub<0.23: diffusers 0.20.2 uses deprecated cached_download
RUN pip install --no-cache-dir --force-reinstall "numpy<2" "huggingface_hub<0.23"

# Create directories
WORKDIR /app
RUN mkdir -p /app/input /app/output /app/models

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV TRANSFORMERS_CACHE=/tmp/.cache
ENV HF_HOME=/tmp/.cache

# Default command
CMD ["bash"]
