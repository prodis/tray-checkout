# encoding: UTF-8
module URI
  def secure?
    self.scheme == 'https'
  end
end
