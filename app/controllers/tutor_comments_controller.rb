class TutorCommentsController < ApplicationController
  before_action :set_tutor_comment, only: [:edit, :update, :destroy]

  add_breadcrumb 'Home', :root_path

  def new
    @tutor = Tutor.of(current_user).find(params[:tutor])

    add_breadcrumb 'Tutors', tutors_path
    add_breadcrumb @tutor.name, tutor_path(@tutor)
    add_breadcrumb 'New Tutor Comment'

    @tutor_comment = TutorComment.new
  end

  def create
    @tutor_comment = TutorComment.new(tutor_comment_params)

    if @tutor_comment.save
      redirect_to tutor_path(tutor_comment_params[:tutor_id])
    else
      @tutor = Tutor.of(current_user).find(tutor_comment_params[:tutor_id])
      render :new
    end
  end

  def edit
    @tutor = Tutor.of(current_user).find(@tutor_comment.tutor_id)

    add_breadcrumb 'Tutors', tutors_path
    add_breadcrumb @tutor.name, tutor_path(@tutor)
    add_breadcrumb 'Edit Comment'
  end

  def update
    if @tutor_comment.update(tutor_comment_params)
      redirect_to tutor_path(tutor_comment_params[:tutor_id])
    else
      @tutor = Tutor.of(current_user).find(tutor_comment_params[:tutor_id])
      render :edit
    end
  end

  def destroy
    @tutor = Tutor.of(current_user).find(@tutor_comment.tutor_id)
    @tutor_comment.destroy

    redirect_to tutor_path(@tutor)
  end

  private

  def tutor_comment_params
    params.require(:tutor_comment).permit(
      :content,
      :tutor_id
    )
  end

  def set_tutor_comment
    @tutor_comment = TutorComment.find(params[:id])
  end
end
