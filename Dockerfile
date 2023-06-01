FROM node:lts-alpine AS build
WORKDIR /

COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine AS runtime
WORKDIR /

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 www
RUN adduser --system --uid 1001 www

RUN rm -rf /website/public_html
RUN mkdir /website
RUN mkdir /website/public_html
RUN mkdir /website/logs
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY --from=build /dist /www

RUN chown -R www:www /website/public_html && chmod -R 755 /website/public_html && \
    chown -R www:www /var/cache/nginx && \
    chown -R www:www /var/log/nginx && \
    chown -R www:www /usr/share/nginx/html && \
    chown -R www:www /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
    chown -R www:www /var/run/nginx.pid
USER www

VOLUME /website

CMD ["nginx", "-g", "daemon off;"]