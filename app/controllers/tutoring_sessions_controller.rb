class TutoringSessionsController < ApplicationController
  before_action :guard_against_tutors
  before_action :set_student, only: [:student_index]
  before_action :set_tutoring_session, only: [:show, :edit, :update, :destroy]

  add_breadcrumb 'Home', :root_path

  def student_index
    # While this lives in the tutoring sessions controller, it appears on the
    # front end as if it's entirely different. Namely, it looks like it's a
    # sub-view of the Student (see breadcrumbs below). This releives some
    # complications regarding enabling seamless navigation through this
    # controller as if the user was viewing this in the context of a student
    # versus a tutor. Please note that the user cannot edit or otherwise
    # manipulate any data on this page. To modify anything they must do so
    # through the tutor path.

    add_breadcrumb 'Students', students_path
    add_breadcrumb @student.name, student_path(@student)
    add_breadcrumb 'Student Attendance'

    @clickable_rows = false
    @page_title = 'Student Attendance'
    @page_title_subtext = "For #{@student.name}"
    @models = TutoringSession.joins(:match).where(
      matches: { student_id: @student.id }
    )
    @headers = [
      'Tutor First Name',
      'Tutor Last Name',
      'Start Date',
      'End Date',
      'Total Hours'
    ]
    @columns = [
      'tutor_first_name',
      'tutor_last_name',
      'start_date',
      'end_date',
      'hours'
    ]
  end

  def tutor_index
    @tutor = Tutor.of(current_user).find(params[:id])

    add_breadcrumb "Tutoring Sessions for #{@tutor.name}"

    @new_button = {
      text: 'Create New Tutoring Session',
      url: new_tutoring_session_path(tutor_id: @tutor)
    }
    @clickable_rows = true
    @page_title = 'Tutoring Sessions'
    @page_title_subtext = "For #{@tutor.name}"
    @models = TutoringSession.joins(:match).where(
      matches: { tutor_id: @tutor.id }
    )
    @headers = [
      'Tutor First Name',
      'Tutor Last Name',
      'Start Date',
      'End Date',
      'Total Hours'
    ]
    @columns = [
      'student_first_name',
      'student_last_name',
      'start_date',
      'end_date',
      'hours'
    ]
  end

  def new
    tutor_id = current_user.tutor_id || params[:tutor_id]
    @tutor = Tutor.of(current_user).find(tutor_id)

    add_breadcrumb "Tutoring Sessions for #{@tutor.name}",
                   tutors_tutoring_sessions_path(@tutor)
    add_breadcrumb 'New Tutoring Session'

    @tutoring_session = TutoringSession.new

    @students = Match.where(tutor_id: @tutor).map do |m|
      [m.student.name, m.id]
    end
  end

  def show
    @tutor = Tutor.of(current_user)
                  .find(Match.find(@tutoring_session.match_id).tutor_id)

    add_breadcrumb "Tutoring Sessions for #{@tutor.name}",
                   tutors_tutoring_sessions_path(@tutor)
    add_breadcrumb 'Tutoring Session'
  end

  def edit
    add_breadcrumb "Tutoring Sessions for #{@tutor.name}",
                   tutors_tutoring_sessions_path(@tutor)
    add_breadcrumb 'Tutoring Session', tutoring_session_path(@tutoring_session)
    add_breadcrumb 'Edit'

    tutor_id = Match.find(@tutoring_session.match_id).tutor_id
    @current_student_id = Match.find(@tutoring_session.match_id).student_id
    @students = Match.where(tutor_id: tutor_id)
                     .map { |m| [m.student.name, m.id] }
  end

  def create
    @tutoring_session = TutoringSession.new(tutoring_session_params)

    if @tutoring_session.save
      redirect_to @tutoring_session,
                  notice: 'Tutoring session was successfully created.'
    else
      set_students_and_tutor
      render :new
    end
  end

  def update
    if @tutoring_session.update(tutoring_session_params)
      redirect_to @tutoring_session,
                  notice: 'Tutoring session was successfully updated.'
    else
      set_students_and_tutor
      render :edit
    end
  end

  def destroy
    @tutoring_session.destroy
    @tutor = Tutor.of(current_user)
                  .find(Match.find(@tutoring_session.match_id).tutor_id)

    redirect_to tutors_tutoring_sessions_path(@tutor)
  end

  private

  def guard_against_tutors
    tutor_id = params[:tutor_id]
    is_tutor = current_user.tutor?
    kick_out if is_tutor && tutor_id && tutor_id.to_i != current_user.tutor_id
  end

  def set_tutoring_session
    @tutoring_session = TutoringSession.find(params[:id])
    match = Match.find(@tutoring_session.match_id)
    @tutor = Tutor.of(current_user).where(id: match.tutor_id).take
    @student = Student.of(current_user).where(id: match.student_id).take

    kick_out if !@tutor || !@student
  end

  def set_students_and_tutor
    @tutor = Tutor.of(current_user)
                  .find(params.to_unsafe_h['tutoring_session']['tutor_id'])
    @students = Match.where(tutor_id: @tutor.id)
                     .map { |m| [m.student.name, m.id] }
  end

  def set_student
    @student = Student.of(current_user).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    deny_access
  end

  def tutoring_session_params
    params.require(:tutoring_session).permit(:end_date,
                                             :hours,
                                             :location,
                                             :session_comment,
                                             :start_date,
                                             :match_id)
  end

  def kick_out
    flash[:alert] = 'Something went wrong!'
    redirect_to root_path
  end
end
