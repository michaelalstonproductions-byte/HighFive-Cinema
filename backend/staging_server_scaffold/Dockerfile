FROM node:22-alpine
WORKDIR /app
COPY package.json tsconfig.json tsconfig.http-target.json ./
COPY src ./src
COPY migrations ./migrations
COPY seed ./seed
COPY scripts ./scripts
RUN npx tsc -p tsconfig.http-target.json --outDir ./compiled
ENV HIGHFIVE_BACKEND_ENV=local_smoke
ENV HIGHFIVE_PROVIDER_MODE=mock
ENV HIGHFIVE_SERVER_HOST=127.0.0.1
ENV HIGHFIVE_SERVER_PORT=8787
CMD ["node", "compiled/runtime/start.js"]
