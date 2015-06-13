@Tutorials = new Mongo.Collection("tutorials")
@Steps = new Mongo.Collection("steps")
@Links = new Mongo.Collection("deps")
@Courses = new Mongo.Collection("courses")
@Weeks = new Mongo.Collection("weeks")

@imageStore = new FS.Store.S3("images", {
	bucket: "meteortree"
	folder: "icons"
});

@Icons = new FS.Collection("images", {
  stores: [imageStore]
});

