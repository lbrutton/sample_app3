class Micropost < ActiveRecord::Base
	belongs_to :user
	validates :user_id, presence: true
	validates :content, length: {maximum: 150}, presence: true
	default_scope(->{order('created_at DESC')}) #parenthesis are optional; default_scope takes a proc (with the arrow) as an argument, which
	# can be evalutated later with "call"
end
