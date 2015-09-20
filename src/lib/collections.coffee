@Tutorials = new Mongo.Collection("tutorials")
@Steps = new Mongo.Collection("steps")
@Links = new Mongo.Collection("deps")
@Courses = new Mongo.Collection("courses")
@Weeks = new Mongo.Collection("weeks")

@s3imageStore = new FS.Store.S3("images", {
	bucket: "meteortree"
	folder: "icons"
});

@s3fileStore = new FS.Store.S3('files', {
	bucket: 'meteortree'
})

@fsiconStore = new FS.Store.FileSystem("icons", {
	path: "~/public/icons"
});

@Icons = new FS.Collection("icons", {
  stores: [fsiconStore]
});

@s3Icons = new FS.Collection('images', {
	stores: [s3imageStore]
})

@s3Files = new FS.Collection('files', {
	stores: [s3fileStore]
})

s3Icons.allow({
	"insert": () ->
		return true
})
