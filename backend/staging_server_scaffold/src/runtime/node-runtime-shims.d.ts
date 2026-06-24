declare const process: {
  env: Record<string, string | undefined>;
  stdout: { write(value: string): void };
  on(event: "SIGTERM" | "SIGINT", listener: () => void): void;
  exitCode?: number;
};

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

declare module "node:path" {
  export function dirname(path: string): string;
  export function resolve(...paths: string[]): string;
}
