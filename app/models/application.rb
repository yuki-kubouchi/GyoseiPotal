class Application < ApplicationRecord
  belongs_to :customer
  enum status: { draft: 0, submitted: 1, reviewing: 2, approved: 3, rejected: 4 }
  has_many_attached :documents
  has_many :invoices, dependent: :destroy
end
