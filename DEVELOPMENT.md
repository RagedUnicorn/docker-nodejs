# Development Guide

This document provides information for developers working on the Node.js Docker image.

## Development Environment

### Prerequisites

- Docker installed and running
- Docker Compose installed
- Git for version control
- Text editor or IDE

### Project Structure

```
docker-nodejs/
├── Dockerfile              # Main image definition
├── docker-compose.yml      # Basic usage configuration
├── docker-compose.dev.yml  # Development environment
├── docker-compose.test.yml # Test orchestration
├── .env                    # Default environment variables
├── examples/               # Example Docker Compose configurations
│   └── docker-compose.yml  # Hello world example
├── test/                   # Container Structure Tests
│   ├── nodejs_test.yml
│   ├── nodejs_command_test.yml
│   └── nodejs_metadata_test.yml
└── docs/                   # Documentation assets
```

## Development Workflow

### 1. Local Development Mode

The `docker-compose.dev.yml` file provides an interactive development environment:

```bash
# Build the image locally
docker compose -f docker-compose.dev.yml build

# Run in development mode (interactive shell)
docker compose -f docker-compose.dev.yml run --rm nodejs-dev

# Inside the container, you can run Node.js manually
node --version
node -e "console.log('Hello from dev!')"
```

The development mode:

- Mounts the current directory to `/app` for testing files
- Uses interactive mode with STDIN open and TTY allocated
- Overrides the entrypoint with a shell for direct access to node and npm

### 2. Building the Image

```bash
# Basic build
docker build -t ragedunicorn/nodejs:dev .

# Build with specific versions
docker build \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VERSION=24-alpine3.24.1-1 \
  -t ragedunicorn/nodejs:24-alpine3.24.1-1 .

# Multi-platform build (requires buildx)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ragedunicorn/nodejs:dev .
```

### 3. Testing Your Changes

After making changes, always build and test locally:

```bash
# Build your changes locally
docker build -t ragedunicorn/nodejs:test .
```

#### Running Tests (Cross-Platform)

**Linux/macOS:**

```bash
# Run all tests against your local build
NODEJS_VERSION=test docker compose -f docker-compose.test.yml run test-all

# Run specific tests during development
NODEJS_VERSION=test docker compose -f docker-compose.test.yml up container-test-command
```

**Windows Command Prompt:**

```cmd
# Run all tests against your local build
set NODEJS_VERSION=test && docker compose -f docker-compose.test.yml run test-all

# Run specific tests during development
set NODEJS_VERSION=test && docker compose -f docker-compose.test.yml up container-test-command
```

**Windows PowerShell:**

```powershell
# Run all tests against your local build
$env:NODEJS_VERSION="test"; docker compose -f docker-compose.test.yml run test-all

# Run specific tests during development
$env:NODEJS_VERSION="test"; docker compose -f docker-compose.test.yml up container-test-command
```

**Important:** Never test against remote images - they may have different labels or configurations due to CI/CD overrides.

See [TEST.md](TEST.md) for detailed testing information.

## Making Changes

### Version Updates

