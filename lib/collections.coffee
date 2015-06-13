@Tutorials = new Mongo.Collection("tutorials")
@Steps = new Mongo.Collection("steps")
@Links = new Mongo.Collection("deps")
@Courses = new Mongo.Collection("courses")
@Weeks = new Mongo.Collection("weeks")

@s3imageStore = new FS.Store.S3("images", {
	bucket: "meteortree"
	folder: "icons"
});

@fsiconStore = new FS.Store.FileSystem("icons", {
	path: "~/public/icons"
});

@Icons = new FS.Collection("icons", {
  stores: [fsiconStore]
});

