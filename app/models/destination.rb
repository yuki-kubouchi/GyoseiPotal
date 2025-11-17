class Destination < ApplicationRecord
  enum kind: { municipality: 0, prefecture: 1, national: 2, other: 9 }

  validates :name, presence: true, uniqueness: true
  validates :kind, presence: true

  before_validation do
    self.kind ||= :other
  end
end
