FROM php:7.3-alpine

LABEL "com.github.actions.name"="phpqa"
LABEL "com.github.actions.description"="phpqa"
LABEL "com.github.actions.icon"="check"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="http://github.com/mickaelandrieu/phpqa-ga"
LABEL "homepage"="http://github.com/actions"
LABEL "maintainer"="Mickaël Andrieu <mickael.andrieu@prestashop.com>"

RUN apk add --update libxslt-dev && \
    docker-php-ext-install xsl

COPY --from=composer:1.8 /usr/bin/composer /usr/bin/composer
RUN COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME="/composer" \
    composer global require --prefer-dist --no-progress --dev edgedesign/phpqa:1.20.0

RUN cd /composer/vendor/edgedesign/phpqa && \
    composer update && \
    composer remove phpunit/phpunit --dev --no-interaction && \
    composer remove sebastian/phpcpd --no-interaction && \
    composer require sebastian/phpcpd:~3.0 phploc/phploc:~4 phpunit/phpunit:~5.7 symfony/filesystem:~3 symfony/process:~3 symfony/finder:~3 && \
    composer require jakub-onderka/php-parallel-lint jakub-onderka/php-console-highlighter phpstan/phpstan friendsofphp/php-cs-fixer:~2.2 vimeo/psalm sensiolabs/security-checker

ENV PATH /composer/vendor/bin:${PATH}

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]