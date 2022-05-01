_DOCKER:=docker
_DOCKER_COMPOSE:=docker compose

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
logs:
	@$(_DOCKER) logs -f --since `date -u +%FT%TZ` `$(_DOCKER_COMPOSE) ps -q espial`
shell:
	$(_DOCKER_COMPOSE) exec espial sh
#update:                                                                     
#        sudo systemctl stop espial.service && HUB_REPO=jonschoning make pull && sudo systemctl start espial.service && sudo systemctl status espial.service 

