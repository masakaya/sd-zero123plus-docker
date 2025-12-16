# sd-zero123plus-docker

## 概要

Zero123++を使用して、単一画像から一貫性のある6視点画像を生成するDocker環境。
LoRA学習データ作成や3D再構築の前処理として使用。

## Description

```
Docker environment for Zero123++ to generate consistent multi-view images (6 views) from a single image for LoRA training data preparation.
```

## Zero123++の特徴

- **入力**: 単一画像（任意のスタイル - アニメ、イラスト、写真、動物等）
- **出力**: 6視点画像（3×2グリッド）
- **カメラ角度**: 固定6方向（仰角30°で方位角30°/90°/150°/210°/270°/330°）
- **VRAM**: 約5GB（軽量）
- **モデル**: SD1.2ベースのfine-tuned diffusion model
- **インターフェース**: Gradio WebUI（公式提供）

## 公式リポジトリ

- https://github.com/SUDO-AI-3D/zero123plus
- HuggingFace: https://huggingface.co/sudo-ai/zero123plus-v1.2

## ライセンス

- コード: Apache-2.0
- モデル: CC-BY-NC 4.0（非商用）
- **出力物は商用利用可能**

## ディレクトリ構造

```
sd-zero123plus-docker/
├── README.md
├── LICENSE
├── .gitignore
├── compose.yml
├── Makefile
├── Dockerfile
├── models/                   # → ~/ai-models/stable-diffusion/zero123plus/ へのシンボリックリンク
├── input/                    # 入力画像配置ディレクトリ（オプション）
└── output/                   # 生成画像出力ディレクトリ（オプション）
```

## モデル管理

### 保存先（ホスト）
```
~/ai-models/stable-diffusion/zero123plus/
└── zero123plus-v1.2/         # 推奨バージョン
```

### シンボリックリンク
```bash
ln -s ~/ai-models/stable-diffusion/zero123plus models
```

## Makefile コマンド

```bash
# セットアップ
make setup              # ディレクトリ作成 + シンボリックリンク
make download-models    # HuggingFaceからモデルDL（v1.2）
make build              # イメージビルド

# 実行
make up                 # コンテナ起動（バックグラウンド）
make start              # Gradio WebUI起動 (http://localhost:7860)
make down               # コンテナ停止

# ユーティリティ
make shell              # コンテナ内シェル
make logs               # ログ表示
make clean              # 出力クリア
make help               # ヘルプ表示
```

## compose.yml

```yaml
services:
  zero123plus:
    build:
      context: .
      dockerfile: Dockerfile
    image: sd-zero123plus:latest
    container_name: sd-zero123plus
    volumes:
      - ./models:/app/models:ro
      - ./input:/app/input:ro
      - ./output:/app/output
    ports:
      - "7860:7860"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    shm_size: '4g'
    tty: true
    stdin_open: true
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - PYTHONUNBUFFERED=1
```

## Dockerfile

### ベースイメージ
```dockerfile
FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime
```

### 必要パッケージ
- Python 3.10+
- PyTorch 2.x
- diffusers
- transformers
- accelerate
- Pillow
- gradio（WebUI用）
- rembg（背景除去、オプション）

### インストール手順
```dockerfile
# 公式リポジトリをクローン
RUN git clone https://github.com/SUDO-AI-3D/zero123plus.git /app/zero123plus

# 依存関係インストール
WORKDIR /app/zero123plus
RUN pip install -r requirements.txt

# 追加パッケージ
RUN pip install rembg[gpu] onnxruntime-gpu gradio

# ディレクトリ作成
WORKDIR /app
RUN mkdir -p /app/input /app/output /app/models
```

## WebUI使用方法

### 起動

```bash
make up      # コンテナ起動
make start   # Gradio WebUI起動
```

ブラウザで **http://localhost:7860** にアクセス

### 操作手順

1. 画像をアップロード
2. パラメータ調整:
   - **Inference Steps**: 50-100（高いほど高品質）
   - **Guidance Scale**: デフォルト 4.0
3. "Generate" クリック
4. 結果をダウンロード（3×2グリッド）

### 出力形式

生成画像は3×2グリッド（6視点）:

```
┌───────┬───────┬───────┐
│  30°  │  90°  │ 150°  │  (Row 1)
├───────┼───────┼───────┤
│ 210°  │ 270°  │ 330°  │  (Row 2)
└───────┴───────┴───────┘
  方位角 (仰角: 30°)
```

## 推奨パラメータ

| 入力タイプ | 推論ステップ | 備考 |
|-----------|-------------|------|
| 一般オブジェクト | 50 | デフォルト |
| アニメ・イラスト | 75-100 | 公式推奨 |
| 複雑なキャラクター | 100 | より高品質 |

## 使用例

### 基本的な使い方

```bash
# セットアップ（初回のみ）
make setup
make download-models
make build

# WebUI起動
make up
make start

# ブラウザで http://localhost:7860 にアクセス
```

### LoRA学習データ作成ワークフロー

```bash
# 1. WebUIで画像を処理、6視点グリッドを生成

# 2. 必要に応じて画像編集ソフトでグリッドを分割

# 3. sd-dataset-tagger-editor-dockerでタグ付け

# 4. sd-webui-kohya-dockerでLoRA学習
```

## トラブルシューティング

### CUDA out of memory

WebUIでステップ数を減らす（50程度）

### 出力品質が低い

ステップ数を増やす（アニメは100推奨）

### WebUIにアクセスできない

コンテナ状態を確認:
```bash
docker compose ps
make logs
```

## 動作要件

- Ubuntu 22.04 / 24.04
- NVIDIA GPU（VRAM 6GB以上推奨）
- Docker & Docker Compose
- NVIDIA Container Toolkit

## 参考

- [Zero123++ Paper](https://arxiv.org/abs/2310.15110)
- [HuggingFace Model](https://huggingface.co/sudo-ai/zero123plus-v1.2)
- [GitHub Repository](https://github.com/SUDO-AI-3D/zero123plus)

## 関連リポジトリ

- [sd-charactergen-docker](https://github.com/masakaya/sd-charactergen-docker) - アニメキャラ専用多視点生成
- [sd-dataset-tagger-editor-docker](https://github.com/masakaya/sd-dataset-tagger-editor-docker) - タグ付け
- [sd-webui-kohya-docker](https://github.com/masakaya/sd-webui-kohya-docker) - LoRA学習
- [sd-comfyui-controlnet-docker](https://github.com/masakaya/sd-comfyui-controlnet-docker) - 画像生成
