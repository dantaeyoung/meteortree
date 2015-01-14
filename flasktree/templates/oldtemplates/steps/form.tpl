<apply template="graph">
  <dfForm class="form-step">
    <div class="form-step-inner">
      <div class="edit-step-title">Edit step</div>
      <div class="step-description">
        <div class="label">Description</div>
        <dfInputTextArea ref="content" placeholder="Please describe the step" class="input"/>
        <dfChildErrorList ref="content" class="error"/>
      </div>

      <div class="step-ordinal">
        <div class="label">Ordinal</div>
        <dfInputText ref="ordinal" class="input" />
        <dfChildErrorList ref="ordinal" class="error" />
      </div>

      <div class="step-video">
        <div class="label">Video URL</div>
        <dfInputText ref="video" class="input" />
        <dfChildErrorList ref="video" class="error" />
      </div>
   
      <div class="submit">
        <a href="#"><dfInputSubmit value="Save" class="btn btn-lg btn-primary btn-block" /></a>
      </div>

      <div class="delete-button">
        <a class="delete" onclick="return confirm('Are you sure you want to delete this step? This action cannot be undone.')" href="${stepDeletePath}">Delete Video</a>
      </div>

    </div>
  </dfForm>
</apply>
