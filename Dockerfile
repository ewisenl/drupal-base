# docker build --build-arg BASE_IMAGE_TAG=${BASE_IMAGE_TAG}
ARG BASE_IMAGE_TAG

FROM wodby/drupal-php:${BASE_IMAGE_TAG}

ARG TARGET_ENVIRONMENT
WORKDIR /var/www/html

USER root
RUN composer self-update 1.10.1
RUN curl --silent --output '/cloud_sql_proxy' 'https://storage.googleapis.com/ewise-public-files/gke/cloud_sql_proxy' \
    && chmod ugo+x '/cloud_sql_proxy'
RUN crontab -l | { cat; echo "*/15       *       *       *       *       /var/www/html/scripts/docker/cron.sh"; } | crontab -

USER wodby
COPY scripts/composer scripts/composer/
COPY scripts/docker scripts/docker/
COPY patches patches/
COPY composer.* ./
RUN scripts/docker/buildscript.sh ${TARGET_ENVIRONMENT}
COPY . .