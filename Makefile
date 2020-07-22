.PHONY: none
none:
	@echo "no command"
pull:
	docker-compose pull espial
createdb:
	docker-compose exec espial ./migration createdb --conn /app/data/espial.sqlite3
up:
	docker-compose up espial
up-d:
	@docker-compose up -d espial
down:
	docker-compose down
logs:
	@docker logs -f --since `date -u +%FT%TZ` `docker-compose ps -q espial`
shell:
	docker-compose exec espial sh
#update:                                                                     
#        sudo systemctl stop espial.service && HUB_REPO=jonschoning make pull && sudo systemctl start espial.service && sudo systemctl status espial.service 

