class Journal < ApplicationRecord
  validates :date, :title, :content, presence: true
end
