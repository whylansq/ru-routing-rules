# RU Routing Rules

Открытый профиль маршрутизации для РФ по схеме «VPN по умолчанию» с явными исключениями DIRECT, PROXY и BLOCK. Геобазы берутся из [`runetfreedom/russia-v2ray-rules-dat`](https://github.com/runetfreedom/russia-v2ray-rules-dat) и автоматически обновляются каждые 6 часов.

## Логика маршрутизации

1. **BLOCK** — `category-ads-all`.
2. **PROXY** — `ru-blocked`, заблокированные российские IP, YouTube, Discord, OpenAI, Instagram и Facebook (`meta`), X/Twitter.
3. **DIRECT** — Spotify, банки, Госуслуги, ecommerce, `ru-available-only-inside`, обычные `.ru` и российские IP.
4. Всё остальное идёт через VPN (`GlobalProxy=true`).

Порядок `block-proxy-direct` принципиален: заблокированные ресурсы проверяются раньше `category-ru` и `geoip:ru`.

## Готовые URL

```text
https://raw.githubusercontent.com/whylansq/ru-routing-rules/release/routing.json
https://raw.githubusercontent.com/whylansq/ru-routing-rules/release/geoip.dat
https://raw.githubusercontent.com/whylansq/ru-routing-rules/release/geosite.dat
https://raw.githubusercontent.com/whylansq/ru-routing-rules/release/checksums.txt
```

Для Happ обычно достаточно URL `routing.json`. Внутри него находятся актуальные ссылки на геобазы и обновляемый `LastUpdated`.

## Структура и ручное добавление

```text
rules/direct.txt  # всегда без VPN
rules/proxy.txt   # всегда через VPN
rules/block.txt   # блокировать
rules/ru.txt      # обычные российские ресурсы, объединяются с DIRECT
```

Добавьте `geosite:имя-категории` или `geoip:имя-категории` в нужный файл, запустите `bash ./scripts/generate-template.sh`, проверьте `jq empty routing.base.json routing.template.json` и отправьте изменения в `main`. Сборка запустится автоматически; вручную: **Actions → Build routing bundle → Run workflow**.

## Локальная проверка

```bash
bash ./scripts/generate-template.sh /tmp/routing.template.json
diff -u routing.template.json /tmp/routing.template.json
bash ./scripts/generate-routing.sh \
  https://raw.githubusercontent.com/whylansq/ru-routing-rules/release \
  "$(date +%s)" /tmp/routing.json
jq empty /tmp/routing.json
```

Основной upstream — `runetfreedom/russia-v2ray-rules-dat`. Большой `ru-blocked-all` намеренно не используется из-за размера и возможных ложных совпадений. Маршрутизация меняет путь трафика, но не гарантирует доступность сервиса: также влияют геолокация и репутация IP, а иногда регион аккаунта.
