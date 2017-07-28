class AddSecretToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :secret_token, :string
  end
end
