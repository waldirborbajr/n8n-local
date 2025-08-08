.PHONY: up
up:
	docker compose up -d --remove-orphans

.PHONY: restart
restart:
	docker compose restart

.PHONY: logs
log:
	docker logs -f service-core

.PHONY: down
down:
	docker compose down

.PHONY: stop
stop:
	docker compose stop
	docker compose rm -f

.PHONY: dang
dang:
	docker rmi $$(docker images -q -f dangling=true)

.PHONY: remove
remove:
	docker rm $$(docker ps -a -q) -f
