describe "Projects Nav", ->
  beforeEach ->
    cy
      .visit("/")
      .window().then (win) ->
        {@ipc, @App} = win

        @agents = cy.agents()

        @agents.spy(@App, "ipc")

        @ipc.handle("get:options", null, {})

  describe "no projects", ->
    beforeEach ->
      cy
        .fixture("user").then (@user) ->
          @ipc.handle("get:current:user", null, @user)
          @ipc.handle("get:project:paths", null, [])

    it "hides projects nav", ->
      cy.get(".navbar-default").should("not.exist")

  describe "selected project", ->
    beforeEach ->
      @firstProjectName = "My-Fake-Project"
      @lastProjectName = "project5"

      cy
        .fixture("user").then (@user) ->
          @ipc.handle("get:current:user", null, @user)
        .fixture("projects").then (@projects) ->
          @ipc.handle("get:project:paths", null, @projects)

      cy
        .contains("Projects").click()
        .get(".projects-list .dropdown-menu a")
          .contains(@firstProjectName).as("firstProject").click()

    it "displays projects nav", ->
      cy
        .get(".empty").should("not.be.visible")
        .get(".navbar-default")

    context "browsers dropdown", ->
      beforeEach ->
        @config = {
          clientUrl: "http://localhost:2020",
          clientUrlDisplay: "http://localhost:2020"
        }

        cy
          .fixture("browsers").then (@browsers) ->
            @config.browsers = @browsers
            @ipc.handle("open:project", null, @config)

      it "lists browsers", ->
        cy.get(".browsers-list")

    context "switch project", ->
      beforeEach ->
        cy
          .contains(@firstProjectName).click()
          .get(".projects-list .dropdown-menu a")
            .contains(@lastProjectName).as("lastProject").click()

      it "displays projects nav", ->
        cy
          .get(".empty").should("not.be.visible")
          .get(".navbar-default")

      context "browsers dropdown", ->
        beforeEach ->
          @config = {
            clientUrl: "http://localhost:2020",
            clientUrlDisplay: "http://localhost:2020"
          }

          cy
            .fixture("browsers").then (@browsers) ->
              @config.browsers = @browsers
              @ipc.handle("close:project", null, {})
              @ipc.handle("open:project", null, @config)

        it.only "lists browsers", ->
          cy.get(".browsers-list")
