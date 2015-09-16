# Meteortree

Meteor rewrite of GSAPP Skilltree.

Uses Meteor. Deployed with [mupx](https://github.com/arunoda/meteor-up/tree/mupx#).

###How to develop:

Run devrun.sh; see devrun.sh.example to add MONGODB_URL env keys and others.

###How to deploy:

1) Install mupx (locally) with

`npm install -g mupx`

2) Edit mup.json file.

See mup.json.example file and make sure any environment variables (such as MongoDB servers) are set accurately. Make sure that server has ssh keys from your computer.

3) Setup mupx server and deploy.

From the meteor source folder:

`mupx setup`
`mupx deploy`

