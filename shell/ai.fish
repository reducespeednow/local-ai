# Load from ~/.config/fish/config.fish with:
#   test -f ~/local-ai/shell/ai.fish; and source ~/local-ai/shell/ai.fish

# Repo location; override by setting LOCAL_AI_DIR before sourcing this file
set -q LOCAL_AI_DIR; or set -g LOCAL_AI_DIR ~/local-ai

function __ai_compose
    docker compose --project-directory $LOCAL_AI_DIR -f $LOCAL_AI_DIR/compose.yaml $argv
end

function ai-up --description "Start the model server"
    __ai_compose up -d llama
    and echo "Model loading... follow with ai-logs. Chat at http://127.0.0.1:"(string match -r '^LLAMA_PORT=(\d+)' < $LOCAL_AI_DIR/.env)[2]
end

function ai-down --description "Stop everything and free the memory"
    __ai_compose --profile webui down
end

function ai-logs --description "Follow the model server log"
    __ai_compose logs -f llama
end

function ai-status --description "Containers, RAM, swap and GPU memory"
    __ai_compose --profile webui ps
    echo
    free -h
    echo
    for f in /sys/class/drm/card*/device/mem_info_gtt_used
        printf "GPU borrowed (GTT): %s\n" (numfmt --to=iec (cat $f))
    end
end

function ai-perf --description "Speed of the most recent requests"
    docker logs llama 2>&1 | grep -E "prompt eval time|eval time|total time" | tail -n 12
end

function ai-bench --description "Raw speed benchmark (server must be stopped)"
    $LOCAL_AI_DIR/scripts/bench.sh
end
