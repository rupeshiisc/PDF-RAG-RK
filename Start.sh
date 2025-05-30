#!/bin/bash

# Start Ollama in background
nohup ollama serve > ollama.log 2>&1 &

# Wait until Ollama is ready
echo "Waiting for Ollama to start..."
until curl -s http://localhost:11434/api/tags > /dev/null; do
  sleep 2
done

# Pull required models
ollama pull nomic-embed-text
ollama pull llama2
ollama pull mistral
ollama pull tinyllama

# Run Streamlit app
/home/user/.local/bin/streamlit run app.py --server.port=8501 --server.address=0.0.0.0
