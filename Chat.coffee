
Messages = new Meteor.Collection("messages")

if Meteor.is_client
  Handlebars.registerHelper "formatDate", (time) ->
    date = new Date()
    date.setTime(time * 1000)
    date.toLocaleString()

  Template.messages.messages = () ->
    Messages.find {},
      sort:
        time: -1

  okcancel_events = (selector) ->
    "keyup " + selector + ", keydown " + selector + ", focusout " + selector

  make_okcancel_handler = (options) ->
    ok = options.ok or () ->

    cancel = options.cancel or () ->

    (evt) ->
      if evt.type is "keydown" and evt.which is 27
        cancel.call this, evt
      else if evt.type is "keyup" and evt.which is 13
        value = String(evt.target.value or "")
        if value
          ok.call(this, value, evt)
        else
          cancel.call(this, evt)

  Template.entry.events = {}
  Template.entry.events[okcancel_events("#messageBox")] = make_okcancel_handler(ok: (text, event) ->
    nameEntry = document.getElementById("name")
    nameVal = nameEntry.value
    unless nameVal is ""
      ts = (Date.now().getTime()) / 1000
      Messages.insert({
          name: nameVal
          message: text
          time: ts
      })
      event.target.value = ""
  )

if Meteor.is_server
  Meteor.startup ->
