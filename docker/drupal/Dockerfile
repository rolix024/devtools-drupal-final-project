FROM drupal:latest

WORKDIR /opt/drupal
RUN composer require --no-interaction --no-progress drush/drush

COPY web/themes/custom/devtools_hebrew web/themes/custom/devtools_hebrew
COPY web/modules/custom/devtools_content web/modules/custom/devtools_content
COPY docker/drupal/entrypoint.sh /usr/local/bin/devtools-entrypoint
RUN chmod +x /usr/local/bin/devtools-entrypoint \
    && chown -R www-data:www-data web/sites web/modules/custom web/themes/custom

ENTRYPOINT ["devtools-entrypoint"]
CMD ["apache2-foreground"]

