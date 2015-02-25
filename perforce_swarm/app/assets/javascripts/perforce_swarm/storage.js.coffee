# Store and retrieve recently visited projects from localStorage
swarm.recentProjects = {
  get: ->
    JSON.parse(window.localStorage.getItem('recent-projects')) || []
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
