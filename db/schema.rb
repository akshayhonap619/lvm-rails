# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171010022437) do

  create_table "affiliates", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "phone_number"
    t.string   "email"
    t.string   "website"
    t.string   "twitter"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "zip"
    t.string   "state"
    t.string   "city"
    t.string   "tags"
  end

  create_table "assessments", force: :cascade do |t|
    t.string   "score"
    t.date     "date"
    t.string   "category"
    t.integer  "student_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "name"
    t.string   "level"
    t.string   "assessment_type"
    t.index ["student_id"], name: "index_assessments_on_student_id"
  end

  create_table "coordinators", force: :cascade do |t|
    t.string   "first_name"
    t.string   "email"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "affiliate_id"
    t.string   "phone_number"
    t.date     "date_of_birth"
    t.string   "last_name"
    t.index ["affiliate_id"], name: "index_coordinators_on_affiliate_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "affiliate_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.date     "start"
    t.date     "end"
    t.index ["affiliate_id"], name: "index_enrollments_on_affiliate_id"
    t.index ["student_id"], name: "index_enrollments_on_student_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "tutor_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.date     "start"
    t.date     "end"
    t.integer  "affiliate_id"
    t.index ["affiliate_id"], name: "index_matches_on_affiliate_id"
    t.index ["student_id"], name: "index_matches_on_student_id"
    t.index ["tutor_id"], name: "index_matches_on_tutor_id"
  end

  create_table "student_comments", force: :cascade do |t|
    t.integer  "student_id"
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_student_comments_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "first_name",                    null: false
    t.string   "last_name",                     null: false
    t.date     "date_of_birth"
    t.string   "gender",                        null: false
    t.string   "address1"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.boolean  "mail_ok"
    t.string   "email"
    t.boolean  "email_ok"
    t.string   "cell_phone"
    t.boolean  "cell_ok"
    t.boolean  "cell_lvm_ok"
    t.string   "home_phone"
    t.boolean  "home_ok"
    t.boolean  "home_lvm_ok"
    t.string   "work_phone"
    t.boolean  "work_ok"
    t.boolean  "work_lvm_ok"
    t.string   "other_phone"
    t.string   "emergency_contact_name"
    t.string   "emergency_contact_phone"
    t.string   "referral"
    t.text     "why_lvm"
    t.string   "race"
    t.boolean  "hispanic_or_latino"
    t.string   "native_language"
    t.string   "country_of_birth"
    t.integer  "availability"
    t.string   "address2"
    t.integer  "smartt_id"
    t.string   "status"
    t.string   "status_date_of_change"
    t.string   "status_changed_by"
    t.string   "last_name_id"
    t.string   "preferred_contact_method"
    t.string   "immigrant_status"
    t.string   "education"
    t.text     "core_service_request"
    t.text     "additional_service_request"
    t.boolean  "criminal_conviction"
    t.boolean  "release_on_file"
    t.date     "release_sign_date"
    t.boolean  "cdbg_required"
    t.boolean  "cdbg_us_citizen"
    t.boolean  "cdbg_legal_resident"
    t.boolean  "cdbg_female_head_of_household"
    t.integer  "cdbg_household_size"
    t.integer  "cdbg_household_income"
    t.date     "intake_date"
    t.integer  "age_preference"
    t.boolean  "meet_at_local_library"
    t.string   "where_can_meet"
    t.integer  "transportation"
    t.string   "other_preferences"
    t.string   "referral_other"
    t.date     "deleted_on"
    t.integer  "deleted_by"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "tutor_id"
    t.integer  "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_taggings_on_student_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["tutor_id"], name: "index_taggings_on_tutor_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tutor_comments", force: :cascade do |t|
    t.integer  "tutor_id"
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tutor_id"], name: "index_tutor_comments_on_tutor_id"
  end

  create_table "tutoring_sessions", force: :cascade do |t|
    t.string   "location"
    t.text     "session_comment"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "hours"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "match_id"
  end

  create_table "tutors", force: :cascade do |t|
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "email_preferred",                   null: false
    t.string   "first_name",                        null: false
    t.string   "last_name",                         null: false
    t.string   "address1",                          null: false
    t.string   "city",                              null: false
    t.string   "state",                             null: false
    t.string   "zip",                               null: false
    t.string   "home_phone",                        null: false
    t.string   "cell_phone",                        null: false
    t.string   "gender"
    t.string   "native_language",                   null: false
    t.string   "race",                              null: false
    t.string   "training_type"
    t.string   "referral"
    t.string   "education"
    t.string   "employment_status"
    t.string   "occupation",                        null: false
    t.date     "orientation_date"
    t.date     "training_date"
    t.date     "date_of_birth",                     null: false
    t.string   "other_phone"
    t.date     "intake_date"
    t.string   "email_other"
    t.string   "address2",                          null: false
    t.string   "emergency_contact_name",            null: false
    t.string   "emergency_contact_phone",           null: false
    t.string   "emergency_contact_email",           null: false
    t.string   "preferred_contact_method"
    t.string   "preferred_contact_class_listing"
    t.string   "preferred_contact_data_collection"
    t.string   "status"
    t.string   "status_date_of_change"
    t.string   "status_changed_by"
    t.string   "smartt_id"
    t.string   "last_name_id"
    t.string   "employer_name"
    t.string   "past_occupation"
    t.text     "colleges_attended"
    t.text     "educational_accomplishments"
    t.text     "previous_teaching_experience"
    t.text     "previous_volunteer_experience"
    t.text     "teachable_subjects"
    t.text     "hobbies"
    t.string   "reference"
    t.text     "language_proficiencies",            null: false
    t.boolean  "hispanic_or_latino",                null: false
    t.string   "country_of_birth",                  null: false
    t.date     "country_leave_date"
    t.date     "country_return_date"
    t.boolean  "criminal_conviction"
    t.boolean  "release_on_file"
    t.date     "release_sign_date"
    t.string   "referral_other"
    t.integer  "availability"
    t.integer  "age_preference"
    t.integer  "category_preference"
    t.boolean  "meet_at_local_library"
    t.string   "where_can_meet"
    t.integer  "transportation"
    t.string   "preferred_student_level"
    t.string   "other_preferences"
    t.date     "deleted_on"
    t.integer  "deleted_by"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "role",                   default: 0
    t.integer  "tutor_id"
    t.integer  "coordinator_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "volunteer_jobs", force: :cascade do |t|
    t.integer  "tutor_id"
    t.integer  "affiliate_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.date     "start"
    t.date     "end"
    t.index ["affiliate_id"], name: "index_volunteer_jobs_on_affiliate_id"
    t.index ["tutor_id"], name: "index_volunteer_jobs_on_tutor_id"
  end

end
