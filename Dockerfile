FROM node:lts-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine AS runtime
VOLUME /app
#RUN rm -rf /app/*
RUN mkdir -p /app/hahahaha
#RUN touch /app/teststs.txt
RUN mkdir -p /app/test

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 www
RUN adduser --system --uid 1001 www

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY --link --from=build /app/dist /app
COPY --link --from=build /app/dist /app/test

WORKDIR /app
RUN chown -R www:www /app && chmod -R 755 /app && \
    chown -R www:www /var/cache/nginx && \
    chown -R www:www /var/log/nginx && \
    chown -R www:www /usr/share/nginx/html && \
    chown -R www:www /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
    chown -R www:www /var/run/nginx.pid
USER www

CMD ["nginx", "-g", "daemon off;"]