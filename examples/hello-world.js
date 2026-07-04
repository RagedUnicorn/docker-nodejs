#!/usr/bin/env node
// A simple hello world example.

const os = require('os');

function main() {
  console.log('Hello, World from Docker Node.js!');
  console.log(`Node.js version: ${process.version}`);
  console.log(`Platform: ${os.platform()} ${os.release()}`);
}

main();
