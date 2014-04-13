# encoding: UTF-8

require 'spec_helper'

module RubyQuest
  describe Character do
    let(:character) { create :character }

    describe 'class methods and attributes' do
      subject { character.class }

      it { should respond_to :login }

      describe ':login' do
        context 'with invalid credentials' do
          let(:password) { 'not_correct_password' }
          before(:each) do
            @conn = double(
              'RubyQuest::Server',
              login: true,
              send_line: true
            ).as_null_object
            @conn.stub(:status)
          end

          it 'should return nil' do
            Character.login(
              name: character.name,
              password: password,
              connection: @conn
            ).should be_nil
          end

          it 'should send a failure message' do
            @conn.should receive(:send_line).with('Invalid credentials.')
            Character.login(
              name: character.name,
              password: password,
              connection: @conn
            )            
          end

          it 'should send the login message again' do
            @conn.should receive(:login)
            Character.login(
              name: character.name,
              password: password,
              connection: @conn
            )
          end
        end

        context 'with an unrecognised character name' do
          let(:name) { 'NotACreatedCharacter' }

          it 'should ask to create a new character' do
            pending 'Bloody annoying attribute set error.'
            @conn.should_receive(:send_line).with(
              "This character does not yet exist.\n" \
              "Create it? (Y/N)"
            )
            Character.login(
              name: name,
              password: character.password,
              connection: @conn
            )
          end
        end
      end
    end

    describe 'instance methods and attributes' do
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