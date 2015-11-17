if Meteor.isClient

  Meteor.subscribe "books"
  Meteor.subscribe "messages"

  AutoForm.debug()

  AutoForm.addHooks "messageForm",
    onSuccess : (formType, result) ->
      if formType is "insert"
        status = this.currentDoc.status
        messageId = this.currentDoc.prevMessageId
        bookId = this.currentDoc.bookId
        console.log "messageId", messageId
        switch status
          when "requested" then Meteor.call "request", bookId
          when "accepted" then Meteor.call "accept", bookId, messageId
          when "denied" then Meteor.call "deny", bookId, messageId

  
  FlowRouter.route "/",
    name : "home"
    action : ->
      BlazeLayout.render "layout",
        content : "about"

  FlowRouter.route "/all-books",
    name : "allBooks"
    action : ->
      BlazeLayout.render "layout",
        content : "books"

  FlowRouter.route "/messages",
    name : "messages"
    action : ->
      BlazeLayout.render "layout",
        content : "messages"

  Template.messages.helpers

    messages : Messages.find()


  Template.books.helpers

    books : Books.find()

    mayAddBook : ->
      Meteor.userId()


  messageDoc = (status)->
    status : status
    prevMessageId : Template.currentData()._id
    bookId : Template.currentData().bookId
    bookTitle: Template.currentData().bookTitle
    senderId : Meteor.userId()
    senderName : Meteor.user().username
    recipientId : Template.currentData().senderId
    recipientName : Template.currentData().senderName

  Template.messageDisplay.helpers

    messageDocAccepted : -> messageDoc("accepted")
    messageDocDenied : -> messageDoc("denied")
    

  Template.bookDisplay.helpers

    messageDoc : ->
      status : "requested"
      bookId : Template.currentData()._id
      bookTitle: Template.currentData().title
      senderId : Meteor.userId()
      senderName : Meteor.user().username
      recipientId : Template.currentData().ownerId
      recipientName : Template.currentData().ownerName

    panelClass : ->
      userId = Meteor.userId()
      if userId and this.ownerId is userId
        if this.status is "available"
          "panel-info"
        else
          "panel-danger"
      else
        if userId and this.requesterId is userId \
        and this.status isnt "available"
          "panel-warning"
        else
          if this.status is "available"
            "panel-success"
          else
            "panel-default"

    mayRequest : ->
      Meteor.userId() and this.ownerId isnt Meteor.userId()\
      and this.status is "available"

    mayEdit : ->
      Meteor.userId() and this.ownerId is Meteor.userId()

    mayDoNothing : ->
      not Meteor.userId()


  Accounts.ui.config
    passwordSignupFields: 'USERNAME_AND_EMAIL'

if Meteor.isServer

  Meteor.publish "books", ->
    Books.find()

  Meteor.publish "messages", ->
    Messages.find()


Meteor.methods

  accept : (bookId, messageId) ->
    book = Books.findOne(bookId)
    unless Meteor.userId()
      throw new Meteor.Error "logged-out", "must be logged in to trade books"
    if Meteor.userId() isnt book.ownerId
      throw new Meteor.Error "not owner", "you must own a book to trade it"
    Books.update bookId,
      $set :
        status : "accepted"
    Messages.remove
      _id : messageId
    Meteor.setTimeout ->
      Books.update bookId,
        $set :
          status : "available"
    ,
      120000
    console.log "#{Meteor.user().username} agreed to trade #{book.title}"
    console.log "should be deleting message:", messageId
    

  deny : (bookId, messageId) ->
    book = Books.findOne(bookId)
    unless Meteor.userId()
      throw new Meteor.Error "logged-out", "must be logged in to trade books"
    if Meteor.userId() isnt book.ownerId
      throw new Meteor.Error "not owner", "you must own a book to not trade it"
    Books.update bookId,
      $set :
        status : "available"
      $unset :
        requesterId : ""
    Messages.remove
      _id : messageId
    console.log "#{Meteor.user().username} denied to trade #{book.title}"
    console.log "should be deleting message:", messageId
    

  request : (bookId) ->
    book = Books.findOne(bookId)
    unless Meteor.userId()
      throw new Meteor.Error "logged-out", "must be logged in to request books"
    if Meteor.userId() is book.ownerId
      throw new Meteor.Error "own book", "you could request your own book, \
      but that would be silly"
    Books.update bookId,
      $set :
        status : "requested"
        requesterId : Meteor.userId()
    console.log "#{book.title} requested by #{Meteor.user().username}"
