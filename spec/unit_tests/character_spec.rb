# encoding: UTF-8

require 'spec_helper'

module RubyQuest
  describe Character do
    let(:character) { create :character }

    describe 'methods and attributes' do
      it { should respond_to :name }
      it { should respond_to :connection }

      describe ':name' do
        context 'when not present' do
          let(:char2) { build :character, name: '' }
          subject { char2 }

          it { should_not be_valid }
        end

        context 'when not unique' do
          before { create :character }
          let(:char2) { build :character }
          subject { char2 }

          it { should_not be_valid }
        end 

        context 'when not unique by case' do
          before { create :character }
          let(:char2) { build :character, name: 'Test_Character' }
          subject { char2 }

          it { should_not be_valid }
        end 

        context 'on saving' do
          let(:name) { 'Capital_Letters' }
          let(:test_character) { build :character, name: name }
          subject { test_character }

          it 'should be downcased' do
            expect { test_character.save }.to change { test_character.name }.
              from(name).to(name.downcase)
          end
        end
      end
    end
  end
end