FROM nginx:alpine AS runtime
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY /dist /usr/share/nginx/html

RUN addgroup --system --gid 1001 www
RUN adduser --system --uid 1001 www

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