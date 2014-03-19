# encoding:UTF-8

require 'spec_helper'

module RubyQuest
  describe Server do
    let(:server) { build :server }

    describe 'methods and attributes' do
      subject { server }

      its(:class) { should respond_to :connected_clients }
    end
  end
end