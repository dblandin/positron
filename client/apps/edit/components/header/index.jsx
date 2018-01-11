import PropTypes from 'prop-types'
import React, { Component } from 'react'
import Icon from '@artsy/reaction-force/dist/Components/Icon'
import colors from '@artsy/reaction-force/dist/Assets/Colors'

export class EditHeader extends Component {
  static propTypes = {
    actions: PropTypes.any,
    article: PropTypes.object,
    channel: PropTypes.object,
    edit: PropTypes.object,
    user: PropTypes.object
  }

  toggleSection = (activeView) => {
    // TODO - connect component to use redux actions directly
    this.props.actions.changeView(activeView)
  }

  isPublishable = () => {
    const { article } = this.props
    return article.finishedContent() && article.finishedThumbnail()
  }

  onPublish = () => {
    const { actions, article } = this.props

    if (this.isPublishable()) {
      actions.publishArticle(
        article,
        !article.get('published')
      )
    }
  }

  onDelete = () => {
    const { actions, article } = this.props

    if (confirm('Are you sure?')) {
      actions.deleteArticle(article)
    }
  }

  getSaveColor = () => {
    const { isSaving, isSaved } = this.props.edit

    if (isSaving) {
      return colors.greenRegular
    } else if (isSaved) {
      return 'black'
    } else {
      return colors.redMedium
    }
  }

  getSaveText = () => {
    const { article, edit } = this.props
    const { isSaving } = edit

    if (isSaving) {
      return 'Saving...'
    } else if (article.get('published')) {
      return 'Save Article'
    } else {
      return 'Save Draft'
    }
  }

  getPublishText = () => {
    const { article, edit } = this.props
    const { isPublishing } = edit
    const isPublished = article.get('published')

    if (isPublishing && isPublished) {
      return 'Publishing...'
    } else if (isPublishing) {
      return 'Unpublishing...'
    } else if (isPublished) {
      return 'Unpublish'
    } else {
      return 'Publish'
    }
  }

  render () {
    const { article, actions, channel, user } = this.props
    const { activeSection, isDeleting } = this.props.edit
    const { grayMedium, greenRegular } = colors

    return (
      <div className='EditHeader'>

        <div className='EditHeader__left'>
          <div className='EditHeader__tabs'>
            <button
              className='avant-garde-button check'
              onClick={() => this.toggleSection('content')}
              data-active={activeSection === 'content'}
            >
              <span>Content</span>
              <Icon
                className='icon'
                name='check'
                color={article.finishedContent() ? greenRegular : grayMedium}
              />
            </button>

            <button
              className='avant-garde-button check'
              onClick={() => this.toggleSection('display')}
              data-active={activeSection === 'display'}
            >
              <span>Display</span>
              <Icon
                className='icon'
                name='check'
                color={article.finishedThumbnail() ? greenRegular : grayMedium}
              />
            </button>

            {user.type === 'Admin' &&
              <button
                className='avant-garde-button'
                onClick={() => this.toggleSection('admin')}
                data-active={activeSection === 'admin'}
              >
                Admin
              </button>
            }
          </div>

          <div>
            <button
              className='avant-garde-button publish'
              data-disabled={!this.isPublishable()}
              onClick={this.onPublish}
            >
              {this.getPublishText()}
            </button>

            {channel.get('type') === 'editorial' &&
              <button
                className='avant-garde-button autolink'
              >
                Auto-link
              </button>
            }
          </div>
        </div>

        <div className='EditHeader__right'>
          <button
            className='avant-garde-button delete'
            onClick={this.onDelete}
          >
            {isDeleting ? 'Deleting...' : 'Delete'}
          </button>

          <button
            className='avant-garde-button'
            style={{color: this.getSaveColor()}}
            onClick={() => article.get('published')
              ? article.trigger('savePublished')
              : actions.saveArticle(article)
            }>
            {this.getSaveText()}
          </button>

          <a href={article.getFullSlug()} target='_blank'>
            <button className='avant-garde-button'>
              {article.get('published') ? 'View' : 'Preview'}
            </button>
          </a>
        </div>

      </div>
    )
  }
}
