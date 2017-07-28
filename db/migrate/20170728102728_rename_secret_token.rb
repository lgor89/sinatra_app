class RenameSecretToken < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :secret_token, :access_token
  end
end
