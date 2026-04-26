#!/bin/bash

# Descargar modelo pequeño
function descarrega_model() {
   mkdir -p /media/influencer/localai-models
   cd /media/influencer/localai-models
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
function atura_servidor() {
   docker stop local-ai
}

# Activar el servidor
function activa_servidor() {
   elimina_contenidor
   # -it interactiu
   # -d background
   echo "docker run -p 8080:8080 -d --name local-ai -v /media/influencer/localai-models:/build/models localai/localai:latest-cpu"
   docker run -p 8080:8080 -d --name local-ai -v /media/influencer/localai-models:/build/models localai/localai:latest-cpu
}

function activa_backend() {
   #ejecuta node server.js en una nueva terminal
   mate-terminal -e 'bash -c "node server.js && bash"'
}

function mostra_models() {
   echo "Llista de models"
   models=$(curl http://localhost:8080/v1/models)
   #echo $models
   get_json $models "id"
   echo
}

function get_token_value() {
   json=$1
   token=$2
   t=${1%%\"*}                # elimina la part posterior a la primera aparició de l'expressió (\"*)
   if [ $t == $token ]; then
      j2=${json#"$t"\":}      # elimina la part anterior a la primera aparició de l'expressió ($t\":)
      if [ ${j2:0:1} == '"' ]; then
         j2=${j2#\"}
         echo ${j2%%\"*}
      fi
   fi
}
function get_json() {
   json='{"object":"list","data":[{"id":"llama27b","object":"model"},{"id":"llama-3.2-1b-instruct-q4_k_m.gguf","object":"model"},{"id":"models_phi2_yaml","object":"model"},{"id":"models_tinyllama_yaml","object":"model"},{"id":"phi-2.Q4_K_M.gguf","object":"model"},{"id":"tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf","object":"model"}]}'
   token="id"
   json=$1
   token=$2
   nl=0
   na=0
   #for i in $(seq 0 $(expr length "${json}")); do
   for i in $(seq 0 $((${#json} - 1))); do
      char="${json:$i:1}"
      if [ "${char}" == "{" ]; then   ((nl++))
      elif [ "${char}" == "}" ]; then ((nl--))
      elif [ "${char}" == "[" ]; then ((na++))
      elif [ "${char}" == "]" ]; then ((na--))
      else
         if [ "${char}" == "\"" ]; then
            t=$(get_token_value ${json:(($i + 1))} $token)
            [ $t ] && echo "   $t" || true
         fi
      fi
   done
}

function prova_model() {
   echo "Prova del model"
   echo -e "   'model': '${MODEL}'",
   echo -e "   'content': 'Hola, ¿cómo estás?'\n"

   curl http://localhost:8080/v1/chat/completions \
     -H "Content-Type: application/json" \
     -d "{\"model\": \"${MODEL}\",
          \"messages\": [{\"role\":\"user\", \"content\":\"Hola, ¿cómo estás?\"}]
         }"
   echo
}

function menu() {
   echo "+--------------------------------------+"
   echo "|                 MENÚ                 |"
   echo "+--------------------------------------+"
   echo "| 0. Sortir                            |"
   echo "| 1. (run) Activa el servidor Docker   |"
   echo "| 2. (node) Activa el backend          |"
   echo "| 3. (stop) Atura el servidor Docker   |"
   echo "|                                      |"
   echo "| 4. Mostra els models                 |"
   echo "| 5. Prova del model                   |"
   echo "| 6. Elimina contenidor 'local-ai'     |"
   echo "| 7. Web de descàrrega de models       |"
   echo "+--------------------------------------+"
   read -p "Selecciona una opció: " -n1 -r opcio
   echo
   case ${opcio} in
      [1]) activa_servidor; menu;;
      [2]) activa_backend; menu;;
      [3]) atura_servidor; menu;;
      [4]) mostra_models; menu;;
      [5]) prova_model; menu;;
      [6]) elimina_contenidor; menu;;
      [7]) echo https://huggingface.co/models; menu;;
   esac
   echo
}

MODEL=llama2-7b
menu
