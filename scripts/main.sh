#!/bin/bash
# DD-Workflow Main Script
# Usage: ./main.sh [init|apply] [repo_path] [dd_id] [slug] [description]

ACTION=$1
REPO_PATH=$2
DD_ID=$3
SLUG=$4
DESCRIPTION=$5

DESIGN_ROOT="/home/darling/.openclaw/workspace/design_docs"
REPO_NAME=$(basename "$REPO_PATH")
DESIGN_DIR="$DESIGN_ROOT/$REPO_NAME"

mkdir -p "$DESIGN_DIR"

WORKFLOW_ROOT=$(dirname $(dirname $(readlink -f $0)))
PROMPTS_DIR="$WORKFLOW_ROOT/prompts"

if [[ -z "$ACTION" || -z "$REPO_PATH" || -z "$DD_ID" || -z "$SLUG" ]]; then
    echo "Usage: $0 [init|apply] [repo_path] [dd_id] [slug] [description]"
    exit 1
fi

case $ACTION in
    init)
        if [[ -z "$DESCRIPTION" ]]; then
            echo "Error: 'init' action requires a description."
            exit 1
        fi
        
        TEMPLATE=$(cat "$PROMPTS_DIR/design.md")
        PROMPT=$(echo "$TEMPLATE" | sed "s|{{repo}}|$REPO_PATH|g" \
                                   | sed "s|{{design_dir}}|$DESIGN_DIR|g" \
                                   | sed "s|{{dd_id}}|$DD_ID|g" \
                                   | sed "s|{{slug}}|$SLUG|g" \
                                   | sed "s|{{description}}|$DESCRIPTION|g")
        
        echo "Spawning Claude for design..."
        openclaw subagents spawn --model momo/claude-opus-4-6 --message "$PROMPT" --label "dd-$DD_ID-design"
        ;;
        
    apply)
        TEMPLATE=$(cat "$PROMPTS_DIR/implement.md")
        PROMPT=$(echo "$TEMPLATE" | sed "s|{{repo}}|$REPO_PATH|g" \
                                   | sed "s|{{design_dir}}|$DESIGN_DIR|g" \
                                   | sed "s|{{dd_id}}|$DD_ID|g" \
                                   | sed "s|{{slug}}|$SLUG|g")
        
        echo "Spawning Codex for implementation..."
        openclaw subagents spawn --model momo-openai/gpt-5.3-codex --message "$PROMPT" --label "dd-$DD_ID-implement"
        ;;
        
    *)
        echo "Unknown action: $ACTION"
        exit 1
        ;;
esac
