FROM certbot/certbot

VOLUME /var/www/certbot/
VOLUME /etc/letsencrypt/

RUN SLEEPTIME=$(awk 'BEGIN{srand(); print int(rand()*(3600+1))}'); echo "0 0,12 * * * root sleep $SLEEPTIME && certbot renew" | tee -a /etc/crontab > /dev/null

ENTRYPOINT crond -f
