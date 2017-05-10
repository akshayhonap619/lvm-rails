class Tutor < ApplicationRecord
  VALID_EMAIL_REGEX  = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_PHONE_REGEX  = /\A\([0-9]{3}\) [0-9]{3}-[0-9]{4}\z/
  VALID_ZIP_REGEX    = /\A[0-9]{5}\z/
  VALID_SMARTT_REGEX = /\A[0-9]{4}-[0-9]{6}\z/
  LAST_NAME_ID_REGEX = /\A[0-9]{4,5}\z/

  belongs_to :user

  has_many :matches
  has_many :students, through: :matches

  has_many :volunteer_jobs
  has_many :affiliates, through: :volunteer_jobs

  has_many :tutor_comments

  has_many :taggings
  has_many :tags, through: :taggings

  validates :address1,                presence: true
  validates :address2,                presence: true
  validates :cell_phone,              presence: true
  validates :city,                    presence: true
  validates :country_of_birth,        presence: true
  validates :date_of_birth,           presence: true
  validates :email_preferred,         presence: true
  validates :emergency_contact_email, presence: true
  validates :emergency_contact_name,  presence: true
  validates :emergency_contact_phone, presence: true
  validates :first_name,              presence: true
  validates :home_phone,              presence: true
  validates :language_proficiencies,  presence: true
  validates :last_name,               presence: true
  validates :native_language,         presence: true
  validates :occupation,              presence: true
  validates :race,                    presence: true
  validates :state,                   presence: true
  validates :zip,                     presence: true

  # can't use presence: true for bool
  validates_inclusion_of :hispanic_or_latino, in: [true, false]

  validates :cell_phone,   format: { with: VALID_PHONE_REGEX }
  validates :home_phone,   format: { with: VALID_PHONE_REGEX }
  validates :last_name_id, format: { with: LAST_NAME_ID_REGEX },
                           allow_blank: true
  validates :other_phone,  format: { with: VALID_PHONE_REGEX },
                           allow_blank: true
  validates :smartt_id,    format: { with: VALID_SMARTT_REGEX },
                           allow_blank: true
  validates :zip,          format: { with: VALID_ZIP_REGEX }

  validates :email_preferred, length: { maximum: 255 },
                              format: { with: VALID_EMAIL_REGEX },
                              uniqueness: { case_sensitive: false }
  validates :email_other, length: { maximum: 255 },
                          format: { with: VALID_EMAIL_REGEX },
                          uniqueness: { case_sensitive: false },
                          allow_blank: true
  validates :emergency_contact_email, length: { maximum: 255 },
                                      format: { with: VALID_EMAIL_REGEX },
                                      uniqueness: { case_sensitive: false },
                                      allow_blank: true
  def name
    [first_name, last_name].join(' ')
  end

  def current_availability_array
    availability ? PreferencesHelper.explode(availability) : []
  end

  def category_preference_array
    category_preference ? PreferencesHelper.explode(category_preference) : []
  end

  def age_preference_array
    age_preference ? PreferencesHelper.explode(age_preference) : []
  end

  def transportation_preference_array
    transportation ? PreferencesHelper.explode(transportation) : []
  end

  def deleted_by_email
    User.find(deleted_by).email
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
    Affiliate.find(volunteer_jobs.where(end: nil).take.affiliate_id)
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
      where(id: user.tutor_id) # Needs to be a relation, not a single record
    elsif user.coordinator?
      joins(:volunteer_jobs).where(
        volunteer_jobs: {
          affiliate_id: Coordinator.find(user.coordinator_id).affiliate_id
        }
      ).where(deleted_on: nil)
    elsif user.admin?
      all
    end
  end

  def self.deleted_of(user)
    where.not(deleted_on: nil) if user.admin?
  end

  def self.to_csv
    attributes = Tutor.column_names
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |tutor|
        csv << tutor.attributes.values_at(*attributes)
      end
    end
  end
end
