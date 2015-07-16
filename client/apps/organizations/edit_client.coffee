AdminEditView = require '../../components/admin_form/index.coffee'
Organization = require '../../models/organization.coffee'
sd = require('sharify').data
AutocompleteList = require '../../components/autocomplete_list/index.coffee'

@init = ->
  organization = new Organization(sd.ORGANIZATION)
  new AdminEditView
    model: organization
    el: $('body')
    onDeleteUrl: '/organizations'
  list = new AutocompleteList $('.organization-authors')[0],
    name: 'author_ids'
    url: "#{sd.ARTSY_URL}/api/v1/match/users?term=%QUERY"
    filter: (users) -> for user in users
      { id: user.id, value: _.compact([user.name, user.email]).join(', ') }
    selected: (e, item, items) ->
      organization.save author_ids: _.pluck items, 'id'
    removed: (e, item, items) ->
      organization.save author_ids: _.pluck items, 'id'
    placeholder: 'Add a user by name or email....'
  organization.fetchAuthors success: (authors) ->
    items = authors.map (author) ->
      { id: author.get('id'), value: author.get('name') }
    list.setState loading: false, items: items