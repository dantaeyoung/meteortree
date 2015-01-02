<apply template="graph">
  <div class="section-tutorial-inner show ${tutorialPublish}">
    <div class="header">
      <ifLoggedIn>
        <div class="draft-warning">DRAFT</div>
        <div class="edit-links">
          <a href="${tutorialEditPath}">Edit Tutorial</a>
          <a class="delete" onclick="return confirm('Are you sure you want to delete this tutorial node? This action cannot be undone.')" href="${tutorialDeletePath}">Delete Tutorial</a>
        </div>
      </ifLoggedIn>
      <div class="header-inner">
        <div class="icon">
          <img src="${tutorialIconPath}" />
        </div>
        <div class="title">
          <tutorialTitle />
        </div>
      </div>
    </div>
  	<apply template="tutorial-steps"></apply>
  </div>
</apply>
