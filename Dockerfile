# Base image with Python
FROM python:3.10-slim

RUN pip install --upgrade pip

# System-level dependencies
RUN apt-get update && apt-get install -y \
    curl git build-essential software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Ollama (replace with the latest stable version if needed)
# Check ollama.com for the latest install script if this one is outdated
RUN curl -fsSL https://ollama.com/install.sh | sh

# Set up user for security (Hugging Face Spaces often run as user `user`)
RUN useradd -m -u 1000 user
USER user
WORKDIR /home/user

# Set environment variables
ENV OLLAMA_MODELS=/home/user/models
ENV PATH="/home/user/.local/bin:$PATH" 
 

# Install Python dependencies
COPY --chown=user:user requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your application code
COPY --chown=user:user . .

# *** Pull Ollama Models (This is where your equivalent commands go) ***
# The `ollama serve` command must be running in the background for `ollama pull` to work.
# We'll use a trick with a shell script for this.

# Create a startup script
# Copy entrypoint script
COPY --chown=user:user start.sh .
RUN chmod +x start.sh

# Expose Streamlit and Ollama ports
EXPOSE 8501
EXPOSE 11434

# Healthcheck for Hugging Face Spaces
HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health || exit 1

# Start both Ollama and Streamlit via the script
ENTRYPOINT ["./start.sh"]
