if Meteor.isClient

  Meteor.subscribe "books"

  FlowRouter.route "/",
    name : "home"
    action : ->
      BlazeLayout.render "layout",
        content : "about"

  FlowRouter.route "/my-books",
    name : "myBooks"
    action : ->
      BlazeLayout.render "layout",
        content : "books"

  FlowRouter.route "/all-books",
    name : "allBooks"
    action : ->
      BlazeLayout.render "layout",
        content : "books"


  Template.books.helpers

    books : Books.find()

  
  Template.bookDisplay.helpers

    panelClass : ->
      if this.requested
        if Meteor.userId() and this.requestedBy is Meteor.userId()
          "panel-warning"
        else
          "panel-default"
      else
        if Meteor.userId() and this.owner is Meteor.userId()
          "panel-info"
        else
          "panel-success"
      

    mayNotRequest : ->
      not Meteor.userId() or this.owner is Meteor.userId()


  Template.bookDisplay.events

    "click .request-button" : ->
      console.log this
      swal
        title : "Request"
        text : "Do you want to borrow #{this.title} by #{this.author}?"
        showCancelButton : true
        #closeOnConfirm : false
        #html : false
      ,
        =>
          console.log "call request #{this._id}"
          Meteor.call "request", this._id

  
  Accounts.ui.config
    passwordSignupFields: 'USERNAME_AND_EMAIL'

if Meteor.isServer

  Meteor.publish "books", ->
    Books.find()

Meteor.methods
  
  request : (bookId) ->
    console.log "request #{bookId} called"
    book = Books.findOne(bookId)
    console.log book
    unless Meteor.userId()
      throw new Meteor.Error "logged-out", "must be logged in to request books"
    Books.update bookId,
      $set :
        requested : true
        requestedBy : Meteor.userId()
    console.log book