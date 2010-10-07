ActiveRecord::Schema.define(:version => 0) do

  create_table :pictures, :force => true do |t|
    t.string  :subtitle
    t.string  :album
    t.boolean :cover
    t.time    :last_marked_at
    t.timestamps
  end

end