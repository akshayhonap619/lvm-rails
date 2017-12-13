class StudentsController < ApplicationController
  before_action :ensure_coordinator_or_admin!
  before_action :set_student, only: [:show, :edit, :match, :makematch]
  helper_method :tutor?

  add_breadcrumb 'Home', :root_path

  def index
    add_breadcrumb 'Students'

    @assessments_button = {
      text: 'View All Assessments',
      url: assessments_path
    }

    @new_button = {
      text: 'Create New Student',
      url: new_student_path
    }
    @clickable_rows = true
    @page_title = 'Students'
    @models = Student.of(current_user).where(deleted_on: nil)
    @headers = [
      'First Name',
      'Last Name',
      'Email',
      'Home Phone',
      'Cell Phone',
      'Work Phone'
    ]
    @columns = [
      'first_name',
      'last_name',
      'email',
      'home_phone',
      'cell_phone',
      'work_phone'
    ]
    @download_button = {
      text: 'Download All',
      url: students_path(format: :csv)
    }
    respond_to do |format|
      format.html
      # rubocop:disable LineLength
      format.csv { send_data @models.to_csv, filename: "students-#{Date.today}.csv" }
      # rubocop:enable LineLength
    end
  end

  def deleted_index
    ensure_admin!
    add_breadcrumb 'Deleted Students'

    @clickable_rows = true
    @page_title = 'Deleted Students'
    @models = Student.deleted_of(current_user)
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
    if @student.deleted_on
      add_breadcrumb 'Deleted Students', deleted_students_path
    else
      add_breadcrumb 'Students', students_path
      @tutor_options = tutor_options
      @match = current_match(params[:id])
    end
    add_breadcrumb @student.name
  end

  def new
    add_breadcrumb 'Students', students_path
    add_breadcrumb 'New Student'

    @student = Student.new
  end

  def edit
    add_breadcrumb 'Students', students_path
    add_breadcrumb @student.name, student_path(@student)
    add_breadcrumb 'Edit'

    @can_edit = !current_user.role.zero?
  end

  def match
    @tutor_options = match_options

    @student_availablity = @student.current_availability_array
    @student_availablity_size = @student.current_availability_array.length

    @student_preferences = @student.age_preference_array

    @age = age(@student.date_of_birth)
    @gender = @student.gender

    @tutor_options.each do |model|
      @tutor_availability = model[1];
      @score = 0
      @tutor_availability_size = @tutor_availability.length;
      @size = @tutor_availability_size < @student_availablity_size ? @tutor_availability_size : @student_availablity_size
      @size.times do |i|
        if @tutor_availability[i] == @student_availablity[i] && @tutor_availability[i]!=0
          model[3] = model[3] + 1;
        end
      end
        @tutor_preferences = model[2]
        @tutor_preferences.length.times do |i|
          case i
          when 0
              model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "male" && @age < 20)

          when 1
            model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "male" && @age >= 20 && @age<=25)

          when 2
            model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "male" && @age >= 26 && @age<=35)

          when 3
            model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "male" && @age >= 36 && @age<=45)

          when 4
            model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "male" && @age >= 46 && @age<=55)

          when 5
            model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "male" && @age >= 56 && @age<=65)

          when 6
            model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "male" && @age >= 66)

          when 7
              model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "female" && @age < 20)

          when 8
            model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "female" && @age >= 20 && @age<=25)

          when 9
            model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "female" && @age >= 26 && @age<=35)

          when 10
            model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "female" && @age >= 36 && @age<=45)

          when 11
            model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "female" && @age >= 46 && @age<=55)

          when 12
            model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "female" && @age >= 56 && @age<=65)

          when 13
            model[8] = model[8] || (@tutor_preferences[i] !=0 && @gender == "female" && @age >= 66)
          end
        end

    #  model[3] = @score
      model[7] = model[7] && @student.meet_at_local_library ? "Yes" : "No"
      model[8] = model[8] == true ? "Yes" : "No"
    end

    #Sort the tutors array by scores
    @tutor_options = @tutor_options.sort_by{|t| -t[3]}


    @clickable_rows= true

    @headers = [
      'First Name',
      'Last Name',
      '# of Matching Slots',
      'Can both Meet at Library',
      'Do Age Preferences Match',
      'Start Matching'
    ]
    @page_title = 'Matches'
    @view_students_button = {
      text: 'View Students',
    # url: new_student_path
      url: ''
    }

    @create_match_button = {
      text: 'Create Match'
    #,url:""
    }

  end


  def create
    calculate_preferences(params)
    @student = Student.new(student_params)

    if @student.save
      redirect_to @student
    else
      render 'new'
    end
  end

  def update
    calculate_preferences(params)
    @student = Student.of(current_user).find(params[:id])

    if @student.update(student_params)
      redirect_to @student
    else
      render 'edit'
    end
  end

  def update_tags
    @student = Student.of(current_user).find(params[:id])
    @student.all_tags = params[:student][:all_tags]

    redirect_to tutor_path(@student)
  end

  def reinstate
    @student = Student.of(current_user).find(params[:id])
    @student.update(
      deleted_on: nil,
      deleted_by: nil
    )

    redirect_to @student
  end

  def delete
    @student = Student.of(current_user).find(params[:id])
    unmatch_current_tutor(@student)
    @student.update(
      deleted_on: Date.today,
      deleted_by: current_user.id
    )

    if current_user.admin?
      redirect_to @student
    else
      redirect_to students_path
    end
  end

  def destroy
    @student = Student.of(current_user).find(params[:id])
    @student.destroy

    redirect_to students_path
  end

  def set_tutor
    tutor_id = params[:tutor_id].to_i
    student_id = params[:student_id].to_i
    if should_update_tutor(student_id, tutor_id)
      unmatch_current_tutor(student_id)
      start_match_with_tutor(student_id, tutor_id) if tutor_id != 0
    end
    redirect_to Student.of(current_user).find(student_id)
  end

  def set_tutor1(student_id, tutor_id)
    if should_update_tutor(student_id, tutor_id)
      unmatch_current_tutor(student_id)
      start_match_with_tutor(student_id, tutor_id) if tutor_id != 0
    end
  #  redirect_to Student.of(current_user).find(student_id)
  #  redirect_to matches_path
  #  return
  end

  private

  def calculate_preferences(params)
    times = params[:student][:availability]
    age = params[:student][:age_preference]
    transportation = params[:student][:transportation]

    params[:student][:availability] = PreferencesHelper.squash(times)
    params[:student][:age_preference] = PreferencesHelper.squash(age)
    params[:student][:transportation] = PreferencesHelper.squash(transportation)
  end

  def student_params
    params.require(:student).permit(
      :first_name,
      :last_name,
      :date_of_birth,
      :gender,
      :address1,
      :address2,
      :city,
      :state,
      :zip,
      :mail_ok,
      :email,
      :email_ok,
      :cell_phone,
      :cell_ok,
      :cell_lvm_ok,
      :home_phone,
      :home_ok,
      :home_lvm_ok,
      :work_phone,
      :work_ok,
      :work_lvm_ok,
      :other_phone,
      :emergency_contact_name,
      :emergency_contact_phone,
      :referral,
      :referral_other,
      :why_lvm,
      :race,
      :hispanic_or_latino,
      :native_language,
      :country_of_birth,
      :availability,
      :smartt_id,
      :status,
      :status_date_of_change,
      :status_changed_by,
      :last_name_id,
      :preferred_contact_method,
      :immigrant_status,
      :education,
      :core_service_request,
      :additional_service_request,
      :criminal_conviction,
      :release_on_file,
      :release_sign_date,
      :cdbg_required,
      :cdbg_us_citizen,
      :cdbg_legal_resident,
      :cdbg_female_head_of_household,
      :cdbg_household_size,
      :cdbg_household_income,
      :intake_date,
      :age_preference,
      :meet_at_local_library,
      :where_can_meet,
      :transportation,
      :other_preferences,
      :referral_other,
      all_tags: []
    )
  end

  def set_student
    @student = Student.of(current_user).find(params[:id])
  end

  def tutor_options
    tutors =
      Tutor.of(current_user).where(deleted_on: nil)
           .joins(:volunteer_jobs).where(
             volunteer_jobs: {
               affiliate_id: @student.active_affiliate.id
             }
           ).order(:first_name).to_a.map { |t| [t.name, t.id] }
    tutors.insert(0, ['No Tutor', 0])
  end

  def match_options
    tutors =
      Tutor.of(current_user).where(deleted_on: nil)
           .joins(:volunteer_jobs).where(
             volunteer_jobs: {
               affiliate_id: @student.active_affiliate.id
             }
           ).order(:id).to_a.map { |t| [t.id, t.availability ? PreferencesHelper.explode(t.availability) : [], t.age_preference ? PreferencesHelper.explode(t.age_preference) : [], 0,t.first_name,t.last_name,t.gender,t.meet_at_local_library,false] }
  end

