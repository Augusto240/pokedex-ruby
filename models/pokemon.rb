require 'active_record'

class Pokemon < ActiveRecord::Base
  validates :pokemon_id, presence: true, uniqueness: true
  validates :name, presence: true
end