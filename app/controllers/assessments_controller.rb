class AssessmentsController < ApplicationController
  before_action :ensure_coordinator_or_admin!
  before_action :set_assessment, only: [:show, :edit, :update, :destroy]

  add_breadcrumb 'Home', :root_path

  def student_assesments_index
    @student = Student.of(current_user).find(params[:id])

    add_breadcrumb 'Students', students_path
    add_breadcrumb 'Assessments', assessments_path
    add_breadcrumb @student.name, student_path(@student)
    add_breadcrumb "Assessments of #{@student.name}"

    @new_button = {
      text: 'Create New Assessment',
      url: new_assessment_path(student_id: @student)
    }
    @clickable_rows = true
    @page_title = 'Assessments'
    @page_title_subtext = "For #{@student.name}"
    @models = Assessment.where(student_id: @student.id)
    @headers = [
      'Name',
      'Category',
      'Level',
      'Type',
      'Score',
      'Date'
    ]
    @columns = [
      'name',
      'category',
      'level',
      'assessment_type',
      'score',
      'date'
    ]
  end

  # GET /assessments
  def index
    add_breadcrumb 'Students', students_path
    add_breadcrumb 'Assessments'

    @clickable_rows = true
    @page_title = 'Assessments'

    if current_user.admin?
      @models = Assessment.all
    else
      @students = Student.of(current_user).where(deleted_on: nil)
      @models = Assessment.where(student_id: @students.ids)
    end

    @headers = [
      'Name',
      'Category',
      'Level',
      'Type',
      'Score',
      'Date'
    ]
    @columns = [
      'name',
      'category',
      'level',
      'assessment_type',
      'score',
      'date'
    ]
  end

  # GET /assessments/1
  def show
    add_breadcrumb 'Students', students_path
    add_breadcrumb 'Assessments', assessments_path
    add_breadcrumb "Assessments for #{@assessment.student.name}",
                   students_assessments_path(@assessment.student)
    add_breadcrumb 'Assessment'
  end

  # GET /assessments/new
  def new
    student_id = params[:student_id]
    @student = Student.of(current_user).find(student_id)

    add_breadcrumb "Assessments for #{@student.name}",
                   students_assessments_path(@student)
    add_breadcrumb 'New Assessment'

    @assessment = Assessment.new
  end

  # GET /assessments/1/edit
  def edit
    @student = @assessment.student

    add_breadcrumb "Assessments for #{@student.name}",
                   students_assessments_path(@student)
    add_breadcrumb 'Assessment', assessment_path(@assessment)
    add_breadcrumb 'Edit'
  end

  # POST /assessments
  def create
    @assessment = Assessment.new(assessment_params)

    if @assessment.save
      redirect_to @assessment, notice: 'Assessment was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /assessments/1
  def update
    if @assessment.update(assessment_params)
      redirect_to @assessment, notice: 'Assessment was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /assessments/1
  def destroy
    @assessment.destroy
    redirect_to students_assessments_url(@assessment.student),
                notice: 'Assessment was successfully deleted.'
  end

  private

  def set_assessment
    @assessment = Assessment.find(params[:id])
  end

  def assessment_params
    params.require(:assessment).permit(:score, :date, :category,
                                       :level, :name, :assessment_type,
                                       :student_id)
  end
end
