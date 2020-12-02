#/**
# * TangoMan Kaamelott Videoboard Backend
# *
# * @version  0.1.0
# * @author   "Matthias Morin" <mat@tangoman.io>
# * @license  MIT
# */

.PHONY: help up shell open restart import update export reset build start stop status network install uninstall composer database cache own tests

#--------------------------------------------------
# Parameters
#--------------------------------------------------

# app environment
env=prod

#--------------------------------------------------
# Colors
#--------------------------------------------------

TITLE     = \033[1;42m
CAPTION   = \033[1;44m
BOLD      = \033[1;34m
LABEL     = \033[1;32m
DANGER    = \033[31m
SUCCESS   = \033[32m
WARNING   = \033[33m
SECONDARY = \033[34m
INFO      = \033[35m
PRIMARY   = \033[36m
DEFAULT   = \033[0m
NL        = \033[0m\n

#--------------------------------------------------
# Symfony
#--------------------------------------------------

# get correct console executable
CONSOLE=$(shell if [ -f ./app/console ]; then echo './app/console'; elif [ -f ./bin/console ]; then echo './bin/console'; fi)
# get correct public folder
PUBLIC=$(shell if [ -d ./web ]; then echo './web'; elif [ -d ./public ]; then echo './public'; else echo './'; fi)
# get current php version
PHP_VERSION=$(shell php -v | grep -oP 'PHP\s\d+\.\d+' | sed s/'PHP '//)
# symfony version
VERSION=$(shell ${CONSOLE} --version)

#--------------------------------------------------
# System
#--------------------------------------------------

# Local operating system (Windows_NT, Darwin, Linux)
ifeq ($(OS),Windows_NT)
	SYSTEM=$(OS)
else
	SYSTEM=$(shell uname -s)
endif

#--------------------------------------------------
# Help
#--------------------------------------------------

## Print this help
help:
	@printf "${TITLE} TangoMan Kaamelott Videoboard Backend ${NL}\n"

	@printf "${CAPTION} Infos:${NL}"
	@printf "${PRIMARY} %-12s${INFO} %s${NL}" "php"     "${PHP_VERSION}"
	@printf "${PRIMARY} %-12s${INFO} %s${NL}" "symfony" "${VERSION}"
	@printf "${NL}"

	@printf "${CAPTION} Description:${NL}"
	@printf "${WARNING} TangoMan Kaamelott Videoboard Backend${NL}\n"

	@printf "${CAPTION} Usage:${NL}"
	@printf "${WARNING} make [command] `awk -F '?' '/^[ \t]+?[a-zA-Z0-9_-]+[ \t]+?\?=/{gsub(/[ \t]+/,"");printf"%s=[%s]\n",$$1,$$1}' ${MAKEFILE_LIST}|sort|uniq|tr '\n' ' '`${NL}\n"

	@printf "${CAPTION} Config:${NL}"
	$(eval CONFIG:=$(shell awk -F '?' '/^[ \t]+?[a-zA-Z0-9_-]+[ \t]+?\?=/{gsub(/[ \t]+/,"");printf"$${PRIMARY}%-12s$${DEFAULT} $${INFO}$${%s}$${NL}\n",$$1,$$1}' ${MAKEFILE_LIST}|sort|uniq))
	@printf " ${CONFIG}\n"

	@printf "${CAPTION} Commands:${NL}"
	@awk '/^### /{printf"\n${BOLD}%s${NL}",substr($$0,5)} \
	/^[a-zA-Z0-9_-]+:/{HELP="";if(match(PREV,/^## /))HELP=substr(PREV, 4); \
		printf " ${LABEL}%-12s${DEFAULT} ${PRIMARY}%s${NL}",substr($$1,0,index($$1,":")),HELP \
	}{PREV=$$0}' ${MAKEFILE_LIST}

##################################################
### Symfony Docker
##################################################

## Build, start docker, composer install, create database, import data, and serve
up: network build start install

## Open a terminal in the php container
shell:
# 	@printf "${INFO}docker-compose exec php bash${NL}"
# 	@docker-compose exec php bash
	@printf "${INFO}docker-compose exec php sh${NL}"
	@docker-compose exec php sh

## Open in default browser
open:
	@printf "${INFO}nohup xdg-open `docker inspect kaamelott-backend --format 'http://{{.NetworkSettings.Networks.tango.IPAddress}}/api/docs' 2>/dev/null` >/dev/null 2>&1${NL}"
	@nohup xdg-open `docker inspect kaamelott-backend --format 'http://{{.NetworkSettings.Networks.tango.IPAddress}}/api/docs' 2>/dev/null` >/dev/null 2>&1

## Restart app and clear cache
restart: stop start cache

##################################################
### App
##################################################

## Import data from json/csv
import:
	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} app:import -f people.json\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} app:import -f people.json"

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} app:import -f episodes.csv\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} app:import -f episodes.csv"

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} app:import -f clips.csv\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} app:import -f clips.csv"

## Import and update
update:
	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} app:update -f clips.csv -x clip:csv -p name\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} app:update -f clips.csv -x clip:csv -p name"

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} app:update -f people.json -x person:json -p name\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} app:update -f people.json -x person:json -p name"

## Export data to json/csv
export:
	-@printf "${INFO}rm ./assets/exports/*${NL}"
	-@rm ./assets/exports/*

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} app:export -x clip:csv -g read:clip\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} app:export -x clip:csv -g read:clip"

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} app:export -x clip:json -g read:clip\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} app:export -x clip:json -g read:clip"

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} app:export -x episode:csv -g read:episode\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} app:export -x episode:csv -g read:episode"

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} app:export -x episode:json -g read:episode\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} app:export -x episode:json -g read:episode"

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} app:export -x person:csv -g read:person\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} app:export -x person:csv -g read:person"

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} app:export -x person:json -g read:person\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} app:export -x person:json -g read:person"

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} app:export -x tag:csv -g read:tag\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} app:export -x tag:csv -g read:tag"

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} app:export -x tag:json -g read:tag\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} app:export -x tag:json -g read:tag"

	@printf "${INFO}sudo chown -R `whoami`:`whoami` ./assets/exports${NL}"
	@sudo chown -R `whoami`:`whoami` ./assets/exports

## Drop database, clear cache and re-import data
reset: database import cache

##################################################
### Docker-Compose Container
##################################################

## Build container
build:
	@printf "${INFO}docker-compose build${NL}"
	@docker-compose build

## Start the environment
start:
	@printf "${INFO}docker-compose up --detach --remove-orphans${NL}"
	@docker-compose up --detach --remove-orphans

## Stop containers
stop:
	@printf "${INFO}docker-compose stop${NL}"
	@docker-compose stop

## List containers
status:
	@printf "${INFO}docker-compose ps${NL}"
	@docker-compose ps

##################################################
### Docker-Compose Network
##################################################

## Create `tango` network
network:
	@printf "${INFO}docker network create tango${NL}"
	-@docker network create tango

## Remove `tango` network
remove-network:
	@printf "${INFO}docker network rm tango${NL}"
	@docker network rm tango

##################################################
### Symfony App Docker
##################################################

## Install Symfony application in docker
install:
	@make --no-print-directory composer
	@make --no-print-directory database
	@make --no-print-directory import

## Uninstall app completely
uninstall: stop
	@printf "${INFO}sudo rm -f .env${NL}"
	@sudo rm -f .env
	@printf "${INFO}sudo rm -f ./composer.lock${NL}"
	@sudo rm -f ./composer.lock
	@printf "${INFO}sudo rm -f ./symfony.lock${NL}"
	@sudo rm -f ./symfony.lock
	@printf "${INFO}sudo rm -f ./composer${NL}"
	@sudo rm -f ./composer
	@printf "${INFO}sudo rm -f ./installer${NL}"
	@sudo rm -f ./installer
	@printf "${INFO}sudo rm -f ./symfony${NL}"
	@sudo rm -f ./symfony
	@printf "${INFO}sudo rm -f ./var/data.db${NL}"
	@sudo rm -f ./var/data.db
	@printf "${INFO}sudo rm -rf ./bin/.phpunit${NL}"
	@sudo rm -rf ./bin/.phpunit
	@printf "${INFO}sudo rm -rf ./vendor${NL}"
	@sudo rm -rf ./vendor
	@make --no-print-directory nuke

## Composer install Symfony project
composer:
ifeq ($(env),prod)
	@printf "${INFO}cp .env.prod .env${NL}"
	@cp .env.prod .env
else
	@printf "${INFO}cp .env.dev .env${NL}"
	@cp .env.dev .env
endif
	@printf "${INFO}docker-compose exec php sh -c \"composer install --optimize-autoloader --prefer-dist --working-dir=/www\"${NL}"
	@docker-compose exec php sh -c "composer install --optimize-autoloader --prefer-dist --working-dir=/www"

## Create database and schema
database:
	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} doctrine:database:drop --force\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} doctrine:database:drop --force"

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} doctrine:database:create\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} doctrine:database:create"

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} doctrine:schema:create --dump-sql\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} doctrine:schema:create --dump-sql"

	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} doctrine:schema:create\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} doctrine:schema:create"

##############################################
### Symfony Cache Docker
##############################################

## Clean cache
cache:
	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} cache:clear\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} cache:clear"
	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} cache:warmup\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} cache:warmup"
ifeq ($(env),dev)
	@make --no-print-directory own
endif

## Force delete cache
nuke:
	@printf "${INFO}sudo rm -rf ./var/cache${NL}"
	@sudo rm -rf ./var/cache
	@printf "${INFO}mkdir ./var/cache${NL}"
	@mkdir ./var/cache

	@printf "${INFO}sudo rm -rf ./var/log${NL}"
	@sudo rm -rf ./var/log
	@printf "${INFO}mkdir ./var/log${NL}"
	@mkdir ./var/log

## Own project files
own:
ifeq ($(env),prod)
	$(eval OWNER=$(shell whoami))
	$(eval GROUP=$(shell whoami))
else
	$(eval OWNER=nobody)
	$(eval GROUP=nogroup)
endif
	@printf "${INFO}sudo chown ${OWNER}:${GROUP} ./composer.lock${NL}"
	-@sudo chown ${OWNER}:${GROUP} ./composer.lock
	@printf "${INFO}sudo chmod 664 ./composer.lock${NL}"
	-@sudo chmod 664 ./composer.lock

	@printf "${INFO}sudo chown ${OWNER}:${GROUP} ./.php_cs.dist${NL}"
	-@sudo chown ${OWNER}:${GROUP} ./.php_cs.dist
	@printf "${INFO}sudo chmod 664 ./.php_cs.dist${NL}"
	-@sudo chmod 664 ./.php_cs.dist

	@printf "${INFO}sudo chown ${OWNER}:${GROUP} ./symfony.lock${NL}"
	-@sudo chown ${OWNER}:${GROUP} ./symfony.lock
	@printf "${INFO}sudo chmod 664 ./symfony.lock${NL}"
	-@sudo chmod 664 ./symfony.lock

	@printf "${INFO}sudo chown ${OWNER}:${GROUP} ./var/data.db${NL}"
	-@sudo chown ${OWNER}:${GROUP} ./var/data.db
	@printf "${INFO}sudo chmod 664 ./var/data.db${NL}"
	-@sudo chmod 664 ./var/data.db

	@printf "${INFO}sudo chown -R ${OWNER}:${GROUP} ./assets/exports${NL}"
	-@sudo chown -R ${OWNER}:${GROUP} ./assets/exports
	@printf "${INFO}sudo chmod 777 -R ./assets/exports${NL}"
	-@sudo chmod 777 -R ./assets/exports

	@printf "${INFO}sudo chown -R ${OWNER}:${GROUP} ./var${NL}"
	-@sudo chown -R ${OWNER}:${GROUP} ./var
	@printf "${INFO}sudo chmod 777 -R ./var${NL}"
	-@sudo chmod 777 -R ./var

	@printf "${INFO}sudo chown -R ${OWNER}:${GROUP} ./vendor${NL}"
	-@sudo chown -R ${OWNER}:${GROUP} ./vendor
	@printf "${INFO}sudo chmod 777 -R ./vendor${NL}"
	-@sudo chmod 777 -R ./vendor

##############################################
### JWT Docker
##############################################

## Generate JWT key
generate-keys:
	@printf "${INFO}sudo rm -rf ./config/jwt${NL}"
	-@sudo rm -rf ./config/jwt

	@printf "${INFO}mkdir -p ./config/jwt${NL}"
	-@mkdir -p ./config/jwt

	@printf "${INFO}echo \"$(shell grep ^JWT_PASSPHRASE .env | cut -f 2 -d=)\" | openssl genpkey -out ./config/jwt/private.pem -pass stdin -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:4096${NL}"
	@echo "$(shell grep ^JWT_PASSPHRASE .env | cut -f 2 -d=)" | openssl genpkey -out ./config/jwt/private.pem -pass stdin -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:4096

	@printf "${INFO}echo \"$(shell grep ^JWT_PASSPHRASE .env | cut -f 2 -d=)\" | openssl pkey -in ./config/jwt/private.pem -passin stdin -out ./config/jwt/public.pem -pubout${NL}"
	@echo "$(shell grep ^JWT_PASSPHRASE .env | cut -f 2 -d=)" | openssl pkey -in ./config/jwt/private.pem -passin stdin -out ./config/jwt/public.pem -pubout

##############################################
### PHPUnit Docker
##############################################

## Load fixtures
fixtures:
	@printf "${INFO}docker-compose exec php sh -c \"${CONSOLE} doctrine:fixtures:load --no-interaction --env=test\"${NL}"
	@docker-compose exec php sh -c "${CONSOLE} doctrine:fixtures:load --no-interaction --env=test"

## Run tests
tests: fixtures
	@if [ -x ./bin/phpunit ]; then \
		printf "${INFO}docker-compose exec php sh -c \"php -d memory-limit=-1 ./bin/phpunit --stop-on-failure\"${NL}"; \
		docker-compose exec php sh -c "php -d memory-limit=-1 ./bin/phpunit --stop-on-failure"; \
	elif [ -x ./vendor/bin/phpunit ]; then \
		printf "${INFO}docker-compose exec php sh -c \"bash ./vendor/bin/phpunit --stop-on-failure\"${NL}"; \
		docker-compose exec php sh -c "bash ./vendor/bin/phpunit --stop-on-failure"; \
	elif [ -x ./vendor/bin/simple-phpunit ]; then \
		printf "${INFO}docker-compose exec php sh -c \"php -d memory-limit=-1 ./vendor/bin/simple-phpunit --stop-on-failure\"${NL}"; \
		docker-compose exec php sh -c "php -d memory-limit=-1 ./vendor/bin/simple-phpunit --stop-on-failure"; \
	else \
		printf "${DANGER}error: phpunit executable not found${NL}"; \
		exit 1; \
	fi
