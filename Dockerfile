
FROM node:18-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /

COPY package.json package-lock.json ./
RUN  npm install --production

FROM node:18-alpine AS builder
WORKDIR /
COPY --from=deps /node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED 1

RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 www-data
RUN adduser --system --uid 1001 www-data

COPY --from=builder --chown=www-data:www-data /.next ./.next
COPY --from=builder --chown=www-data:www-data /public ./public
COPY --from=builder /node_modules ./node_modules
COPY --from=builder /package.json ./package.json

USER www-data

EXPOSE 3000

ENV PORT 3000

CMD ["npm", "start"]