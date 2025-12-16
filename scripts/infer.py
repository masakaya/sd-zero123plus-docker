#!/usr/bin/env python3
"""Zero123++ inference script."""

import argparse
from pathlib import Path

import torch
from diffusers import DiffusionPipeline, EulerAncestralDiscreteScheduler
from PIL import Image


def main():
    parser = argparse.ArgumentParser(description="Zero123++ inference")
    parser.add_argument("--input", "-i", required=True, help="Input image path")
    parser.add_argument("--output", "-o", default="/app/output", help="Output directory")
    parser.add_argument("--model", "-m", default="/app/models/zero123plus-v1.2", help="Model path")
    parser.add_argument("--steps", type=int, default=75, help="Number of inference steps")
    args = parser.parse_args()

    input_path = Path(args.input)
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Loading model from {args.model}...")
    pipe = DiffusionPipeline.from_pretrained(
        args.model,
        custom_pipeline="sudo-ai/zero123plus-pipeline",
        torch_dtype=torch.float16,
    )
    pipe.scheduler = EulerAncestralDiscreteScheduler.from_config(
        pipe.scheduler.config, timestep_spacing='trailing'
    )
    pipe.to("cuda")

    print(f"Processing {input_path}...")
    image = Image.open(input_path)
    result = pipe(image, num_inference_steps=args.steps).images[0]

    output_path = output_dir / f"{input_path.stem}_mv.png"
    result.save(output_path)
    print(f"Saved to {output_path}")


if __name__ == "__main__":
    main()
