## METEORTREE

### SCHEMA:
There are five collections:
Tutorials, Steps, Links, Courses, Weeks

Each Tutorial is a single tutorial, represented as nodes on the tree. (ex: "Intro to Rhino"). Each Tutorial contains one or many Steps; each Step can be either 1) a video tutorial, or 2) an open-ended Markdown form. (ex: "Rhino interface video 1/2", "Conditionals in Python").

Links connect between Tutorials; each Link is a non-directional link between two Tutorials. Links are represented as edges on the tree. 

Each Course is a specific trajectory through the tree (ex: "ADR2", "METATOOL"). Each Course contains a Week (ex: "Week 3").

