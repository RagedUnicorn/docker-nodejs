# Testing Guide

This document describes how to test the Node.js Docker image using Container Structure Tests.

## Quick Start

```bash
# Run all tests
docker compose -f docker-compose.test.yml run test-all

# Run individual test suites
docker compose -f docker-compose.test.yml up container-test          # File structure tests
docker compose -f docker-compose.test.yml up container-test-command  # Command execution tests
docker compose -f docker-compose.test.yml up container-test-metadata # Metadata validation tests
```

## Test Structure

The test suite consists of three main test files:

### 1. File Structure Tests (`test/nodejs_test.yml`)

Validates:

- Node.js binary exists with correct permissions
- npm command and its module tree exist
- Working directory `/app` exists and is accessible
- SSL certificates are present for npm functionality

### 2. Command Execution Tests (`test/nodejs_command_test.yml`)

Validates:

- Node.js and npm version outputs
- Basic JavaScript code execution
- Built-in module usage (process, os, JSON)
- Script execution capability
- Non-root user functionality
- Working directory configuration

### 3. Metadata Tests (`test/nodejs_metadata_test.yml`)

Validates:

- OCI-compliant labels are present and correct
- Container entrypoint and default command
- Working directory configuration
- User context (runs as non-root node user)

## Running Tests

### Prerequisites

1. Docker must be installed and running
2. Build the Node.js image locally before testing

### Important: Always Test Local Builds

**⚠️ Always build and test locally to ensure consistency:**

```bash
# Build the image locally with a test tag
docker build -t ragedunicorn/nodejs:test .
```

**Linux/macOS:**

```bash
# Run tests against your local build
NODEJS_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

**Windows (PowerShell):**

```powershell
# Run tests against your local build
$env:NODEJS_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

**Windows (Command Prompt):**

```cmd
# Run tests against your local build
set NODEJS_VERSION=test && docker compose -f docker-compose.test.yml run test-all
```

**Why local testing is important:**
- Remote images (Docker Hub, GHCR) may have different labels due to CI/CD overrides
- Ensures you're testing exactly what you built
- Avoids false positives/negatives from version mismatches
- Guarantees consistent test results

**Never pull remote images for testing:**

**❌ DON'T DO THIS - may have different labels/settings:**

```bash
docker pull ragedunicorn/nodejs:latest
docker compose -f docker-compose.test.yml run test-all
```

**✅ DO THIS - test your local build:**

Linux/macOS:

```bash
docker build -t ragedunicorn/nodejs:test .
NODEJS_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

Windows (PowerShell):

```powershell
docker build -t ragedunicorn/nodejs:test .
$env:NODEJS_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

### Test Execution

Run all tests against your local build:

**Linux/macOS:**

```bash
# Ensure you've built locally first!
NODEJS_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

**Windows (PowerShell):**

```powershell
# Ensure you've built locally first!
$env:NODEJS_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

**Windows (Command Prompt):**

```cmd
# Ensure you've built locally first!
set NODEJS_VERSION=test && docker compose -f docker-compose.test.yml run test-all
```

Run specific test categories:

**Linux/macOS:**

```bash
# File structure tests
NODEJS_VERSION=test docker compose -f docker-compose.test.yml up container-test

# Command execution and functionality tests
NODEJS_VERSION=test docker compose -f docker-compose.test.yml up container-test-command

# Metadata and label tests
NODEJS_VERSION=test docker compose -f docker-compose.test.yml up container-test-metadata
```

**Windows (PowerShell):**

```powershell
# File structure tests
$env:NODEJS_VERSION="test"; docker compose -f docker-compose.test.yml up container-test

# Command execution and functionality tests
$env:NODEJS_VERSION="test"; docker compose -f docker-compose.test.yml up container-test-command

# Metadata and label tests
$env:NODEJS_VERSION="test"; docker compose -f docker-compose.test.yml up container-test-metadata
```

### Testing Different Versions

When testing different versions, always build locally first:

