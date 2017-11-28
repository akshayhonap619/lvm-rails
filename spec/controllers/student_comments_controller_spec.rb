require 'rails_helper'

RSpec.describe StudentCommentsController, type: :controller do
  describe 'endpoints' do
    before do
      user = User.new(role: 2)
      sign_in_auth(user)
      @student = create(:student)
    end

    describe 'GET #new' do
      it 'populates a new student comment' do
        get :new, params: { student: @student }
        expect(assigns(:student_comment)).to be_a_new(StudentComment)
      end

      it 'populates the correct student' do
        get :new, params: { student: @student }
        expect(assigns(:student)).to eq(@student)
      end

      it 'renders the new view' do
        get :new, params: { student: @student }
        expect(response).to render_template :new
      end
    end

    describe 'as Coordinator' do
      before do
        user = User.new(role: 1, coordinator_id: 1)
        sign_in_auth(user)
        @student2 = create(:student)
        @student_comment = create(:student_comment, student_id: @student.id)
      end

      it 'denys to create a new comment for incorrect student_id' do
        get :new, params: { student: @student }
        expect((redirect_to root_path))
      end

      it 'denys to edit a  comment for incorrect student_id' do
        get :edit, params: { id: @student_comment, student: @student2 }
        expect((redirect_to root_path))
      end
    end

    describe 'GET #edit' do
      before do
        @student_comment = create(:student_comment, student_id: @student.id)
      end

      it 'populates the specified student_comment' do
        get :edit, params: { id: @student_comment, student: @student }
        expect(assigns(:student_comment)).to eq(@student_comment)
      end

      it 'populates the specified student' do
        get :edit, params: { id: @student_comment, student: @student }
        expect(assigns(:student)).to eq(@student)
      end

      it 'renders the edit view' do
        get :edit, params: { id: @student_comment, student: @student }
        expect(response).to render_template :edit
      end
    end

    describe 'POST #create' do
      before do
        @student_comment_attrs =
          attributes_for(:student_comment, student_id: @student.id)
      end

      context 'with valid attributes' do
        it 'saves the new student_comment in the database' do
          post :create, params: { student_comment: @student_comment_attrs }
          expect(assigns(:student_comment)).to be_persisted
        end

        it 'redirects to the existing student view' do
          post :create, params: { student_comment: @student_comment_attrs }
          expect(response).to redirect_to(@student)
        end
      end

      context 'with invalid attributes' do
        before do
          allow_any_instance_of(StudentComment).to receive(:save) { false }
        end

        it 'assigns the specified student as @student' do
          post :create, params: { student_comment: @student_comment_attrs }
          expect(assigns(:student)).to eq(@student)
        end

        it 're-renders the :new view' do
          post :create, params: { student_comment: @student_comment_attrs }
          expect(response).to render_template :new
        end
      end
    end

    describe 'PUT #update' do
      before do
        @student_comment = create(:student_comment, student_id: @student.id)
        @new_student_comment_attrs =
          attributes_for(:student_comment, student_id: @student.id)
      end

      context 'with valid attributes' do
        it 'saves the updated student_comment in the database' do
          post :update, params: {
            id: @student_comment.id,
            student_comment: @new_student_comment_attrs
          }
          expect(StudentComment.last.content)
            .to eq(@new_student_comment_attrs[:content])
        end

        it 'redirects to the existing student view' do
          post :update, params: {
            id: @student_comment.id,
            student_comment: @new_student_comment_attrs
          }
          expect(response).to redirect_to(@student)
        end
      end

      context 'with invalid attributes' do
        before do
          allow_any_instance_of(StudentComment).to receive(:update) { false }
        end

        it "assigns the existing student_comment's student as @student" do
          post :update, params: {
            id: @student_comment.id,
            student_comment: @new_student_comment_attrs
          }
          expect(assigns(:student)).to eq(@student)
        end

        it 're-renders the :edit view' do
          post :update, params: {
            id: @student_comment.id,
            student_comment: @new_student_comment_attrs
          }
          expect(response).to render_template :edit
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the student_comment' do
        student_comment = create(:student_comment, student_id: @student.id)
        expect { delete :destroy, params: { id: student_comment } }
          .to change(StudentComment, :count).by(-1)
      end

      it 'redirects to the :index view' do
        student_comment = create(:student_comment, student_id: @student.id)
        delete :destroy, params: { id: student_comment }
        expect(response).to redirect_to student_path(@student)
      end
    end
  end
end
