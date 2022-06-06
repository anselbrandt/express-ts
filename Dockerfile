FROM node:16-alpine AS web_deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY web/package.json web/yarn.lock ./
RUN yarn install --frozen-lockfile

FROM node:16-alpine AS web_builder
WORKDIR /app
COPY --from=web_deps /app/node_modules ./node_modules
COPY web/. .
RUN yarn build

FROM node:16-alpine AS server_deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

FROM node:16-alpine AS server_builder
WORKDIR /app
COPY --from=server_deps /app/node_modules ./node_modules
COPY package.json ./
COPY tsconfig.json ./
COPY src/. ./src
COPY public/. ./public
RUN yarn build

FROM node:16-alpine AS runner
WORKDIR /app
ENV NODE_ENV production
COPY --from=web_builder /app/out ./web/out
COPY --from=server_deps /app/node_modules ./node_modules
COPY --from=server_builder /app/dist ./dist
COPY --from=server_builder /app/package.json ./package.json

EXPOSE 5000

ENV PORT 5000

CMD ["node", "dist/index.js"]