```bash
# Build a specific version locally
docker build -t ragedunicorn/nodejs:24-alpine3.24.1-1 .
```

**Linux/macOS:**

```bash
# Test that specific version
NODEJS_VERSION=24-alpine3.24.1-1 docker compose -f docker-compose.test.yml run test-all
```

**Windows (PowerShell):**

```powershell
# Test that specific version
$env:NODEJS_VERSION="24-alpine3.24.1-1"; docker compose -f docker-compose.test.yml run test-all
```

## Troubleshooting Test Failures

### Node.js Version Mismatches

Node.js and npm are pinned Alpine packages. When the pinned `NODEJS_VERSION` changes major (e.g. 24 → 26), the expected output in `test/nodejs_command_test.yml` (`v24`) must be updated to match; the same applies to the npm major (`11.`).

To find the current versions in the image:

```bash
docker run --rm --entrypoint sh ragedunicorn/nodejs:test -c "node --version && npm --version"
```

### Binary Layout

`node` is a regular binary at `/usr/bin/node`; `npm` is a symlink into the npm module tree at `/usr/lib/node_modules/npm`. The file existence test asserts permissions for `node` but existence only for `npm` (symlinks don't carry their own permission mode):

```bash
# Inspect the binaries
docker run --rm --entrypoint sh ragedunicorn/nodejs:test -c "ls -la /usr/bin/node /usr/bin/npm"
```

### Metadata Test Failures

**Common causes:**

1. **Testing remote images instead of local builds**
   - Remote images (Docker Hub, GHCR) have labels overridden by CI/CD
   - Always test your local builds with `NODEJS_VERSION=test`

2. **Label value mismatches**
   - CI/CD systems may capitalize values (e.g., "RagedUnicorn" vs "ragedunicorn")
   - GitHub Actions may override labels during build
   - Docker Hub automated builds may set different values

3. **Version-specific labels**
   - The `org.opencontainers.image.version` label changes with each build
   - Build date labels are dynamic

**Solution:** Always build and test locally before pushing:

```bash
docker build -t ragedunicorn/nodejs:test .
```

Linux/macOS:

```bash
NODEJS_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

Windows (PowerShell):

```powershell
$env:NODEJS_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

### Permission Errors

If you encounter Docker socket permission errors:

```bash
sudo docker compose -f docker-compose.test.yml run test-all
```

Or ensure your user is in the `docker` group:

```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

## Writing New Tests

To add new tests, follow the Container Structure Test schema:

1. **File tests**: Add to `test/nodejs_test.yml`
2. **Command tests**: Add to `test/nodejs_command_test.yml`
3. **Metadata tests**: Add to `test/nodejs_metadata_test.yml`

Example of adding a new package test:

```yaml
- name: 'Check npm package installation'
  command: 'npm'
  args: ['install', 'axios']
  exitCode: 0
```

## CI/CD Integration

These tests are automatically run in GitHub Actions:

- **On every push** to master branches
- **On every pull request** to master branches
- **Before releases** to ensure quality

The test workflow (`.github/workflows/test.yml`):
1. Builds the Docker image
2. Runs all Container Structure Tests
3. Verifies basic Node.js functionality
4. Blocks releases if tests fail

Manual integration example:

```yaml
- name: Run Container Structure Tests
  env:
    NODEJS_VERSION: test
  run: docker compose -f docker-compose.test.yml run test-all
```

The `test-all` service returns:
- Exit code 0: All tests passed
- Exit code 1: One or more tests failed

## Test Maintenance

When updating the Docker image:

1. **Node.js version updates**: A major bump (24 → 26) requires updating the expected `v24` output in `nodejs_command_test.yml`; minor and patch bumps need no test changes
2. **Alpine version updates**: Renovate keeps the `base.name` label and `nodejs_metadata_test.yml` in sync with the `FROM` version, so no manual edit is needed for the drift to resolve
3. **New functionality**: Add corresponding tests to verify behavior
4. **Label changes**: Update metadata tests to match new labels

Always run the full test suite before creating a release.
