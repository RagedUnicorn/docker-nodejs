# docker-nodejs

[![Release Build](https://github.com/ragedunicorn/docker-nodejs/actions/workflows/docker_release.yml/badge.svg)](https://github.com/ragedunicorn/docker-nodejs/actions/workflows/docker_release.yml)
[![Test](https://github.com/ragedunicorn/docker-nodejs/actions/workflows/test.yml/badge.svg)](https://github.com/ragedunicorn/docker-nodejs/actions/workflows/test.yml)
![License: MIT](docs/license_badge.svg)

> Docker Alpine image with Node.js and npm.

![](./docs/alpine_linux_logo.svg)

## Overview

This Docker image provides a minimal Node.js installation built on Alpine Linux. It ships Alpine's Node.js LTS package together with npm, both pinned to exact package versions so image builds stay reproducible.

## Features

- **Small footprint**: compact runtime image using Alpine Linux
- **Node.js 24 LTS**: pinned Alpine package (`24.17.0-r0`)
- **npm included**: pinned separately (`11.12.1-r0`)
- **Non-root user**: Enhanced security with dedicated node user
- **Volume mounting**: Easy code and data access through `/app`

## Quick Start

```bash
# Pull the image
docker pull ragedunicorn/nodejs:latest

# Run Node.js interactively (REPL)
docker run -it --rm ragedunicorn/nodejs:latest
```

For development and building from source, see [DEVELOPMENT.md](DEVELOPMENT.md).

## Usage

The container uses Node.js as the entrypoint, so any Node.js parameters can be passed directly to the `docker run` command.

### Basic Usage

**Linux/macOS:**
```bash
# Using latest version
docker run -v $(pwd):/app ragedunicorn/nodejs:latest [node-options]

# Using specific Node.js version (latest Alpine build)
docker run -v $(pwd):/app ragedunicorn/nodejs:24 [node-options]

# Using exact version combination
docker run -v $(pwd):/app ragedunicorn/nodejs:24-alpine3.24.1-1 [node-options]
```

**Windows (PowerShell):**
```powershell
# Using latest version
docker run -v ${PWD}:/app ragedunicorn/nodejs:latest [node-options]
```

### Examples

#### Run Node.js Script
```bash
docker run -v $(pwd):/app ragedunicorn/nodejs:latest script.js
```

#### Interactive Node.js Shell (REPL)
```bash
docker run -it --rm ragedunicorn/nodejs:latest
```

#### Execute JavaScript Code
```bash
docker run --rm ragedunicorn/nodejs:latest -e "console.log('Hello, World!')"
```

#### Install Packages and Run
```bash
docker run -v $(pwd):/app ragedunicorn/nodejs:latest /bin/sh -c "npm install && node script.js"
```

#### Check Node.js Version
```bash
docker run --rm ragedunicorn/nodejs:latest --version
```

#### Check npm Version
```bash
docker run --rm --entrypoint npm ragedunicorn/nodejs:latest --version
```

#### Run Tests
```bash
docker run -v $(pwd):/app ragedunicorn/nodejs:latest /bin/sh -c "npm install && npm test"
```

## Docker Compose Usage

This repository includes Docker Compose configurations for easier usage and common Node.js development workflows.

### Basic Setup

1. Create an `app` directory:
```bash
mkdir -p app
```

2. Place your JavaScript files in `app/`

3. Run Node.js using docker compose:
```bash
docker compose run --rm nodejs script.js
```

### Example Configuration

The `examples/` directory contains a hello-world example:

#### Hello World Example (`examples/docker-compose.yml`)
```bash
# Run the hello world example
cd examples && docker compose run --rm hello-world
```

### Environment Variables

The compose configuration supports:

- `NODEJS_VERSION`: Specify Node.js image version (default: latest)
- `TERM`: Terminal type for colored output

### Tips

1. **Custom Commands**: Override the default command:
   ```bash
   docker compose run --rm nodejs -e "console.log(process.version)"
   ```

2. **Development Mode**: Use the development compose file for building locally:
   ```bash
   docker compose -f docker-compose.dev.yml build
   docker compose -f docker-compose.dev.yml run --rm nodejs-dev
   ```

3. **Persistent Settings**: The repository includes a `.env` file with default settings:
   ```env
   NODEJS_VERSION=latest
   ```

## Building Custom Images

To create a custom image with your required packages:

```dockerfile
FROM ragedunicorn/nodejs:latest

# Install global packages
USER root
RUN npm install -g typescript
USER node

# Copy your application
WORKDIR /app
COPY --chown=node:node . .

RUN npm install

CMD ["app.js"]
```

## Versioning

This project uses semantic versioning that matches the Docker image contents:

**Format:** `{nodejs_major_version}-alpine{alpine_version}-{build_number}`

Examples:
- `24-alpine3.24.1-1` - Node.js 24 on Alpine 3.24.1, build 1
- `latest` - Most recent stable release

For detailed release process and versioning guidelines, see [RELEASE.md](RELEASE.md).

## Automated Dependency Updates

This project uses [Renovate](https://docs.renovatebot.com/) to automatically check for updates to:
- Alpine Linux base image version (all major, minor, and patch updates)
- The pinned Node.js and npm Alpine package versions

Renovate runs weekly (every Monday) and creates pull requests when updates are available. Every Alpine reference is kept in sync from a single update: the `FROM` line, the `org.opencontainers.image.base.name` OCI label, and the Alpine version asserted in `test/nodejs_metadata_test.yml` are grouped into one pull request. The Node.js and npm package pins are likewise grouped together, and their minor/patch updates merge automatically once tests pass — superseded pins vanish from the Alpine package index and would otherwise break the build.

## Documentation

- [Development Guide](DEVELOPMENT.md) - Building, debugging, and contributing
- [Testing Guide](TEST.md) - Running and writing tests
- [Release Process](RELEASE.md) - Creating releases and versioning

## Links

- [Node.js Documentation](https://nodejs.org/en/docs)
- [Alpine Linux](https://www.alpinelinux.org/)

# License

MIT License

Copyright (c) 2026 Michael Wiesendanger

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
