class Task < ApplicationRecord
  validates :title, :start_at, presence: true
  validate :check_start_at

  def check_start_at
    if start_at.present? && start_at < Time.now
      errors.add(:start_at, "過去の時間は指定できません")
    end
  end
end
