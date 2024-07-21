#!/bin/bash

# Install PostgreSQL 15
export DEBIAN_FRONTEND=noninteractive


wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update

#Show package info
apt-cache showpkg postgresql-16
apt-cache depends postgresql-16
apt show postgresql-16
dpkg -l | grep postgresql-client-16
dpkg -l | grep postgresql-contrib

sudo apt-get -y install postgresql-16 postgresql-client-16 postgresql-contrib
sudo apt-get install -y wget gnupg2 net-tools
sudo apt-get install postgresql-plpython3-16
sudo apt install postgresql-16-pgvector

# Config PostgreSQL
sudo -u postgres psql -c "CREATE USER marat WITH SUPERUSER PASSWORD 'md52fff642b8f9356685bcb6ebc08c5de08';"
sudo -u postgres createdb -O marat testdb
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/16/main/postgresql.conf
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf
sudo systemctl restart postgresql



##Configuring action for AI
sudo -u postgres psql -c "create extension if not exists plpython3u;" testdb
sudo -u postgres psql -c "create extension if not exists vector;" testdb

sudo -u postgres psql -d testdb -c "
CREATE TABLE commit_logs (
    id bigserial PRIMARY KEY,
    hash text NOT NULL,
    created_at timestamptz NOT NULL,
    authors text,
    message text,
    embedding vector(1024)
);
CREATE UNIQUE INDEX ON commit_logs(hash);"

git clone https://gitlab.com/postgres/postgres.git /tmp/postgres
cd /tmp/postgres

sudo git log --all --pretty=format:'%H,%ad,%an,🐘%s %b🐘🐍' --date=iso \
 | tr '\n' ' ' \
 | sed 's/"/""/g' \
 | sed 's/🐘/"/g' \
 | sed 's/🐍/\n/g' \
 > commit_logs.csv

sudo chmod 666 /tmp/postgres/commit_logs.csv

sudo -u postgres psql -d testdb -c "copy commit_logs(hash, created_at, authors, message)
   from stdin
   with delimiter ',' csv" \
 < commit_logs.csv

sudo -u postgres psql -d testdb -f /vagrant/query.sql
