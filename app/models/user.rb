require 'uuidtools'

class User < ApplicationRecord
  has_many :favorite
  before_create :add_uuid

  def add_uuid
    self.uuid = UUIDTools::UUID.random_create.to_s
  end
end
