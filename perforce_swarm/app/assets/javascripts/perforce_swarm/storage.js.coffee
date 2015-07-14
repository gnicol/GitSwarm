# Store and retrieve recently visited projects from localStorage
swarm.recentProjects = {
  get: ->
    projects = JSON.parse(window.localStorage.getItem('recent-projects')) || []
    last_checked = JSON.parse(window.localStorage.getItem('last-checked')) || null
    recent_user_projects = []
    if last_checked? and Date.now() - last_checked < 3600000
      recent_user_projects = projects
    else
      $.ajax '/user/recent_projects',
        type: 'GET'
        dataType: "json"
        success: (recent_projects) ->
          swarm.recentProjects.set((x for x in projects when x.project? and x.project.id in recent_projects))
          window.localStorage.setItem('last-checked', Date.now())
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
