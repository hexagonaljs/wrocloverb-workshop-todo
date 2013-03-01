#= require jquery
#= require handlebars
#= require ./underscore
#= require ./YouAreDaBomb
#= require ./YouAreDaBomb.shortcuts
#= require_tree ./templates

class TasksContainer
  constructor: ->
    @currentId = 1
    @tasks = []

  count: ->
    @tasks.length

  add: (name) ->
    task = new Task(@currentId, name)
    @tasks.push(task)
    @currentId += 1
    task


class Task
  constructor: (@id, @name) ->


class UseCase
  constructor: ->
    @tasks = new TasksContainer()
    @tasks.add("buy milk")
    @tasks.add("bring milk home")

  displayTasks: ->

  addTask: (name) ->
    @tasks.add(name)


class Gui
  constructor: ->
    @showContainer()
    @showNewTaskButton()

  showContainer: =>
    @container = $("<div>")
    $("body").append(@container)

  showNewTaskButton: =>
    html = JST['templates/new_task_button']()
    @container.prepend(html)
    @container.find("#new-task-button").click (e) =>
      e.preventDefault()
      @newTaskClicked()

  removeNewTaskButton: =>
    @container.find("#new-task-button").detach()

  newTaskClicked: =>

  showTasks: (tasks) =>
    html = JST['templates/task_list']()
    if @container.find("#task-list").length
      @container.find("#task-list").html("")
    else
      @container.append(html)
    for task in tasks
      @addTask(task)

  addTask: (task) =>
    html = JST['templates/task'](
      id: "task-#{task.id}",
      name: task.name
    )
    @container.find("#task-list").append(html)

  showNewTaskForm: =>
    html = JST['templates/new_task_form']()
    @container.append(html)
    form = @container.find("#new-task-form")
    form.submit (e) =>
      e.preventDefault()
      name = form.find("input[name='name']").val()
      @newTaskFormSubmitted(name)

  removeNewTaskForm: =>
    @container.find("#new-task-form").detach()

  newTaskFormSubmitted: (name) =>


class Glue
  constructor: (@useCase, @gui) ->
    After(@useCase, 'displayTasks', =>
      @gui.showTasks(@useCase.tasks.tasks)
    )
    After(@gui, 'newTaskClicked', =>
      @gui.removeNewTaskButton()
      @gui.showNewTaskForm()
    )
    After(@gui, 'newTaskFormSubmitted', (name) =>
      if name.length > 0
        @useCase.addTask(name)
        @gui.removeNewTaskForm()
        @gui.showNewTaskButton()
    )
    After(@useCase, 'addTask', (name) =>
      @gui.showTasks(@useCase.tasks.tasks)
    )


class Runner
  constructor: ->
    @setupDomain()
    @setupGui()
    @setupGlue()

  setupDomain: ->
    @useCase = new UseCase()

  setupGui: ->
    @gui = new Gui()

  setupGlue: ->
    @glue = new Glue(@useCase, @gui)

  start: ->
    @useCase.displayTasks()

$ ->
  runner = new Runner()
  runner.start()

