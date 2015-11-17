@Books = new Mongo.Collection "books"

@BookSchema = new SimpleSchema
  title :
    type : String
  author :
    type : String
  ownerId :
    type : String
    autoValue : ->
      if this.isInsert then Meteor.userId() else undefined
    autoform :
      omit : true
  ownerName :
    type : String
    autoValue : ->
      if this.isInsert then Meteor.user().username else undefined
    autoform :
      omit : true
  status :
    type : String
    autoValue : ->
      #available, requested, accepted, denied
      if this.isInsert then "available" else undefined
    autoform :
      omit : true
  requesterId :
    type : String
    optional : true
    autoform :
      omit : true
  requesterName :
    type : String
    optional : true
    autoform :
      omit : true

Books.attachSchema(BookSchema)

Books.allow
  insert : (userId, doc) ->
    userId
  update : (userId, doc, fields, modifier) ->
    userId and doc.ownerId is userId
  remove : (userId, doc) ->
    doc.ownerId is userId

@Messages = new Mongo.Collection "messages"

@MessageSchema = new SimpleSchema
  status :
    #requested, accepted, denied
    type : String
    autoform :
      type : "hidden"
  prevMessageId :
    type : String
    optional : true
    autoform :
      type : "hidden"
  bookId :
    type : String
    autoform :
      type : "hidden"
  bookTitle :
    type : String
    autoform :
      type : "hidden"
  senderId :
    type : String
    autoform :
      type : "hidden"
  senderName :
    type : String
    autoform :
      type : "hidden"
  recipientId :
    type : String
    autoform :
      type : "hidden"
  recipientName :
    type : String
    autoform :
      type : "hidden"
  text :
    type : String
    optional : true
    autoform :
      label : "Message (optional)"
      lines : 6

Messages.attachSchema(MessageSchema)

Messages.allow
  insert : (userId, doc) ->
    userId
  update : (userId, doc, fields, modifier) ->
    userId and doc.senderId is userId
  remove : (userId, doc) ->
    userId and ((doc.senderId is userId) or (doc.recipientId is userId))

@messageFormHooks = {}
