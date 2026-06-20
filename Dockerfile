FROM runpod/worker-comfyui:5.8.6-base

# Upgrade PyTorch with CUDA 12.4 support (works on all GPUs including L40S/A6000)
RUN pip install --force-reinstall torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

WORKDIR /comfyui
RUN mkdir -p models/unet models/clip models/vae

# WAN 2.1 T2V UNET (~14GB)
RUN wget -q -O models/unet/wan2.1_t2v_14B_fp8_e4m3fn.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_14B_fp8_e4m3fn.safetensors"

# Text encoder (~6.7GB)
RUN wget -q -O models/clip/umt5_xxl_fp8_e4m3fn_scaled.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

# VAE (~254MB)
RUN wget -q -O models/vae/wan_2.1_vae.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

ENV WEBSOCKET_RECONNECT_ATTEMPTS=10
ENV WEBSOCKET_RECONNECT_DELAY_S=5
