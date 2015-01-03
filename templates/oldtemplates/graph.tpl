<apply template="base">
 <div class="error-overlay">
  <div class="error-message">
  </div>
 </div>
 <div class="container">
  <div class="section-logo">
    <img class="logo" src="${siteLogoPath}" />
  </div>
  <div class="section-tree">
    <svg class='tree'></svg>
  </div>

  <div class="section-tutorial">
    <apply-content/>
  </div>

  <div class="courses"></div>

  <div id="javascript-helpers" style="display:none;">
    <!-- this is hacky, but currently necessary - exposes variables such as default icons to javascript -->
    <img id="tutorialDefaultIconPath" src="${tutorialDefaultIconPath}" />
  </div>

 </div>



  <div class="modeTray">
    <div class="modeTray-inner">
      <div class="modeTray-toolbar">
        <ifLoggedIn>
        <div class="buttons">
          <button class='create-button'>+ Create Tutorial</button>
        </div>
        </ifLoggedIn>
      </div>

      <div class="modeTray-loginout">
        <ifLoggedIn>
        <div id="saving-status"><div class="timeago"></div></div>
        <div class="motd">
          Hi, <loggedInUser><userLogin /></loggedInUser>
        </div>
        </ifLoggedIn>
        <div class="loginout-links">
          <ifLoggedIn>
              <a id="logout-link" href="/auth/logout">Logout</a>
          </ifLoggedIn>
          <ifLoggedOut>
              <a id="login-link" href="#">Login</a>
          </ifLoggedOut>
        </div>

        <ifLoggedOut>
          <div class="login-form">
            <form method='post' enctype='application/x-www-form-urlencoded' action="/auth/login">
              <div class="email">
                <div class="label">Email</div>
                <input id='login.email.address' name='login.email.address' value />
              </div>
              <div class="password">
                <div class="label">Password</div>
                <input type='password' id='login.password' name='login.password' value />
              </div>
              <div class="submit">
                <input type='submit' />
              </div>
            </form>
          </div>
        </ifLoggedOut>
      </div>


   </div>
</div>


</apply>
