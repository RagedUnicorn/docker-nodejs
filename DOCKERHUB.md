# Node.js Alpine Docker Image

![Docker Node.js](https://raw.githubusercontent.com/RagedUnicorn/docker-nodejs/master/docs/docker_nodejs_banner.png)

A minimal Node.js image on Alpine Linux, shipping Alpine's Node.js LTS package and npm pinned to exact versions.

## Quick Start

```bash
# Pull latest version
docker pull ragedunicorn/nodejs:latest

# Or pull specific version
docker pull ragedunicorn/nodejs:24-alpine3.24.1-1

# Run Node.js interactively (REPL)
docker run -it --rm ragedunicorn/nodejs:latest

# Run a Node.js script
docker run -v $(pwd):/app ragedunicorn/nodejs:latest script.js
```

## Features

- 🚀 **Small footprint**: compact runtime image built on Alpine Linux
- 🟢 **Node.js LTS**: pinned Alpine package, reproducible builds
- 📦 **npm included**: separately pinned npm for package management
- 🔒 **Security**: non-root user, minimal attack surface
- 🏗️ **Multi-platform**: supports linux/amd64 and linux/arm64
- 🎯 **Customizable**: install only what you need

## Usage Examples

### Run a Node.js script
```bash
docker run -v $(pwd):/app ragedunicorn/nodejs:latest script.js
```

### Interactive Node.js shell (REPL)
```bash
docker run -it --rm ragedunicorn/nodejs:latest
```

### Execute JavaScript code
```bash
docker run --rm ragedunicorn/nodejs:latest -e "console.log('Hello, World!')"
```

### Install packages and run commands
```bash
# Install dependencies and run a script
docker run -v $(pwd):/app ragedunicorn/nodejs:latest /bin/sh -c "npm install && node script.js"

# Install and run the project test suite
docker run -v $(pwd):/app ragedunicorn/nodejs:latest /bin/sh -c "npm install && npm test"
```

### Build a custom image
```dockerfile
FROM ragedunicorn/nodejs:latest

# Install additional global packages
USER root
RUN npm install -g typescript
USER node

# Your custom configuration
WORKDIR /app
COPY --chown=node:node . .
RUN npm install
CMD ["app.js"]
```

## Tags

This image uses semantic versioning that includes all component versions:

**Format:** `{nodejs_major_version}-alpine{alpine_version}-{build_number}`

### Version Examples

- `24-alpine3.24.1-1` - Initial release with Node.js 24 and Alpine 3.24.1
- `24-alpine3.24.1-2` - Rebuild of same versions (bug fixes, security patches)
- `24-alpine3.24.2-1` - Alpine Linux patch update
- `latest` - Most recent stable release

The pinned Node.js and npm package versions are fixed per release and tracked by automated dependency management. When updates are available, new releases are created with appropriate version tags.

## Working Directory

The default working directory is `/app`. Mount your code here:

```bash
docker run -v $(pwd):/app ragedunicorn/nodejs:latest your_script.js
```

## Links

- **GitHub**: [https://github.com/ragedunicorn/docker-nodejs](https://github.com/ragedunicorn/docker-nodejs)
- **Issues**: [https://github.com/ragedunicorn/docker-nodejs/issues](https://github.com/ragedunicorn/docker-nodejs/issues)
- **Releases**: [https://github.com/ragedunicorn/docker-nodejs/releases](https://github.com/ragedunicorn/docker-nodejs/releases)

## License

MIT License - See [GitHub repository](https://github.com/ragedunicorn/docker-nodejs) for details.
