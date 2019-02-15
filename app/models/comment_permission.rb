class CommentPermission < ApplicationRecord
  belongs_to :comment
  belongs_to :role
end
