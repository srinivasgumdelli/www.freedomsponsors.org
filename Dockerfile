FROM postgres:9.3
MAINTAINER "srinivasgumdelli@gmail.com"

ADD . /home/docker/app

ENV PGDATA /var/lib/postgresql/data #Why do I need this?
RUN chown -R postgres "$PGDATA"; gosu postgres initdb; sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf ; { echo; echo 'host all all 0.0.0.0/0 trust'; } >> "$PGDATA"/pg_hba.conf
RUN ( chown -R postgres "$PGDATA"; gosu postgres postgres & sleep 2 ; psql -U postgres -c "create user frespo;"; psql -U postgres -c "alter user frespo password 'frespo';"; psql -U postgres -c "create database frespo with owner frespo;"; )
 
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432

RUN apt-get -qq update
RUN apt-get install -y python-dev python-lxml libxslt-dev libpq-dev python-pip git
RUN (pip install virtualenv)
RUN (cd /home/docker/app/ && virtualenv ENV)
RUN (. /home/docker/app/ENV/bin/activate)
RUN (cd /home/docker/app/ && pip install -r requirements.txt)
RUN (cd /home/docker/app/djangoproject && python manage.py syncdb --migrate --noinput)
RUN (cd /home/docker/app/ && python manage.py collectstatic --noinput)
EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