def get_tutor(tutor_id)
  tutors = Tutor.where(id: tutor_id)
    .order(:id).to_a.map { |t| [t.id, t.availability ? PreferencesHelper.explode(t.availability) : []]}
end

# Calculate age of student from date of birth
def age(dob)
  now = Time.now.utc.to_date
  now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
end

#delete later if not used
def get_tutor1(tutor_id)
  tutors =
    Tutor.where(id: tutor_id)
         .joins(:volunteer_jobs).where(
           volunteer_jobs: {
             affiliate_id: @student.active_affiliate.id
           }
         ).order(:id).to_a.map { |t| [t.id, t.availability ? PreferencesHelper.explode(t.availability) : []] }

end

  def should_update_tutor(student_id, tutor_id)
    # If the selection was "No tutor" (id is 0)
    # or the student doesn't have a tutor
    # or the student does have one and this tutor isn't it
    tutor_id.zero? ||
      !current_match(student_id) ||
      (tutor_id != 0 && tutor_is_existing_tutor(student_id, tutor_id))
  end

  def tutor_is_existing_tutor(student_id, tutor_id)
    current_tutor = current_match(student_id)
    current_tutor && tutor_id != current_tutor.tutor_id
  end

  def unmatch_current_tutor(student_id)
    Match.where(student_id: student_id, end: nil).update_all(end: Date.today)
  end

  def start_match_with_tutor(student_id, tutor_id)
    Match.create(student_id: student_id, tutor_id: tutor_id, start: Date.today)
  end

  def current_match(student_id)
    Match.where(student_id: student_id, end: nil).take
  end

  helper_method :should_update_tutor
  helper_method :tutor_is_existing_tutor
  helper_method :unmatch_current_tutor
  helper_method :start_match_with_tutor
  helper_method :set_tutor1



end
