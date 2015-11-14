@Books = new Mongo.Collection "books"

@BookSchema = new SimpleSchema
  title :
    type : String
  author :
    type : String
  owner :
    type : String
    autoValue : ->
      return if this.isInsert then Meteor.userId() else undefined
    autoform :
      omit : true
  requested :
    type : Boolean
    autoValue : ->
      return if this.isInsert then false else undefined
    autoform :
      omit : true
  requestedBy :
    type : String
    optional : true
    autoform :
      omit : true

Books.attachSchema(BookSchema)