# Roda Starter

This is a repo you can use as a starter for [roda](https://roda.jeremyevans.net) projects.

It has:

- A locked down CSP (everything served from same domain)
- Asset compilation in production
- A docker and docker compose file
- A .env file for docker to set env variables
- [Sequel](http://sequel.jeremyevans.net) with model plugin
- [Markaby](https://markaby.github.io) templates
- Example email auth with a migration, model, a mailer and a background job ([sucker_punch](https://github.com/brandonhilkert/sucker_punch)) for that mailer

## Install docker

I use docker in anger, apologies.

Go ahead and install docker if you don't have it already:

[https://docs.docker.com/docker-for-mac/install/](https://docs.docker.com/docker-for-mac/install/)

## Clone the repo

```sh
git clone https://github.com/swlkr/roda-starter ~/Projects/your_project
cd your_project
cp .env.example .env
```

## Start it up

```sh
docker compose up # listening on http://localhost:9292
```

Everything happens on start up because I hate running rake tasks on every deploy:

1. Docker runs bundle install (cached)
2. `models.rb` runs migrations on startup
3. `app.rb` runs `compile_assets` in production on startup

Head over to localhost:9292 and check it out!

You should be able to sign up, login and logout via email (magic link) auth.

## Deploy

I use [dokku](https://dokku.com) to deploy and it should "just work" with a docker volume for sqlite and a change to the nginx config for serving production assets:

```sh
# make sure you are in the project directory
cd your_project
# mount for sqlite
dokku storage:mount /var/lib/dokku/data/storage/db:/storage # make sure that `your_project` folder exists on the server
# mount for compiled assets
dokku storage:mount /var/lib/dokku/data/storage/your_project:/var/app/public # make sure that `your_project` folder exists on the server
```

Here's what you need for the nginx config

```sh
# add this to your nginx config
location /assets/ {
  alias /var/lib/dokku/data/storage/your_project/assets/;
}
```

And that should be it, the Procfile should get picked up by dokku and it also gives you a handy pry console with `dokku run console`!

Now go make something people want!
