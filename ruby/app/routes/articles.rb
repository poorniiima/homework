require_relative '../controllers/articles'

class ArticleRoutes < Sinatra::Base
  use AuthMiddleware

  def initialize
    super
    @articleCtrl = ArticleController.new
  end

  before do
    content_type :json
  end

  get('/') do
    summary = @articleCtrl.get_batch

    if (summary[:ok])
      { articles: summary[:data] }.to_json
    else
      { msg: 'Could not get articles.' }.to_json
    end
  end

  get('/:id') do 
    summary = @articleCtrl.get_article(params['id'])

    if summary[:ok]
      { article: summary[:data] }.to_json
    else
      { msg: 'Article not found.' }.to_json
    end
  end

  post('/') do
    payload = JSON.parse(request.body.read)
    summary = @articleCtrl.create_article(payload)

    if summary[:ok]
      status 200
      { msg: 'Article created' }.to_json
    else
      { msg: summary[:msg] }.to_json
    end
  end

  put('/:id') do
    payload = JSON.parse(request.body.read)
    summary = @articleCtrl.update_article params['id'], payload

    if summary[:ok]
      status 200
      { msg: 'Article updated' }.to_json
    else
      { msg: summary[:msg] }.to_json
    end
  end

  delete('/:id') do
    summary = @articleCtrl.delete_article params['id']

    if summary[:ok]
      { msg: 'Article deleted' }.to_json
    else
      { msg: 'Article does not exist' }.to_json
    end
  end

  #bonus question
  get('/:id/comments') do
    comments = Comment.where(article_id: params['id']).map do |c|
      {
        id: c.id,
        content: c.content,
        author_name: c.author_name,
        created_at: c.created_at
      }
    end
    { comments: comments }.to_json
  end
  
  post('/:id/comments') do
    payload = JSON.parse(request.body.read)

    comment = Comment.create(
      article_id: params['id'],
      content: payload['content'],
      author_name: payload['author_name']
    )

    if comment.id
      { ok: true, comment_id: comment.id }.to_json
    else
      { ok: false, msg: 'Comment failed' }.to_json
    end    
  end
end
