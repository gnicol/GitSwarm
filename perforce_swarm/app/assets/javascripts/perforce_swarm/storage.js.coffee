# Store and retrieve recently visited projects from localStorage
swarm.recentProjects = {
  get: ->
    projects = JSON.parse(window.localStorage.getItem('recent-projects')) || []
    last_checked = JSON.parse(window.localStorage.getItem('last-checked')) || null
    if (last_checked? and Date.now() - last_checked > 3600000) or !last_checked?
      $.ajax '/user/recent_projects',
        type: 'GET'
        dataType: "json"
        success: (recent_projects) ->
          swarm.recentProjects.set((x for x in projects when x.project.id in recent_projects))
          window.localStorage.setItem('last-checked', Date.now())
    projects
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
