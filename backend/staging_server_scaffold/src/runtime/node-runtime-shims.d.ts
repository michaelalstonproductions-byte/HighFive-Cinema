declare const process: {
  env: Record<string, string | undefined>;
  stdout: { write(value: string): void };
  on(event: "SIGTERM" | "SIGINT", listener: () => void): void;
  exitCode?: number;
};

declare function setInterval(listener: () => void, delay?: number): unknown;
declare function clearInterval(intervalID: unknown): void;

interface ImportMeta {
  dirname: string;
}

declare class Buffer extends Uint8Array {
  static isBuffer(value: unknown): value is Buffer;
  static from(value: string | ArrayBuffer | Uint8Array): Buffer;
  static concat(chunks: readonly Uint8Array[]): Buffer;
  toString(encoding?: string): string;
}

declare module "node:http" {
  import { EventEmitter } from "node:events";

  export type IncomingHttpHeaders = Record<string, string | string[] | undefined>;

  export interface IncomingMessage extends AsyncIterable<Buffer> {
    method?: string;
    url?: string;
    headers: IncomingHttpHeaders;
  }

  export interface ServerResponse {
    writeHead(statusCode: number, headers?: Record<string, string>): void;
    end(body?: string): void;
  }

  export interface Server extends EventEmitter {
    listen(port: number, host: string, callback?: () => void): this;
    close(callback?: (error?: Error) => void): this;
    address(): { port: number; address: string; family: string } | string | null;
  }

  export function createServer(
    listener: (request: IncomingMessage, response: ServerResponse) => void | Promise<void>
  ): Server;
}

declare module "node:events" {
  export class EventEmitter {
    once(event: string, listener: (...args: unknown[]) => void): this;
    on(event: string, listener: (...args: unknown[]) => void): this;
  }
}

declare module "node:fs" {
  export function writeFileSync(path: string, data: string): void;
  export function readFileSync(path: string, encoding: "utf8"): string;
  export function mkdirSync(path: string, options?: { recursive?: boolean }): void;
}

declare module "node:fs/promises" {
  export function mkdir(path: string, options?: { recursive?: boolean }): Promise<void>;
  export function writeFile(path: string, data: Uint8Array | string): Promise<void>;
  export function rename(oldPath: string, newPath: string): Promise<void>;
  export function rm(path: string, options?: { recursive?: boolean; force?: boolean }): Promise<void>;
}

declare module "node:path" {
  export function dirname(path: string): string;
  export function join(...paths: string[]): string;
  export function resolve(...paths: string[]): string;
}

declare module "node:crypto" {
  export function randomUUID(): string;
  export function createHash(algorithm: string): {
    update(data: Uint8Array | string): { digest(encoding: "hex"): string };
    digest(encoding: "hex"): string;
  };
}