This project uses [Renovate](https://docs.renovatebot.com/) to automatically manage dependency updates:

- **Alpine Linux**: Renovate monitors Docker Hub and creates PRs for new Alpine versions. Every Alpine reference is kept in sync from a single grouped PR — the `FROM` line (Renovate's built-in dockerfile manager), the `org.opencontainers.image.base.name` OCI label, and the Alpine version asserted in `test/nodejs_metadata_test.yml` (both via regex `customManagers` in `renovate.json`).
- **Node.js / npm**: Both are pinned to exact Alpine package versions via the `NODEJS_VERSION` and `NPM_VERSION` build args, tracked through the `# renovate:` comments above their `ARG` lines (Repology datasource) and grouped into one PR. Minor and patch updates merge automatically once tests pass: superseded pins vanish from the Alpine package index and would otherwise break the image build.

When Renovate creates a PR:

1. Review the changes in the PR
2. Check the CI/CD pipeline passes all tests
3. Test the build locally if it's a major version update
4. Merge the PR if everything looks good

Manual version updates are rarely needed. If you must update manually:

```dockerfile
# renovate: datasource=repology depName=alpine_3_24/nodejs versioning=loose
ARG NODEJS_VERSION=24.17.0-r0
# renovate: datasource=repology depName=alpine_3_24/npm versioning=loose
ARG NPM_VERSION=11.12.1-r0
```

When manually updating the Node.js or npm version:

1. Look up the current package versions for the Alpine branch on [pkgs.alpinelinux.org](https://pkgs.alpinelinux.org/)
2. Update `NODEJS_VERSION` / `NPM_VERSION` in the Dockerfile
3. Test the build thoroughly
4. Update the expected versions in `test/nodejs_command_test.yml` if the Node.js or npm major changed
5. Update version numbers in documentation

When the Alpine base moves to a new release branch (e.g. 3.24 → 3.25), the Repology package names embed the branch and must follow manually: update `alpine_3_24/nodejs` and `alpine_3_24/npm` in the two `# renovate:` comments to the new branch, and re-pin both versions to what that branch ships. The `FROM` line, `base.name` label, and metadata test are kept aligned by Renovate.

### Adding npm Packages

To add npm packages to the base image (discouraged - users should extend the image):

```dockerfile
# Add after npm is installed
RUN npm install -g your-new-package
```

System packages can be added with `apk` (the base is Alpine).

**Note:** This image is intentionally minimal. Users should extend it:

```dockerfile
FROM ragedunicorn/nodejs:latest
USER root
RUN npm install -g typescript
USER node
```

## Code Style and Best Practices

### Dockerfile Best Practices

1. **Minimal installation**: Only Node.js and npm included
2. **Layer optimization**: Group related commands to minimize layers
3. **Cache efficiency**: Order commands from least to most frequently changed
4. **Security**: Run as non-root user
5. **Labels**: Follow OCI naming conventions

### Documentation

1. **README.md**: Keep focused on user-facing information
2. **Comments**: Add comments in Dockerfile for complex operations
3. **Examples**: Provide working examples for new features
4. **Commit messages**: Use conventional format (feat:, fix:, docs:, etc.)

### Testing

1. **Test everything**: New features must include tests
2. **Test edge cases**: Include negative tests where appropriate
3. **Keep tests fast**: Avoid long-running operations in tests
4. **Test organization**: Group related tests together

## Debugging

### Common Issues

**Build failures:**

```bash
# Verbose build output
docker build --progress=plain --no-cache -t ragedunicorn/nodejs:debug .

# Check the pinned package versions still exist on the Alpine branch
docker run --rm alpine:3.24.1 sh -c "apk update >/dev/null && apk policy nodejs npm"
```

**Node.js not working:**

```bash
# Check Node.js installation
docker run --rm --entrypoint sh ragedunicorn/nodejs:dev -c "which node"
docker run --rm --entrypoint sh ragedunicorn/nodejs:dev -c "node --version"

# Check npm installation
docker run --rm --entrypoint sh ragedunicorn/nodejs:dev -c "npm --version"
```

**Package installation issues:**

```bash
# List globally installed npm packages
docker run --rm --entrypoint sh ragedunicorn/nodejs:dev -c "npm ls -g"

# Test package installation
docker run --rm --entrypoint sh ragedunicorn/nodejs:dev -c "npm install axios"
```

## Contributing

### Before Submitting Changes

1. Run the full test suite
2. Update documentation if needed
3. Add tests for new features
4. Ensure your code follows the existing style
5. Write clear commit messages

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes using conventional commits
4. Push to your fork
5. Open a Pull Request with a clear description

### Release Process

See [RELEASE.md](RELEASE.md) for information about creating releases.
