.PHONY: update
update: stop dang up

.PHONY: up
up:
	docker compose up -d --remove-orphans

.PHONY: restart
restart:
	docker compose restart

.PHONY: log
log:
	docker logs -f evolution

.PHONY: down
down:
	docker compose down

.PHONY: stop
stop:
	docker compose stop
	docker compose rm -f

.PHONY: dang
dang:
	docker rmi $$(docker images -qf dangling=true)
	docker volume rm $$(docker volume ls -qf dangling=true)

.PHONY: remove
remove:
	docker rm $$(docker ps -a -q) -f

.PHONY: volume
volume:
	docker volume rm  n8n-local_evolution_storage
