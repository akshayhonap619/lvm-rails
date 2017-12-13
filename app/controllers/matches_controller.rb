class MatchesController < ApplicationController
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

    @match = Match.find(params[:id])
    @student = Student.of(current_user).find(@match.student_id)
    @tutor = Tutor.of(current_user).find(@match.tutor_id)
  end

end
