# Используем свежий Alpine 3.20
FROM alpine:3.20

# Устанавливаем нужные пакеты:
# - bash
# - dnsmasq (DNS)
# - nginx (и модуль stream через nginx-mod-stream)
# - supervisor (для одновременного запуска процессов)
RUN apk update && \
    apk add --no-cache \
      bash \
      dnsmasq \
      nginx \
      nginx-mod-stream \
      supervisor

# Создаём каталог для конфигов supervisor
RUN mkdir -p /etc/supervisor.d

# Копируем шаблоны конфигурации dnsmasq и Nginx
COPY dnsmasq.conf.template /etc/dnsmasq.conf.template
COPY nginx.conf.template   /etc/nginx/nginx.conf.template

# Копируем скрипт entrypoint и делаем его исполняемым
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Создаём supervisor-конфиг для двух процессов (dnsmasq и nginx)
RUN echo "[supervisord]" > /etc/supervisor.d/supervisord.ini \
 && echo "nodaemon=true" >> /etc/supervisor.d/supervisord.ini \
 && echo "user=root" >> /etc/supervisor.d/supervisord.ini \
 \
 && echo "[program:dnsmasq]" >> /etc/supervisor.d/supervisord.ini \
 && echo "command=/usr/sbin/dnsmasq -k" >> /etc/supervisor.d/supervisord.ini \
 && echo "autorestart=true" >> /etc/supervisor.d/supervisord.ini \
 \
 && echo "[program:nginx]" >> /etc/supervisor.d/supervisord.ini \
 && echo "command=/usr/sbin/nginx -g 'daemon off;'" >> /etc/supervisor.d/supervisord.ini \
 && echo "autorestart=true" >> /etc/supervisor.d/supervisord.ini

# EXPOSE обычно не нужен при network_mode=host, 
# но оставим для документирования: (53/udp, 80/tcp, 443/tcp)
EXPOSE 53/udp
EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.d/supervisord.ini"]
