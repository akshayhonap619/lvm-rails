class MatchesController < ApplicationController
  before_action :set_match, only: [:show]
  before_action :set_student, only: [:show]
  before_action :set_tutor, only: [:show]

  add_breadcrumb 'Home', :root_path

  def index
    add_breadcrumb 'Matches'

    @clickable_rows = true
    @page_title = 'Matches'
    @models = Match.of(current_user)
    @headers = [
      'Student First Name',
      'Student Last Name',
      'Tutor First Name',
      'Tutor Last Name',
      'Start Date',
      'End Date'
    ]
    @columns = [
      'student_first_name',
      'student_last_name',
      'tutor_first_name',
      'tutor_last_name',
      'start',
      'end'
    ]
  end

  def show
    add_breadcrumb 'Matches', matches_path
    add_breadcrumb 'Match'

  end

  private

  def set_match
    @match = Match.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    deny_access
  end

  def set_student
    @student = Student.of(current_user).find(@match.student_id)
  rescue ActiveRecord::RecordNotFound
    deny_access
  end

  def set_tutor
    @tutor = Tutor.of(current_user).find(@match.tutor_id)
  rescue ActiveRecord::RecordNotFound
    deny_access
  end
end
