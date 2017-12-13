class TutorsController < ApplicationController
  before_action :ensure_coordinator_or_admin!
  before_action :set_tutor, only: [:show, :edit]

  add_breadcrumb 'Home', :root_path

  def index
    add_breadcrumb 'Tutors'

    @new_button = {
      text: 'Create New Tutor',
      url: new_tutor_path
    }
    @clickable_rows = true
    @page_title = 'Tutors'
    @models = Tutor.of(current_user).where(deleted_on: nil)
    @headers = [
      'First Name',
      'Last Name',
      'Status',
      'Home Phone',
      'Cell Phone',
      'Email'
    ]
    @columns = [
      'first_name',
      'last_name',
      'status',
      'home_phone',
      'cell_phone',
      'email_preferred'
    ]
    @download_button = {
      text: 'Download All',
      url: tutors_path(format: :csv)
    }
    respond_to do |format|
      format.html
      # rubocop:disable LineLength
      format.csv { send_data @models.to_csv, filename: "tutors-#{Date.today}.csv" }
      # rubocop:enable LineLength
    end
  end

  def deleted_index
    ensure_admin!
    add_breadcrumb 'Deleted Tutors'

    @clickable_rows = true
    @page_title = 'Deleted Tutors'
    @models = Tutor.deleted_of(current_user)
    @headers = [
      'First Name',
      'Last Name',
      'Deleted On',
      'Deleted By'
    ]
    @columns = [
      'first_name',
      'last_name',
      'deleted_on',
      'deleted_by_email'
    ]
  end

  def show
    if @tutor.deleted_on
      add_breadcrumb 'Deleted Tutors', deleted_tutors_path
    else
      add_breadcrumb 'Tutors', tutors_path
      @students = students
      @student_options = student_options
    end
    add_breadcrumb @tutor.name

    @user = User.where(tutor_id: @tutor.id).take
  end

  def reinstate
    @tutor = Tutor.of(current_user).find(params[:id])
    @tutor.update(
      deleted_on: nil,
      deleted_by: nil
    )

    redirect_to @tutor
  end

  def delete
    @tutor = Tutor.of(current_user).find(params[:id])
    unmatch_all_matches
    @tutor.update(
      deleted_on: Date.today,
      deleted_by: current_user.id
    )

    if current_user.admin?
      redirect_to @tutor
    else
      redirect_to tutors_path
    end
  end

  def update_tags
    @tutor = Tutor.of(current_user).find(params[:id])
    @tutor.all_tags = params[:tutor][:all_tags]

    redirect_to tutor_path(@tutor)
  end

  def new
    add_breadcrumb 'Tutors', tutors_path
    add_breadcrumb 'New Tutor'

    @tutor = Tutor.new
  end

  def edit
    add_breadcrumb 'Tutors', tutors_path
    add_breadcrumb @tutor.name, tutor_path(@tutor)
    add_breadcrumb 'Edit'
  end

  def create
    calculate_preferences(params)
    clean_params = update_params_with_proficiencies(tutor_params.clone, params)
    @tutor = Tutor.new(clean_params)

    if @tutor.save
      redirect_to @tutor
    else
      render 'new'
    end
  end

  def update
    calculate_preferences(params)
    clean_params = update_params_with_proficiencies(tutor_params.clone, params)
    @tutor = Tutor.of(current_user).find(params[:id])

    if @tutor.update(clean_params)
      redirect_to @tutor
    else
      render 'edit'
    end
  end

  def destroy
    @tutor = Tutor.of(current_user).find(params[:id])
    @tutor.destroy

    redirect_to tutors_path
  end

  def add_student
    student_id = params[:student_id]
    tutor_id = params[:tutor_id]
    Match.create(student_id: student_id, tutor_id: tutor_id, start: Date.today)
    redirect_to Tutor.of(current_user).find(tutor_id)
  end

  def remove_student
    student_id = params[:student_id]
    tutor_id = params[:tutor_id]
    Match.where(student_id: student_id,
                tutor_id: tutor_id).update(end: Date.today)
    redirect_to Tutor.of(current_user).find(tutor_id)
  end

  private

  def tutor_params
    params.require(:tutor).permit(
      :address1,
      :address2,
      :age_preference,
      :availability,
      :category_preference,
      :cell_phone,
      :city,
      :colleges_attended,
      :country_leave_date,
      :country_of_birth,
      :country_return_date,
      :criminal_conviction,
      :date_of_birth,
      :education,
      :educational_accomplishments,
      :email_other,
      :email_preferred,
      :emergency_contact_email,
      :emergency_contact_name,
      :emergency_contact_phone,
      :employer_name,
      :employment_status,
      :first_name,
      :gender,
      :hispanic_or_latino,
      :hobbies,
      :home_phone,
      :intake_date,
      :language_proficiencies,
      :last_name_id,
      :last_name,
      :meet_at_local_library,
      :native_language,
      :occupation,
      :orientation_date,
      :other_phone,
      :other_preferences,
      :past_occupation,
      :preferred_contact_class_listing,
      :preferred_contact_data_collection,
      :preferred_contact_method,
      :preferred_student_level,
      :previous_teaching_experience,
      :previous_volunteer_experience,
      :race,
      :reference,
      :referral_other,
      :referral,
      :release_on_file,
      :release_sign_date,
      :smartt_id,
      :state,
      :status_changed_by,
      :status_date_of_change,
      :status,
      :teachable_subjects,
      :training_date,
      :training_type,
      :training,
      :transportation,
      :where_can_meet,
      :zip,
      all_tags: []
    )
  end

  def students
    match_params = { tutor_id: params[:id], end: nil }
    Match.where(match_params).to_a.map do |m|
      Student.of(current_user).find(m.student_id)
    end
  end

  def student_options
    matched_student_ids = Match.where(end: nil).to_a.map(&:student_id)
    all_students_arr =
      Student.of(current_user).where(deleted_on: nil).joins(:enrollments).where(
        enrollments: {
          affiliate_id: @tutor.active_affiliate.id
        }
      ).order(:first_name).to_a
    untutored_students = all_students_arr
                         .reject { |s| matched_student_ids.include? s.id }
    untutored_students.map { |t| [t.name, t.id] }
  end

  def calculate_preferences(params)
    times = params[:tutor][:availability]
    age = params[:tutor][:age_preference]
    category = params[:tutor][:category_preference]
    transportation = params[:tutor][:transportation]

    params[:tutor][:availability] = PreferencesHelper.squash(times)
    params[:tutor][:age_preference] = PreferencesHelper.squash(age)
    params[:tutor][:category_preference] = PreferencesHelper.squash(category)
    params[:tutor][:transportation] = PreferencesHelper.squash(transportation)
  end

  def update_params_with_proficiencies(clean_params, params)
    clean_params['language_proficiencies'] =
      params.to_unsafe_h['language_proficiencies'].to_json ||
      params['tutor']['language_proficiencies'].to_json
    clean_params
  end

  def unmatch_all_matches
    Match.where(tutor_id: @tutor, end: nil).each do |m|
      m.update(end: Date.today)
    end
  end

  def set_tutor
    @tutor = Tutor.of(current_user).find(params[:id])
  end
end
