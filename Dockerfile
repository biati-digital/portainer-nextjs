FROM node:lts-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json ./
RUN  npm install --production

FROM node:lts-alpine AS builder
WORKDIR /app
COPY --from=deps /node_modules ./node_modules
COPY . .

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN npm run build

FROM nginx:alpine AS runtime
#RUN rm -rf /app/*
RUN mkdir -p /app/hahahaha
RUN mkdir -p /app/hulk
#RUN touch /app/teststs.txt
RUN mkdir -p /app/test

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 www
RUN adduser --system --uid 1001 www

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist /app
COPY --from=build /app/dist /app/test

WORKDIR /app
RUN chown -R www:www /app && chmod -R 755 /app && \
    chown -R www:www /var/cache/nginx && \
    chown -R www:www /var/log/nginx && \
    chown -R www:www /usr/share/nginx/html && \
    chown -R www:www /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
    chown -R www:www /var/run/nginx.pid
USER www

VOLUME /app

CMD ["nginx", "-g", "daemon off;"]