module SeedLoader
  class Loader
    def load_seed
      RubyQuest::Character.create(name: 'Test Character')
    end
  end
end
