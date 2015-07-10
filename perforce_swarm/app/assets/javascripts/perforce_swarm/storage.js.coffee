# Store and retrieve recently visited projects from localStorage
swarm.recentProjects = {
  get: ->
    projects = JSON.parse(window.localStorage.getItem('recent-projects')) || []
    recent_user_projects = []
    $.ajax '/user/recent_projects',
      type: 'GET'
      dataType: "json"
      async:   false
      success: (recent_projects) ->
        for id in recent_projects
          for project in projects
            if project.project.id not in recent_projects
              swarm.recentProjects.set((x for x in projects when x.path != project.path))
            else
              if project.project.id == id
                recent_user_projects.push(project)
      error: ->
        recent_user_projects = projects
    recent_user_projects
  set: (projects) ->
    window.localStorage.setItem('recent-projects', JSON.stringify(projects))
  clear: ->
    window.localStorage.setItem('recent-projects', null)
  add: (newProject) ->
    projectSlug    = (newProject.namespace?.path || '') + '/' + newProject.path
    recentProjects =
      for projectEvent in swarm.recentProjects.get() when projectEvent.path isnt projectSlug
        projectEvent
    recentProjects.unshift({path: projectSlug, project: newProject, time: Date.now()})
    swarm.recentProjects.set(recentProjects)
}

$ ->
  swarm.recentProjects.add(gon.project) if gon.project
