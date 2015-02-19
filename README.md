# Meteortree

Meteor rewrite of GSAPP Skilltree.

Uses Meteor. Deployed with [Dokku](https://github.com/progrium/dokku).

###How to deploy:

####Install Dokku:

1) Install Dokku (on server) with

`wget -qO- https://raw.github.com/progrium/dokku/v0.3.15/bootstrap.sh | sudo DOKKU_TAG=v0.3.15 bash`

2) Install Dokku MongoDB plugin (on server) with

`git clone https://github.com/jeffutter/dokku-mongodb-plugin.git /var/lib/dokku/plugins/mongodb`

`dokku plugins-install`

3) Upload SSH keys for dokku user (from client) with

`cat ~/.ssh/id_rsa.pub | ssh root@DOMAINNAMEOFAPPSERVER.com "sudo sshcommand acl-add dokku KEYDESCRIPTION"`

4) Set VHOST file (on server):

`echo "DOMAINNAMEOFAPPSERVER.com" > /home/dokku/VHOST`

####Deploy to Dokku:

5) Setup Dokku deployment location into repo (from client) with

`git remote add dokku dokku@DOMAINNAMEOFAPPSERVER.com:APPNAME`

6) Deploy dokku (from client) with

`git push dokku master`

7) Start MongoDB and create DB linked to Meteortree (from server) with
 
`dokku mongodb:start`

`dokku mongodb:create meteortree meteortree-db`

8) Set ROOT_URL and MONGODB_HOST env variables with (from server):

`dokku config:set meteortree MONGODB_HOST=http://localhost`

`dokku config:set meteortree ROOT_URL=http://meteortree.provolotapp.com`

9) Ta-da!
