# MagicDNS

**MagicDNS** — проксирующий DNS-сервер для обхода географических блокировок по IP.

## Используемые компоненты:
- **dnsmasq** — резолвер DNS с поддержкой подмены доменов на нужные IP.
- **nginx** — HTTP-прокси и TCP-прокси для HTTPS с поддержкой модуля stream.

## Возможности
- Подмена DNS-записей для заданных доменов (задаются через переменную окружения `DOMAINS`).
- Прозрачное проксирование HTTP-запросов.
- Прозрачное SNI-проксирование HTTPS-трафика (без расшифровки).
- Поддержка работы с IPv4 и IPv6.

## Установка
Проверено на **Ubuntu 24.04** с правами root.

### 1. Обновление системы
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Установка Docker
Следуйте [официальному руководству Docker для Ubuntu](https://docs.docker.com/engine/install/ubuntu/).

### 3. Освобождение порта 53
На Ubuntu 24.04 может работать `systemd-resolved`, занимающий порт 53. Для запуска MagicDNS нужно отключить встроенный DNS Stub Listener.

Откройте файл конфигурации:
```bash
sudo nano /etc/systemd/resolved.conf
```

Найдите строку `#DNSStubListener=yes`, раскомментируйте её и измените значение на:
```ini
DNSStubListener=no
```

Сохраните (`Ctrl+O`, `Enter`) и выйдите (`Ctrl+X`).

Перезапустите службу:
```bash
sudo systemctl restart systemd-resolved
```

Удалите старый `/etc/resolv.conf`:
```bash
sudo rm /etc/resolv.conf
```

Создайте новый `/etc/resolv.conf`:
```bash
sudo nano /etc/resolv.conf
```

Добавьте DNS-серверы, например Google DNS:
```ini
nameserver 8.8.8.8
nameserver 8.8.4.4
```

Сохраните файл (`Ctrl+O`, `Enter`, затем `Ctrl+X`).

Теперь порт 53 свободен и системные приложения будут использовать указанные DNS-серверы.

### 4. Клонирование репозитория
```bash
git clone https://github.com/MillerTGr/MagicDNS.git
```

### 5. Сборка и запуск контейнера
Перейдите в папку проекта:
```bash
cd MagicDNS
```

Укажите IP-адреса сервера и список доменов для проксирования в файле `docker-compose.yml`:
```ini
MAIN_IPV4=ваш_ipv4
MAIN_IPV6=ваш_ipv6

DOMAINS=chatgpt.com,openai.com
```

Соберите и запустите контейнер:
```bash
docker compose up -d --build
```

### 6. Просмотр логов
Просмотреть логи работы `dnsmasq` и `nginx` можно командой:
```bash
docker compose logs -f
```
