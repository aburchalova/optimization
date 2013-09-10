class CreateMatrices < ActiveRecord::Migration
  def up
    create_table :matrices do |t|
      t.text :parsed

      t.timestamps
    end
  end

  def down
  end
end
