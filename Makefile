_DOCKER:=docker
_DOCKER_COMPOSE:=docker compose
# _DOCKER_COMPOSE:=docker compose -f docker-compose-caddy.yml
# _DOCKER_COMPOSE:=docker compose -f docker-compose-caddy-archivebox07.yml
_HUB_REPO=jonschoning

.PHONY: none
none:
	@echo "no command"
pull:
	$(_DOCKER_COMPOSE) pull espial
createdb:
	$(_DOCKER_COMPOSE) exec espial ./migration createdb --conn /app/data/espial.sqlite3
up:
	$(_DOCKER_COMPOSE) up espial
up-d:
	@$(_DOCKER_COMPOSE) up -d espial
down:
	$(_DOCKER_COMPOSE) down
logs-espial:
	@$(_DOCKER) logs -f --since `date -u +%FT%TZ` `$(_DOCKER_COMPOSE) ps -q espial`
logs:
	@$(_DOCKER_COMPOSE) logs -f --since `date -u +%FT%TZ`
shell:
	$(_DOCKER_COMPOSE) exec espial sh
updateimage:                                                                     
	sudo systemctl stop espial.service && HUB_REPO=$(_HUB_REPO) make pull && sudo systemctl start espial.service && sudo systemctl status espial.service 

