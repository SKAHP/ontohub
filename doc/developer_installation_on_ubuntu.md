# Developer Installation on Ubuntu

*This guide is for Ubuntu 14.04*

## Ruby (rbenv and ruby-build)

We recommend to use rbenv for managing
ruby on your system. Sam Stephenson gives a good
installation guide on the [Github page](https://github.com/sstephenson/rbenv#installation).
But here is what you have to do:

- `$ git clone https://github.com/sstephenson/rbenv.git ~/.rbenv`

Now we just have to tell the shell to use rbenv
to determine the Ruby Version.

- `$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc`
- `$ echo 'eval "$(rbenv init -)"' >> ~/.bashrc`

If you are using **zsh**, just replace the *.bashrc* with
*.zshrc* (or the config file for your shell, if you are using
different one).

if you restart your shell you could check if rbenv is installed correctly
with:

```
$ type rbenv
#=> "rbenv is a function"
````

to install a ruby version, first install ruby-build with
```
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
```

The file `.ruby-version` contains the ruby version, e.g. 2.1.7, which you should install with this command

```
rbenv install 2.1.7
```
### rbenv aliases

As we use the *.ruby-version* to specify ontohubs ruby version,
you might need rbenv aliases in order to use the **right**
local version.

- `mkdir -p ~/.rbenv/plugins`
- `git clone git://github.com/tpope/rbenv-aliases.git \
  ~/.rbenv/plugins/rbenv-aliases`
- `rbenv alias --auto`

## PostgreSQL
```
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get install -y postgresql-9.3
sudo sed -i 's/de_DE/en_US/' /etc/postgresql/9.3/main/postgresql.conf
sudo service postgresql reload
```

Next, we should allow the connection to the database with the postgres user. Edit the `/etc/postgresql/9.3/main/pg_hba.conf` as super user. Somewhere on the bottom there is the line
```
local   all             postgres                                peer
```
change it to
```
local   all             postgres                                trust
```

After this we should create the config directory for postgres:

- `initdb /usr/local/var/postgres -E utf8`

As the postgres user you have to create two databases
- `sudo su -l postgres`
- `createdb ontohub_development`
- `createdb ontohub_test`

When you type in
- `psql` 
you should be connected to the database (`\q` lets you quit).


## gems

Switch to the directory where you clone ontohub.

We use **capybara-webkit** for integration testing. This gem needs a **qt**-Engine
on the system, so we will have to install one:

- `sudo apt-get install libqtwebkit-dev`

Clone the ontohub sources:
- `git clone git@github.com:ontohub/ontohub.git`
(Side note: if you want to push later on, you need to get access rights from the Ontohub team first.)

Now we can actually start installing the necessary gems:

- `cd ontohub`
- `gem install bundler`
- `bundle install`

## redis

In order for sidekiq to work, we need to install redis.

```
add-apt-repository ppa:chris-lea/redis-server
apt-get update
apt-get install -y redis-server
```

## elasticsearch

```
wget -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
sudo add-apt-repository "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main”
sudo apt-get update
sudo apt-get install -y elasticsearch
sudo update-rc.d elasticsearch defaults 95 10
```

And then after a reboot the elasticsearch service should be running.

## hets

The Heterogenous Toolset is needed to perform Operations during Ontology import.
To Install it you have to do the following steps:

```
apt-add-repository ppa:hets/hets
apt-add-repository "deb http://archive.canonical.com/ubuntu precise partner"
apt-get update
apt-get -y install hets-core subversion

cd /lib/x86_64-linux-gnu/
ln -s libpng12.so.0 libpng14.so.14
```

If you need the latest nightly build, just update hets (assure you have a working internet connection):

```
hets -update
```

## phantomjs
We use `phantomjs` as a headless javascript-enabled browser for our integration
tests. You only need to install the package:
```
sudo apt-get install -y phantomjs
```

## Extra executables

The SSH-Key handling requires an additional executable `data/.ssh/cp_keys` to exist.
This can be compiled easily from the supplied C-code with (in the ontohub directory)

    GIT_HOME=$(pwd)/tmp/git bundle exec rake git:compile_cp_keys

Providing the `GIT_HOME` variable is mandatory for this rake task.
It will print a message about changing permissions, but you don't need to do as the message says as long as you are in a development environment.
It is only important for securing production systems.

## setup

In ontohub directory:

You can start everything needed with (in the ontohub directory):
```
invoker start invoker.ini
```
And you can (re)build the database with:
```
script/rebuild-ontohub
```

Now you should be ready...


## Troubleshooting
### Remote Access
If you want to access the rails server (WEBrick) remotely, it gets very slow.
To speed things up, you can change the WEBrick config:
Find the `webrick/config.rb` of your ruby (rbenv) installation and change
`:DoNotReverseLookup => nil` to `:DoNotReverseLookup => true`.
[Source](https://www.ruby-forum.com/topic/218316)
