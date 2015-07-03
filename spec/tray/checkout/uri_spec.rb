# encoding: UTF-8
require 'spec_helper'

describe URI do
  describe '#secure?' do
    subject { described_class.parse(url).secure? }

    context 'when scheme is HTTPS' do
      let(:url) { 'https://prodis.webstorelw.com.br' }
      it { is_expected.to be true }
    end

    context 'when scheme is HTTP' do
      let(:url) { 'http://prodis.blog.br' }
      it { is_expected.to be false }
    end
  end
end
