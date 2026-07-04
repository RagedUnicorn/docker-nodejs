# Node.js Docker Examples

This directory contains a simple example to get you started with the Node.js Docker image.

## Hello World Example

The `hello-world.js` script demonstrates basic Node.js functionality in the Docker container.

### Running the Example

#### Using Docker Compose (recommended)

```bash
# From the examples directory
docker-compose run --rm hello-world

# Or run interactively (REPL)
docker-compose run --rm nodejs-shell

# Run any JavaScript file
docker-compose run --rm nodejs your-script.js
```

#### Using Docker directly

**Linux/macOS:**
```bash
# From the repository root
docker run -v $(pwd)/examples:/app ragedunicorn/nodejs:latest hello-world.js
```

**Windows (PowerShell):**
```powershell
# From the repository root
docker run -v ${PWD}/examples:/app ragedunicorn/nodejs:latest hello-world.js
```

### Expected Output

```
Hello, World from Docker Node.js!
Node.js version: v24.x.x
Platform: linux 6.x.x-...
```

## Creating Your Own Script

1. Create a JavaScript file:

```javascript
// my-script.js
console.log('Hello from my custom script!');
```

2. Run it with Docker:

```bash
docker run -v $(pwd):/app ragedunicorn/nodejs:latest my-script.js
```

## Installing Additional Packages

If your script needs additional packages:

```bash
# Install and run in one command
docker run -v $(pwd):/app ragedunicorn/nodejs:latest /bin/sh -c "npm install axios && node my-script.js"
```

Or create a custom Dockerfile:

```dockerfile
FROM ragedunicorn/nodejs:latest

WORKDIR /app
COPY --chown=node:node . .

RUN npm install

CMD ["my-script.js"]
```
