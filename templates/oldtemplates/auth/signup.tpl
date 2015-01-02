<apply template="base">

  <dfForm method="post">
    <dfChildErrorList ref="" />

    <dfSubView ref="email">
      <dfInput ref="address"/>
      <dfInput ref="confirm"/>
    </dfSubView>

    <br/>
    <dfInputPassword ref="password" />
    <br/>

    <dfInputSubmit/>
  </dfForm>
</apply>
