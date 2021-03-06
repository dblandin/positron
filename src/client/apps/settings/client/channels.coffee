Backbone = require 'backbone'
_ = require 'underscore'
AutocompleteList = require '../../../components/autocomplete_list/index.coffee'
ImageUploadForm = require '../../../components/image_upload_form/index.coffee'
Channel = require '../../../models/channel.coffee'
sd = require('sharify').data
async = require 'async'
request = require 'superagent'
React = require 'react'
ReactDOM = require 'react-dom'

module.exports.EditChannel = class EditChannel extends Backbone.View

  events:
    'click .js--channel-save-metadata': 'saveMetadata'

  initialize: ->
    @channel = new Channel sd.CHANNEL
    @setupUserAutocomplete()
    @setupPinnedArticlesAutocomplete() if @channel.isTeam()
    @setupBackgroundImageForm() if @channel.isTeam()

  setupUserAutocomplete: ->
    @user_ids = @channel.get 'user_ids' or []
    props =
      name: 'user_ids[]'
      url: "#{sd.ARTSY_URL}/api/v1/match/users?term=%QUERY"
      placeholder: 'Search by user name or email...'
      filter: (users) -> for user in users
        { id: user.id, value: _.compact([user.name, user.email]).join(', ')}
      selected: (e, item, items) =>
        @channel.save user_ids: _.pluck items, 'id'
      removed: (e, item, items) =>
        @channel.save user_ids: _.without(_.pluck(items, 'id'),item.id)
      idsToFetch: @user_ids
      fetchUrl: (id) -> "#{sd.ARTSY_URL}/api/v1/user/#{id}"
      resObject: (res) -> {
        id: res.body.id,
        value: _.compact([res.body.name, res.body.email]).join(', ')
      }
    ReactDOM.render React.createElement(AutocompleteList, props), $('#channel-edit__users')[0]

  setupPinnedArticlesAutocomplete: ->
    @pinnedArticles = @channel.get('pinned_articles') or []
    props =
      name: 'pinned_articles[]'
      url: "#{sd.APP_URL}/api/articles?published=true&channel_id=#{@channel.get('id')}&q=%QUERY"
      placeholder: 'Search by article title...'
      draggable: true
      filter: (articles) -> for article in articles.results
        { id: article.id, value: article.thumbnail_title }
      selected: (e, item, items) =>
        @channel.save pinned_articles: @indexPinnedArticles items
      idsToFetch: @pinnedArticles
      fetchUrl: (id) -> "#{sd.APP_URL}/api/articles/#{id.id}"
      removed: (e, item, items) =>
        @channel.save pinned_articles: @indexPinnedArticles items
      resObject: (res) -> {
        id: res.body.id,
        value: res.body.thumbnail_title
      }
    ReactDOM.render React.createElement(AutocompleteList, props), $('#channel-edit__pinned-articles')[0]

  indexPinnedArticles: (items) ->
    _.map items, (item, i) ->
      index: i,
      id: item.id

  setupBackgroundImageForm: ->
    new ImageUploadForm
      el: $('#channel-edit__image')
      src: @channel.get('image_url')
      remove: =>
        @channel.save image_url: null
      done: (src) =>
        @channel.save image_url: src

  saveMetadata: ->
    $button = @$('.js--channel-save-metadata')
    data =
      slug: $('input[name=slug]').val()
      tagline: $('input[name=tagline]').val()
      links: @linkArray()
    $button.addClass('is-loading')
    @channel.save data,
      success: ->
        $button
          .removeClass('is-loading')
          .removeClass('is-error')
          .text 'Saved'
      error: ->
        $button
          .addClass('is-error')
          .removeClass('is-loading')
          .text 'Error Saving'

  linkArray: ->
    _(3).times (i) ->
      {
        text: $("input[name='links[#{i}][text]']").val()
        url: $("input[name='links[#{i}][url]']").val()
      }

module.exports.init = ->
  new EditChannel
    el: $('body')
