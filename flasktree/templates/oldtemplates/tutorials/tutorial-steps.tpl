<div id="tutorial-steps" class="tutorial-steps">
  <tutorialSteps>
    <div class="tutorial-step" data-id="${stepId}" data-ordinal="${stepOrdinal}">
      <ifLoggedIn>
        <div class="edit-links">
          <a class="step-move step-move-up" href="#">&#9650;</a>
          <a class="step-move step-move-down" href="#">&#9660;</a>
          <a href="${stepEditPath}">Edit Video</a>
          <a class="delete" onclick="return confirm('Are you sure you want to delete this step? This action cannot be undone.')" href="${stepDeletePath}">Delete Video</a>
        </div>
      </ifLoggedIn>
      <div class="tutorial-step-inner">
        <div class="step-description">
          <stepContent/>
        </div>
        <div class="step-video">
          <stepVideo>
          <div class="lazy-load">
            <img class="lazy-load-thumbnail" data-video-url="${url}" data-video-code="${stepVideoCode}" />
  <!--          <img src="http://img.youtube.com/vi/${stepVideoCode}/0.jpg" />
           <img src="${stepVideoCode}" name="${url}" /> -->
            <div class="lazy-load-button"></div>
          </div>
          <iframe class="pre-load" src="" name="${url}" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
          </stepVideo>
        </div>
        <div class="step-ordinal" style="display:none;">
          <stepOrdinal/>
        </div>
      </div>
    </div>
  </tutorialSteps>
  <ifLoggedIn>
    <div class="edit-links">
      <a href="${tutorialStepNewPath}">Add a step!</a>
    </div>
    <div class="empty-step"></div>
  </ifLoggedIn>
</div>
