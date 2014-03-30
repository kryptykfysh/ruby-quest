# encoding: UTF-8

require 'spec_helper'

module RubyQuest
  describe Character do
    let(:character) { create :character }

    describe 'methods and attributes' do
      it { should respond_to :name }      
    end
  end
end