#!/bin/bash

# Copy docs from parent directory
echo "Copying docs..."
cp -R ../docs/ ./assets/docs

# Generate docs registry
echo "Generating docs registry..."
node scripts/generate-docs-registry.js

# Generate build info
echo "Generating build info..."
BUILD_TIMESTAMP=$(date -u +"%Y-%m-%d at %H:%M")
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

# Create build info file
cat > ./constants/buildInfo.ts << EOF
// Auto-generated build info - do not edit manually
export const BUILD_INFO = {
  gitCommit: '${GIT_COMMIT}',
  gitBranch: '${GIT_BRANCH}',
  buildTimestamp: '${BUILD_TIMESTAMP}',
  buildId: '${GIT_COMMIT} on ${BUILD_TIMESTAMP}'
} as const;
EOF

echo "Prebuild complete!"