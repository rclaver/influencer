#!/bin/bash

# Descargar modelo pequeño
function descarrega_model() {
   mkdir -p ~/.localai-models
   cd ~/.localai-models
   wget https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf
}

# Activar el servidor
function activa_servidor() {
   # -it interactiu
   # -d background
   docker run -p 8080:8080 -it --name local-ai -v ~/.localai-models:/build/models localai/localai:latest-cpu
}

function executa() {
   docker exec -it local-ai local-ai run llama-3.2-1b-instruct:q4_k_m
}

function mostra_models() {
   # el servidor ha d'estar actiu'
   curl http://localhost:8080/v1/models
}
