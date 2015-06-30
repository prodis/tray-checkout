# encoding: UTF-8
require 'spec_helper'

describe URI do
  describe "#ssl?" do
    context "when is SSL" do
      it "returns true" do
        uri = URI.parse("https://prodis.webstorelw.com.br")
        uri.ssl?.should be true
      end
    end

    context "when is not SSL" do
      it "returns false" do
        uri = URI.parse("http://prodis.blog.br")
        uri.ssl?.should be false
      end
    end
  end
end
