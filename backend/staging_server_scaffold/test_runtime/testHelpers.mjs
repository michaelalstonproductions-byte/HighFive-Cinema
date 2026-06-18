import assert from "node:assert/strict";
import { afterEach } from "node:test";
import { createRequire } from "node:module";
import path from "node:path";
import { pathToFileURL } from "node:url";

export const outDir = "/private/tmp/highfive-phase-66-0a-staging-backend-contract-tests";
export const compiledRoot = process.env.HIGHFIVE_CONTRACT_TEST_COMPILED_ROOT ?? path.join(outDir, "compiled");

const guardKey = Symbol.for("highfive.stagingBackendContractTestGuards");

function installGuards() {
  const require = createRequire(import.meta.url);
  const state = {
    networkRequestsPerformed: false,
    envReadsAttempted: false,
    sensitiveLogViolations: [],
    capturedLogs: []
  };

  const blockNetwork = () => {
    state.networkRequestsPerformed = true;
    throw new Error("Network calls are disabled for staging backend local contract tests");
  };

  Object.defineProperty(globalThis, "fetch", {
    configurable: true,
    writable: true,
    value: blockNetwork
  });
  Object.defineProperty(globalThis, "WebSocket", {
    configurable: true,
    writable: true,
    value: class BlockedWebSocket {
      constructor() {
        return blockNetwork();
      }
    }
  });

  for (const moduleName of ["node:http", "node:https"]) {
    const module = require(moduleName);
    module.request = blockNetwork;
    module.get = blockNetwork;
  }
  for (const moduleName of ["node:net", "node:tls"]) {
    const module = require(moduleName);
    module.connect = blockNetwork;
    module.createConnection = blockNetwork;
  }

  const fs = require("node:fs");
  const originalReadFileSync = fs.readFileSync.bind(fs);
  const originalReadFile = fs.readFile.bind(fs);
  const originalPromisesReadFile = fs.promises.readFile.bind(fs.promises);
  const isRealEnvPath = (filePath) => {
    const basename = path.basename(String(filePath));
    return basename === ".env" || basename.endsWith(".env");
  };

  fs.readFileSync = (filePath, ...args) => {
    if (isRealEnvPath(filePath)) {
      state.envReadsAttempted = true;
      throw new Error("Real .env reads are disabled for staging backend local contract tests");
    }
    return originalReadFileSync(filePath, ...args);
  };
  fs.readFile = (filePath, ...args) => {
    if (isRealEnvPath(filePath)) {
      state.envReadsAttempted = true;
      const callback = args.at(-1);
      if (typeof callback === "function") {
        callback(new Error("Real .env reads are disabled for staging backend local contract tests"));
        return undefined;
      }
      throw new Error("Real .env reads are disabled for staging backend local contract tests");
    }
    return originalReadFile(filePath, ...args);
  };
  fs.promises.readFile = async (filePath, ...args) => {
    if (isRealEnvPath(filePath)) {
      state.envReadsAttempted = true;
      throw new Error("Real .env reads are disabled for staging backend local contract tests");
    }
    return originalPromisesReadFile(filePath, ...args);
  };

  const sensitiveLogPatterns = [
    /playback_url_or_token_reference/i,
    /MOCK_DESCRIPTOR_REFERENCE/i,
    /mock descriptor-reference/i
  ];
  const stringifyLogArg = (arg) => {
    if (typeof arg === "string") return arg;
    try {
      return JSON.stringify(arg);
    } catch {
      return String(arg);
    }
  };
  const interceptConsole = (method) => {
    console[method] = (...args) => {
      const rendered = args.map(stringifyLogArg).join(" ");
      state.capturedLogs.push({ method, rendered });
      if (sensitiveLogPatterns.some((pattern) => pattern.test(rendered))) {
        state.sensitiveLogViolations.push({ method, rendered });
      }
    };
  };
  for (const method of ["log", "info", "warn", "error"]) {
    interceptConsole(method);
  }

  return state;
}

export const guardState = globalThis[guardKey] ?? installGuards();
globalThis[guardKey] = guardState;

afterEach(() => {
  assert.equal(guardState.networkRequestsPerformed, false, "network calls must not be performed");
  assert.equal(guardState.envReadsAttempted, false, "real .env files must not be read");
  assert.deepEqual(guardState.sensitiveLogViolations, [], "descriptor references must not be logged");
});

export function compiledModule(relativePath) {
  return pathToFileURL(path.join(compiledRoot, relativePath)).href;
}

export function baseEntitlementRequest(overrides = {}) {
  return {
    user_id: "user-local-contract",
    anonymous_session_id: null,
    movie_id: "friendly",
    storekit_product_id: "com.highfive.movie.thefriendly",
    entitlement_context: {
      app_reported_state: "entitlement_approved",
      receipt_source: "local_contract_test"
    },
    playback_provider: "cloudflare_stream",
    device_context: {
      platform: "ios_simulator",
      build: "local_contract_test"
    },
    ...overrides
  };
}

export function playbackRequestFromEntitlement(entitlementResponse, overrides = {}) {
  return {
    ...baseEntitlementRequest(),
    audit_id: entitlementResponse.audit_id,
    ...overrides
  };
}

export function assertIsoDate(value, message) {
  assert.equal(typeof value, "string", message);
  assert.ok(!Number.isNaN(Date.parse(value)), message);
}

export function assertNoCredentialMaterial(value) {
  const rendered = JSON.stringify(value);
  assert.doesNotMatch(rendered, /HIGHFIVE_/);
  assert.doesNotMatch(rendered, /CLOUDFLARE/i);
  assert.doesNotMatch(rendered, /REVENUECAT/i);
  assert.doesNotMatch(rendered, /PRIVATE_KEY/i);
  assert.doesNotMatch(rendered, /-----BEGIN/);
  assert.doesNotMatch(rendered, /Bearer\s+[A-Za-z0-9]/);
  assert.doesNotMatch(rendered, /(?:token|secret|api[_-]?key)\s*[:=]\s*[^<\s"']+/i);
}

export function assertNoConcreteUrl(value) {
  assert.doesNotMatch(JSON.stringify(value), /https?:\/\//i);
}

export function assertShortLived(expiresAt, now = Date.now()) {
  const expiresAtMs = Date.parse(expiresAt);
  assert.ok(expiresAtMs > now, "descriptor expiry must be in the future");
  assert.ok(expiresAtMs - now <= 10 * 60 * 1000 + 5_000, "descriptor must be short-lived");
}

export function guardSummary() {
  return {
    network_requests_performed: guardState.networkRequestsPerformed,
    env_reads_attempted: guardState.envReadsAttempted,
    sensitive_log_violations: guardState.sensitiveLogViolations.length
  };
}
