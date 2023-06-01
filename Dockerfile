FROM node:lts-alpine AS build
WORKDIR /

COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
RUN mkdir -p jsjsjsj

FROM nginx:alpine AS runtime
WORKDIR /

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 www
RUN adduser --system --uid 1001 www

RUN rm -rf /www/*
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist /www

RUN chown -R www:www /www && chmod -R 755 /www && \
    chown -R www:www /var/cache/nginx && \
    chown -R www:www /var/log/nginx && \
    chown -R www:www /usr/share/nginx/html && \
    chown -R www:www /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
    chown -R www:www /var/run/nginx.pid
USER www

VOLUME /www

CMD ["nginx", "-g", "daemon off;"]