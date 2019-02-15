class Role < ApplicationRecord
# has_and_belongs_to_many :users, :join_table => :users_roles
has_many :users_roles
has_many :users, through: :users_roles
has_many :comment_permissions
has_many :comments, through: :comment_permissions
has_many :promocode_roles
has_many :promocodes, through: :promocode_roles
has_many :releases_roles
has_many :releases, through: :releases_roles


belongs_to :resource,
           :polymorphic => true,
           :optional => true


validates :resource_type,
          :inclusion => { :in => Rolify.resource_types },
          :allow_nil => true

scopify
end
