# RunPod ComfyUI Serverless Setup Guide

This guide walks you through setting up a working RunPod Custom ComfyUI Serverless endpoint for WAN 2.1 T2V video generation.

## Prerequisites

- Docker installed on your machine
- Docker Hub account (free)
- RunPod account with API key
- RunPod credits (L40S GPU costs ~$0.44/hr)

---

## Step 1: Build & Push Docker Image

### 1.1 Navigate to runpod directory
```bash
cd runpod/
```

### 1.2 Build the Docker image
```bash
docker build --platform linux/amd64 -t YOUR_DOCKERHUB_USERNAME/runpod-wan21:1.0 .
```

> **Note**: Replace `YOUR_DOCKERHUB_USERNAME` with your actual Docker Hub username.
> The image will be ~25-30GB. First build takes 10-20 minutes.

### 1.3 Login to Docker Hub
```bash
docker login
```
Enter your Docker Hub username and password when prompted.

### 1.4 Push the image
```bash
docker push YOUR_DOCKERHUB_USERNAME/runpod-wan21:1.0
```

---

## Step 2: Create RunPod Template

1. Go to [RunPod Console](https://www.runpod.io/console/serverless/user/templates)
2. Click **New Template**
3. Fill in:
   - **Template Name**: `worker-comfyui-wan21`
   - **Template Type**: Select **Serverless**
   - **Container Image**: `YOUR_DOCKERHUB_USERNAME/runpod-wan21:1.0`
   - **Container Registry Credentials**: Leave as default (public image)
   - **Container Disk**: `50` GB
4. Click **Save Template**

---

## Step 3: Create Serverless Endpoint

1. Go to [Serverless Endpoints](https://www.runpod.io/console/serverless/user/endpoints)
2. Click **New Endpoint**
3. Fill in:
   - **Endpoint Name**: `wan21-t2v`
   - **Select Template**: `worker-comfyui-wan21`
   - **Worker Configuration**: Select **L40S 48GB** (recommended) or **RTX 6000 Ada 48GB**
   - **Active Workers**: `0` (scales to zero when idle)
   - **Max Workers**: `1` (increase if you need parallel processing)
   - **GPUs/Worker**: `1`
   - **Idle Timeout**: `5`
   - **Flash Boot**: **Enabled** (faster cold starts)
4. Click **Deploy**
5. Wait for status to show **Ready** (2-3 minutes)

---

## Step 4: Get Your Endpoint ID

1. Click on your new endpoint
2. Look for **Endpoint ID** in the Overview section
3. Copy the ID (looks like `abc123xyz456`)

---

## Step 5: Update Your .env File

Add to your `.env` file:
```
RUNPOD_ENDPOINT_ID=YOUR_ENDPOINT_ID_HERE
```

---

## Step 6: Test the Endpoint

### Quick Test (Single Frame)
```bash
python runpod_single_test.py
```

### Full Test (Video Generation)
```bash
python runpod_test_workflow.py
```

### Expected Output
```
[1/2] Submitting to RunPod ComfyUI endpoint...
  HTTP 200 (2.1s)
  Job ID: job_abc123...
  Status: IN_QUEUE

[2/2] Waiting for completion...
  [0m10s] Status: IN_PROGRESS (cold start loading models...)
  [0m20s] Status: IN_PROGRESS (cold start loading models...)
  [0m30s] Status: IN_PROGRESS
  [1m00s] Status: IN_PROGRESS
  [2m30s] Status: COMPLETED
  Cost: $0.12
  SUCCESS — Endpoint is working
```

> **Note**: First cold start takes 30-60 seconds as models load into VRAM. Subsequent requests are faster.

---

## Troubleshooting

### "Websocket receive timed out" Error
**Cause**: ComfyUI container not running or models not loaded.
**Fix**: Verify your Docker image has the correct models and the endpoint is using your custom template.

### "FAILED" Status with Error
**Cause**: Insufficient VRAM or incorrect model paths.
**Fix**:
- Ensure you're using L40S 48GB or RTX 6000 Ada 48GB
- Check container disk is at least 50GB

### Cold Start Takes Too Long
**Cause**: Large model loading on first request.
**Fix**:
- Enable Flash Boot in endpoint settings
- Set Active Workers to 1 (keeps one warm)
- This is normal for WAN 2.1 14B model (~25GB)

### "ComfyUI server not reachable"
**Cause**: ComfyUI process crashed on startup.
**Fix**:
- Check RunPod worker logs for CUDA errors
- Verify GPU has enough VRAM (24GB minimum for FP8)
- Try reducing RUNPOD_FRAMES to 49 or RUNPOD_STEPS to 20

---

## Cost Optimization

### Scale to Zero (Recommended)
- Active Workers: 0
- Max Workers: 1
- Idle Timeout: 5

This keeps costs at $0 when not generating. First request triggers cold start (~30-60s).

### Keep Warm (Faster Response)
- Active Workers: 1
- Max Workers: 2
- Idle Timeout: 5

This keeps one GPU running (~$0.44/hr) for instant response.

### Reduce Resolution for Testing
In `config.py`:
```python
RUNPOD_WIDTH = 480
RUNPOD_HEIGHT = 832
RUNPOD_FRAMES = 33  # ~2 seconds at 16fps
RUNPOD_STEPS = 20
```

---

## Model Files Included

Your Docker image includes these models:
- `wan2.1_t2v_14B_fp8_e4m3fn.safetensors` (~14GB) - Main video model
- `umt5_xxl_fp8_e4m3fn_scaled.safetensors` (~10GB) - Text encoder
- `wan_2.1_vae.safetensors` (~300MB) - Video autoencoder

All models from [Comfy-Org/Wan_2.1_ComfyUI_repackaged](https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged).

---

## Next Steps

After testing succeeds:
1. Update `config.py` with your preferred settings
2. Run the full pipeline: `python run_pipeline.py`
3. Monitor costs in RunPod dashboard
