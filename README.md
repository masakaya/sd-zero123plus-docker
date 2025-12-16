# sd-zero123plus-docker

Docker environment for Zero123++ to generate consistent multi-view images (6 views) from a single image for LoRA training data preparation.

## Features

- **Input**: Single image (any style - anime, illustration, photo, etc.)
- **Output**: 6 multi-view images (3x2 grid)
- **Camera angles**: Fixed 6 directions (elevation 30°, azimuth 30°/90°/150°/210°/270°/330°)
- **VRAM**: ~5GB (lightweight)
- **Interface**: CLI

## Quick Start

```bash
# Setup (first time only)
make setup
make download-models
make build

# Run inference
make run INPUT=input/your_image.png

# Output will be saved to output/your_image_mv.png
```

## Requirements

- Ubuntu 22.04 / 24.04
- NVIDIA GPU (VRAM 6GB+ recommended)
- Docker & Docker Compose
- NVIDIA Container Toolkit

## Installation

### 1. Clone repository

```bash
git clone https://github.com/masakaya/sd-zero123plus-docker.git
cd sd-zero123plus-docker
```

### 2. Setup directories and model symlink

```bash
make setup
```

This creates:
- `input/` - Place input images here
- `output/` - Generated images will be saved here
- `models/` - Symlink to `~/ai-models/stable-diffusion/zero123plus/`

### 3. Download model

```bash
make download-models
```

Downloads `zero123plus-v1.2` from HuggingFace to `~/ai-models/stable-diffusion/zero123plus/`.

### 4. Build Docker image

```bash
make build
```

## Usage

### Run Inference

```bash
# Basic usage
make run INPUT=input/your_image.png

# With custom steps (default: 75)
docker compose run --rm zero123plus \
    python /app/scripts/infer.py --input /app/input/your_image.png --steps 100
```

### Parameters

- **--input, -i**: Input image path (required)
- **--output, -o**: Output directory (default: /app/output)
- **--steps**: Number of inference steps (default: 75, recommended: 50-100)

### Output format

Generated images are 3x2 grids containing 6 views:

```
┌───────┬───────┬───────┐
│  30°  │  90°  │ 150°  │  (Row 1)
├───────┼───────┼───────┤
│ 210°  │ 270°  │ 330°  │  (Row 2)
└───────┴───────┴───────┘
  Azimuth angles (Elevation: 30°)
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make setup` | Create directories and symlinks |
| `make download-models` | Download model from HuggingFace |
| `make build` | Build Docker image |
| `make up` | Start container (background) |
| `make run INPUT=path` | Run inference on specified image |
| `make down` | Stop container |
| `make shell` | Open shell in container |
| `make logs` | Show container logs |
| `make clean` | Clean output directory |
| `make help` | Show help |

## Recommended Parameters

| Input Type | Steps | Notes |
|------------|-------|-------|
| General objects | 50 | Default |
| Anime/Illustration | 75-100 | Official recommendation |
| Complex characters | 100 | Higher quality |

## Directory Structure

```
sd-zero123plus-docker/
├── README.md
├── LICENSE
├── .gitignore
├── compose.yml
├── Makefile
├── Dockerfile
├── models/          # Symlink to ~/ai-models/stable-diffusion/zero123plus/
├── input/           # Input images (optional)
└── output/          # Generated images (optional)
```

## Troubleshooting

### CUDA out of memory

Reduce inference steps (try 50 instead of 75):
```bash
docker compose run --rm zero123plus \
    python /app/scripts/infer.py --input /app/input/image.png --steps 50
```

### Low output quality

Increase inference steps (recommended 100 for anime/illustration):
```bash
docker compose run --rm zero123plus \
    python /app/scripts/infer.py --input /app/input/image.png --steps 100
```

### Container not running

Check container status:
```bash
docker compose ps
make logs
```

## License

- Code: Apache-2.0
- Model: CC-BY-NC 4.0 (non-commercial)
- **Generated outputs can be used commercially**

## References

- [Zero123++ Paper](https://arxiv.org/abs/2310.15110)
- [HuggingFace Model](https://huggingface.co/sudo-ai/zero123plus-v1.2)
- [GitHub Repository](https://github.com/SUDO-AI-3D/zero123plus)

## Related Projects

- [sd-charactergen-docker](https://github.com/masakaya/sd-charactergen-docker) - Anime character multi-view generation
- [sd-dataset-tagger-editor-docker](https://github.com/masakaya/sd-dataset-tagger-editor-docker) - Image tagging
- [sd-webui-kohya-docker](https://github.com/masakaya/sd-webui-kohya-docker) - LoRA training
- [sd-comfyui-controlnet-docker](https://github.com/masakaya/sd-comfyui-controlnet-docker) - Image generation
