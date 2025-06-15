#!/bin/bash

# Copy docs from parent directory
echo "Copying docs..."
cp -R ../docs/ ./assets/docs

# Generate docs registry
echo "Generating docs registry..."
node scripts/generate-docs-registry.js

echo "Prebuild complete!"