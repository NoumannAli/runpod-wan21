FROM runpod/worker-comfyui:5.8.6-base

WORKDIR /comfyui

RUN mkdir -p models/unet models/clip models/vae

# WAN 2.1 T2V models from Comfy-Org official repo
RUN wget -q -O models/unet/wan2.1_t2v_14B_fp8_e4m3fn.safetensors \
    https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/models/wan2.1_t2v_14B_fp8_e4m3fn.safetensors

RUN wget -q -O models/clip/umt5_xxl_fp8_e4m3fn_scaled.safetensors \
    https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/models/umt5_xxl_fp8_e4m3fn_scaled.safetensors

RUN wget -q -O models/vae/wan_2.1_vae.safetensors \
    https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/models/wan_2.1_vae.safetensors

# Increase timeouts for large model loading
ENV WEBSOCKET_RECONNECT_ATTEMPTS=10
ENV WEBSOCKET_RECONNECT_DELAY_S=5
