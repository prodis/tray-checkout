# encoding: UTF-8
module URI
  def ssl?
    self.port == 443
  end
end
