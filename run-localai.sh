#!/bin/bash

# Descargar modelo pequeño
function descarrega_model() {
   mkdir -p /media/rafael/dades/localai-models
   cd /media/rafael/dades/localai-models
   wget https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf
   wget https://huggingface.co/hugging-quants/Llama-3.2-1B-Instruct-Q4_K_M-GGUF/blob/main/llama-3.2-1b-instruct-q4_k_m.gguf
   wget https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf
   wget https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/resolve/main/llama-2-7b-chat.Q4_K_M.gguf
}

# Detener y Eliminar el contenedor
function elimina_contenidor() {
   docker stop local-ai
   docker rm local-ai
}

# Activar el servidor
function activa_servidor() {
   elimina_contenidor
   # -it interactiu
   # -d background
   echo "docker run -p 8080:8080 -it --name local-ai -v /media/rafael/dades/localai-models:/build/models localai/localai:latest-cpu"
   docker run -p 8080:8080 -it --name local-ai -v /media/rafael/dades/localai-models:/build/models localai/localai:latest-cpu
}

function executa() {
   docker exec -it local-ai local-ai run llama-3.2-1b-instruct:q4_k_m
}

function mostra_models() {
   echo "Llista de models"
   models=$(curl http://localhost:8080/v1/models)
   echo $models

   partToken=${models//,\"expiresAt\":*}    # elimina la part posterior a l'expressió
   httpToken=${partToken#\{*\"downloadUrl\":}      # elimina la primera part que conté l'expressió
   httpToken=${httpToken//\"}                      # elimina todas las comillas
}

function prova_model() {
   echo "Prova del model"
   echo -e "\t'model': '${MODEL}'",
   echo -e "\t'content': 'Hola, ¿cómo estás?'\n"
   curl http://localhost:8080/v1/chat/completions \
     -H "Content-Type: application/json" \
     -d '{"model": "phi2",
          "messages": [{"role": "user", "content": "Hola, ¿cómo estás?"}]
         }'
}

function menu() {
   echo -e "\n+--------------------------------------+"
   echo "|                 MENÚ                 |"
   echo "+--------------------------------------+"
   echo "| 0. Sortir                            |"
   echo "| 1. (run) Activa el servidor Docker   |"
   echo "| 2. (exec) Executa el model en Docker |"
   echo "| 3. Mostra els models                 |"
   echo "| 4. Prova del model                   |"
   echo "| 5. Elimina contenidor 'local-ai'     |"
   echo "| 6. Descàrrega de models              |"
   echo "+--------------------------------------+"
   read -p "Selecciona una opció: " -n1 -r opcio
   echo
   case ${opcio} in
      [1]) activa_servidor;;
      [2]) executa; menu;;
      [3]) mostra_models; menu;;
      [4]) prova_model; menu;;
      [5]) elimina_contenidor; menu;;
      [6]) echo https://huggingface.co/models; menu;;
   esac
   echo
}
MODEL=llama-2-7b-chat.Q4_K_M
menu
