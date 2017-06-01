# Meteortree

The [GSAPP Skill Tree](skilltree.gsapp.org) is a pedagogy platform at Columbia University GSAPP for explaining and teaching the unknown unknowns of architectural software tools.

![skilltree_screenshot](https://github.com/dantaeyoung/meteortree/blob/master/skilltree_screenshot.png)

(http://skilltree.gsapp.org)

Credits:
- **Created by:** Dan Taeyoung and Danil Nagy.
- **Design:** Dan Taeyoung 
- **Software development:** Dan Taeyoung, Scott Donaldson
- **Icons:** Dan Taeyoung
- **Video tutorials:**
  - Farzin Lotfi-Jam
  - Danil Nagy
  - Bika Rebek
  - Dan Taeyoung
  - Josh Uhl
  - and many others.

Please send suggestions/comments to dan.taeyoung@columbia.edu. 

## Dev info:

Uses Meteor w/ Blaze & Coffeescript. Deployed with Heroku.

TODO:
- [ ] Trails for courses
- [ ] Better edit UI
- [ ] Megavision CSS positioning


### How to develop / deploy:

#### Develop:
- Run `devrun.sh`
    - See `devrun.sh.example` to add MONGODB_URL env keys and others.
#### Deploy:

- `git push heroku master`

#### SCHEMA:
There are five collections:
Tutorials, Steps, Links, Courses, Weeks

Each Tutorial is a single tutorial, represented as nodes on the tree. (ex: "Intro to Rhino"). Each Tutorial contains one or many Steps; each Step can be either 1) a video tutorial, or 2) an open-ended Markdown form. (ex: "Rhino interface video 1/2", "Conditionals in Python").

Links connect between Tutorials; each Link is a non-directional link between two Tutorials. Links are represented as edges on the tree. 

Each Course is a specific trajectory through the tree (ex: "ADR2", "METATOOL"). Each Course contains a Week (ex: "Week 3").

