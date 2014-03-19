class CreateTableCharacters < ActiveRecord::Migration
  def change
    create_table :characters do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :characters,
      [:name],
      {
        name: 'characters_name_index',
        unique: true,
        order: { name: :desc }
      }
  end
end
