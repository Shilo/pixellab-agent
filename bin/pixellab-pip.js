#!/usr/bin/env node

const fs = require("fs");
const os = require("os");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..");
const sourceSkill = path.join(repoRoot, "pixellab-pip");

function usage() {
  console.log(`PixelLab Pip installer

Usage:
  pixellab-pip install [--target auto|codex|claude|cursor] [--scope project|user] [--no-alias]

Defaults:
  --target auto
  --scope project

Installs only the runtime skill payload:
  pixellab-pip/SKILL.md
  pixellab-pip/references/

By default it also installs a /pip alias by copying the same payload to a sibling pip skill folder.`);
}

function parseArgs(argv) {
  const args = {
    command: argv[2],
    target: "auto",
    scope: "project",
    alias: true
  };

  if (args.command === "-h" || args.command === "--help") {
    args.command = "help";
  }

  for (let i = 3; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--target") args.target = argv[++i];
    else if (arg.startsWith("--target=")) args.target = arg.slice("--target=".length);
    else if (arg === "--scope") args.scope = argv[++i];
    else if (arg.startsWith("--scope=")) args.scope = arg.slice("--scope=".length);
    else if (arg === "--no-alias") args.alias = false;
    else if (arg === "-h" || arg === "--help") args.command = "help";
    else throw new Error(`Unknown argument: ${arg}`);
  }

  return args;
}

function targetRoot(target, scope) {
  const home = os.homedir();
  if (!home) throw new Error("Could not resolve home directory.");

  if (!["auto", "codex", "claude", "cursor"].includes(target)) {
    throw new Error(`Unsupported target: ${target}`);
  }
  if (!["project", "user"].includes(scope)) {
    throw new Error(`Unsupported scope: ${scope}`);
  }

  if (scope === "user") {
    if (target === "claude") return path.join(home, ".claude", "skills");
    if (target === "cursor") return path.join(home, ".cursor", "skills");
    return path.join(home, ".agents", "skills");
  }

  if (target === "claude") return path.resolve(".claude", "skills");
  if (target === "cursor") return path.resolve(".cursor", "skills");
  return path.resolve(".agents", "skills");
}

function removeExistingRuntime(target) {
  const resolved = path.resolve(target);
  if (!resolved.endsWith(`${path.sep}pixellab-pip`) && !resolved.endsWith(`${path.sep}pip`)) {
    throw new Error(`Refusing to replace unexpected target: ${resolved}`);
  }
  fs.rmSync(resolved, { recursive: true, force: true });
}

function copyRuntime(target) {
  fs.mkdirSync(target, { recursive: true });
  fs.copyFileSync(path.join(sourceSkill, "SKILL.md"), path.join(target, "SKILL.md"));
  fs.cpSync(path.join(sourceSkill, "references"), path.join(target, "references"), {
    recursive: true,
    force: true
  });
}

function install(args) {
  if (!fs.existsSync(path.join(sourceSkill, "SKILL.md"))) {
    throw new Error(`Missing runtime skill: ${path.join(sourceSkill, "SKILL.md")}`);
  }

  const root = targetRoot(args.target, args.scope);
  fs.mkdirSync(root, { recursive: true });

  const primary = path.join(root, "pixellab-pip");
  removeExistingRuntime(primary);
  copyRuntime(primary);

  const installed = [primary];
  if (args.alias) {
    const alias = path.join(root, "pip");
    removeExistingRuntime(alias);
    copyRuntime(alias);
    installed.push(alias);
  }

  console.log("Installed PixelLab Pip:");
  for (const folder of installed) console.log(`  ${folder}`);
  console.log("");
  console.log("Commands:");
  console.log("  /pixellab-pip");
  if (args.alias) console.log("  /pip");
}

try {
  const args = parseArgs(process.argv);
  if (!args.command || args.command === "help") {
    usage();
  } else if (args.command === "install") {
    install(args);
  } else {
    throw new Error(`Unknown command: ${args.command}`);
  }
} catch (error) {
  console.error(`pixellab-pip: ${error.message}`);
  process.exit(1);
}
