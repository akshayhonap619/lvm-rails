class Affiliate < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_ZIP_REGEX = /\A[0-9]{5}\z/

  has_many :coordinators

  has_many :volunteer_jobs
  has_many :tutors, through: :volunteer_jobs

  has_many :enrollments
  has_many :students, through: :enrollments

  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :name, presence: true, length: { maximum: 100 }
  validates :address, presence: true, length: { maximum: 200 }
  validates :phone_number, presence: true, length: { maximum: 14 }
  validates :zip, presence: true, format: { with: VALID_ZIP_REGEX }
  validates :state, presence: true
  validates :city, presence: true


  def full_address
    "#{address}, #{city} #{state}, #{zip}"
  end
end
