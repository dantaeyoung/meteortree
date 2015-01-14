<apply template="graph">
  <div class="section-tutorial-inner edit ${tutorialPublish}">
  <dfForm class="form-tutorial">
    <div class="header">
      <div class="draft-warning">DRAFT</div>
      <div class="edit-links">
        <a href="${tutorialShowPath}">Preview Tutorial</a>
        <a class="delete" onclick="return confirm('Are you sure you want to delete this tutorial node? This action cannot be undone.')" href="${tutorialDeletePath}">Delete Tutorial</a>
      </div>
      <div class="header-inner">
        <div class="icon">
          <img src="${tutorialIconPath}" />
          <div class="icon-edit-link">
            <div class="label">Edit</div>
            <div class="icon-edit-forms">
              <dfInputFile ref="iconPath" onchange="$(this).parents('form').submit()"/>
              <dfChildErrorList ref="iconPath" class="error" />
            </div>
          </div>
        </div>
        <div class="title">
          <dfInputTextArea class="title tutorial-title" ref="title" placeholder="Title"/>
          <dfChildErrorList ref="title" class="error" />
        </div>
      </div>
      <div class="header-edit">
          <div class="publish">
          <div class="label">Publish/Draft:</div>
          <dfInputSelect ref="publish" />
          <dfChildErrorList ref="publish" class="error" />
        </div>
        <div class="submit">
          <a href="#"><dfInputSubmit value="Save" class="btn btn-lg btn-primary btn-block" /></a>
        </div>
      </div>
    </div>
  </dfForm>

  <apply template="tutorial-steps"></apply>


  </div>
</apply>
