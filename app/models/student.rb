class Student < ApplicationRecord
  VALID_EMAIL_REGEX  = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_PHONE_REGEX  = /\A\([0-9]{3}\) [0-9]{3}-[0-9]{4}\z/
  VALID_ZIP_REGEX    = /\A[0-9]{5}\z/
  VALID_SMARTT_REGEX = /\A[0-9]{4}-[0-9]{6}\z/
  LAST_NAME_ID_REGEX = /\A[0-9]{4,5}\z/

  has_many :affiliates
  has_many :assessments

  has_many :enrollments
  has_many :affiliates, through: :enrollments

  has_many :matches
  has_many :tutors, through: :matches

  has_many :student_comments

  has_many :taggings
  has_many :tags, through: :taggings

  validates :first_name, presence: true
  validates :gender, presence: true
  validates :last_name, presence: true

  validates :cell_phone, format: { with: VALID_PHONE_REGEX },
                         allow_blank: true
  validates :home_phone, format: { with: VALID_PHONE_REGEX },
                         allow_blank: true
  validates :last_name_id, format: { with: LAST_NAME_ID_REGEX },
                           allow_blank: true
  validates :work_phone, format: { with: VALID_PHONE_REGEX },
                         allow_blank: true
  validates :other_phone, format: { with: VALID_PHONE_REGEX },
                          allow_blank: true
  validates :emergency_contact_phone,  format: { with: VALID_PHONE_REGEX },
                                       allow_blank: true
  validates :smartt_id, format: { with: VALID_SMARTT_REGEX },
                        allow_blank: true
  validates :zip, format: { with: VALID_ZIP_REGEX },
                  allow_blank: true
  validates :email, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false },
                    allow_blank: true

  def name
    [first_name, last_name].join(' ')
  end

  def current_availability_array
    availability ? PreferencesHelper.explode(availability) : []
  end

  def age_preference_array
    age_preference ? PreferencesHelper.explode(age_preference) : []
  end

  def transportation_preference_array
    transportation ? PreferencesHelper.explode(transportation) : []
  end

  def all_tags=(names)
    self.tags = names.reject(&:empty?).uniq.map do |name|
      Tag.where(name: name.strip).first_or_create!
    end
  end

  def all_tags
    tags.map(&:name)
  end

  def active_affiliate
    Affiliate.find(enrollments.where(end: nil).take.affiliate_id)
  end

  def deleted_by_email
    User.find(deleted_by).email
  end

  # rubocop:disable CyclomaticComplexity, PerceivedComplexity
  def status_class_indicator
    active  = ['Active']
    info    = ['Waiting for re-match', 'Waiting for 1st match', 'On hold']
    warning = ['Declined match', 'Unable to contact', 'Cannot match', 'Moved']
    danger  = ['Exited', 'No show to appointment', 'Dropped out of training']

    klass = ('success' if active.include? status)  ||
            ('info'    if info.include? status)    ||
            ('warning' if warning.include? status) ||
            ('danger'  if danger.include? status)
    klass
  end

  def self.of(user)
    if user.tutor?
      joins(:matches).where(matches: { tutor_id: 1 })
    elsif user.coordinator?
      joins(:enrollments).where(
        enrollments: {
          affiliate_id: Coordinator.find(user.coordinator_id).affiliate_id
        }
      ).where(deleted_on: nil)
    else
      all
    end
  end

  def self.deleted_of(user)
    where.not(deleted_on: nil) if user.admin?
  end

  def self.to_csv
    attributes = Student.column_names
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |student|
        csv << student.attributes.values_at(*attributes)
      end
    end
  end
end
