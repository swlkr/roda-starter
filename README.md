# Roda Starter

This is a repo you can use as a starter for [roda](https://roda.jeremyevans.net) projects.

It has:

- A locked down CSP (everything served from same domain)
- Asset compilation in production
- A Containerfile for containers
- A .env file for podman to set env variables
- [Sequel](http://sequel.jeremyevans.net) with model plugin
- [Markaby](https://markaby.github.io) templates
- Example email auth with a migration, model, a mailer and a background job ([sucker_punch](https://github.com/brandonhilkert/sucker_punch)) for that mailer
- Sqlite is the database used in development and production

## Install podman

Go ahead and install podman if you don't have it already:

[https://podman.io/getting-started/installation](https://podman.io/getting-started/installation)

## Clone the repo

You also might want to rename `roda_starter.rb` to your project name as well

```sh
git clone https://github.com/swlkr/roda-starter ~/Projects/your_project
cd your_project
cp .env.example .env
```

## Start it up

This is a two step process:

1. Build the container

```sh
podman build -t your_project .
```

2. Start the container

```sh
podman run --rm -it --env-file .env --volume $(pwd):/var/app --publish 9292:9292 your_project # listening on http://localhost:9292
```

Everything happens on start up because I hate running rake tasks on every deploy:

1. podman runs bundle install
2. `models.rb` runs migrations on startup
3. `app.rb` runs `compile_assets` in production on startup

Head over to http://localhost:9292 and check it out!

You should be able to sign up, login and logout via email (magic link) auth.

## Deploy

I use [dokku](https://dokku.com) to deploy and it should "just work" with a volume for sqlite and a change to the nginx config for serving production assets:

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
