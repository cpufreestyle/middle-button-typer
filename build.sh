#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Compiling MiddleButtonTyper..."
swiftc main.swift -o MiddleButtonTyper

echo "Build complete: $(pwd)/MiddleButtonTyper"
