class TestsController < ActionController::Base
  def index
    I18n.t('foo.bar')
    render plain: ''
  end
end
