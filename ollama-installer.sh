#!/bin/sh

# Function to repeat a command until it succeeds
repeat_until_success() {
  while true; do
    "$@" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "Success: $*"
      break
    else
      echo "Retrying: $*"
      sleep 2
    fi
  done
}

echo "Installing dependencies..."
repeat_until_success apt install git golang python cmake clang -y

echo "Cloning repository..."
repeat_until_success git clone https://github.com/ollama/ollama.git

cd ollama || { echo "Failed to change directory"; exit 1; }

echo "Generating Go code..."
eval $(go env)
go generate ./... > /dev/null 2>&1

echo "Building ollama..."
repeat_until_success go build .

echo "Copying ollama binary to PATH..."
repeat_until_success cp ollama  $PREFIX/bin

echo "Cleaning up..."
cd ~ || exit
repeat_until_success chmod -R 777 go
repeat_until_success rm -rf go
repeat_until_success rm -rf ollama

echo "ollama installed successfully."
