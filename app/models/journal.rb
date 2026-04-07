class Journal < ApplicationRecord
  validates :date, :title, :content, presence: true
  validates :date, uniqueness: true
end
