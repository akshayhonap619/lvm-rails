require 'rails_helper'

RSpec.describe TutorCommentsController, type: :controller do
  describe 'endpoints' do
    before do
      user = User.new(role: 2)
      sign_in_auth(user)
      @tutor = create(:tutor)
    end

    describe 'GET #new' do
      it 'populates a new tutor comment' do
        get :new, params: { tutor: @tutor }
        expect(assigns(:tutor_comment)).to be_a_new(TutorComment)
      end

      it 'populates the correct tutor' do
        get :new, params: { tutor: @tutor }
        expect(assigns(:tutor)).to eq(@tutor)
      end

      it 'renders the new view' do
        get :new, params: { tutor: @tutor }
        expect(response).to render_template :new
      end
    end

    describe 'as Coordinator' do
      before do
        affiliate = create(:affiliate)
        coordinator = create(:coordinator, affiliate: affiliate)
        @user = User.new(role: 1, coordinator_id: coordinator.id)
        sign_in_auth(@user)
        @tutor2 = create(:tutor)
        create(:volunteer_job, tutor: @tutor2, affiliate: affiliate)
        @tutor_comment = create(:tutor_comment, tutor_id: @tutor.id)
      end

      it 'denys to create a new comment for tutor who is not under this coordinator' do
        get :new, params: { tutor: @tutor }
        expect(redirect_to root_path)
      end
    end

    describe 'GET #edit' do
      before do
        @tutor_comment = create(:tutor_comment, tutor_id: @tutor.id)
      end

      it 'populates the specified tutor_comment' do
        get :edit, params: { id: @tutor_comment, tutor: @tutor }
        expect(assigns(:tutor_comment)).to eq(@tutor_comment)
      end

      it 'populates the specified tutor' do
        get :edit, params: { id: @tutor_comment, tutor: @tutor }
        expect(assigns(:tutor)).to eq(@tutor)
      end

      it 'renders the edit view' do
        get :edit, params: { id: @tutor_comment, tutor: @tutor }
        expect(response).to render_template :edit
      end
    end

    describe 'POST #create' do
      before do
        @tutor_comment_attrs =
          attributes_for(:tutor_comment, tutor_id: @tutor.id)
      end

      context 'with valid attributes' do
        it 'saves the new tutor_comment in the database' do
          post :create, params: { tutor_comment: @tutor_comment_attrs }
          expect(assigns(:tutor_comment)).to be_persisted
        end

        it 'redirects to the existing tutor view' do
          post :create, params: { tutor_comment: @tutor_comment_attrs }
          expect(response).to redirect_to(@tutor)
        end
      end

      context 'with invalid attributes' do
        before do
          allow_any_instance_of(TutorComment).to receive(:save) { false }
        end

        it 'assigns the specified tutor as @tutor' do
          post :create, params: { tutor_comment: @tutor_comment_attrs }
          expect(assigns(:tutor)).to eq(@tutor)
        end

        it 're-renders the :new view' do
          post :create, params: { tutor_comment: @tutor_comment_attrs }
          expect(response).to render_template :new
        end
      end
    end

    describe 'PUT #update' do
      before do
        @tutor_comment = create(:tutor_comment, tutor_id: @tutor.id)
        @new_tutor_comment_attrs =
          attributes_for(:tutor_comment, tutor_id: @tutor.id)
      end

      context 'with valid attributes' do
        it 'saves the updated tutor_comment in the database' do
          post :update, params: {
            id: @tutor_comment.id,
            tutor_comment: @new_tutor_comment_attrs
          }
          expect(TutorComment.last.content)
            .to eq(@new_tutor_comment_attrs[:content])
        end

        it 'redirects to the existing tutor view' do
          post :update, params: {
            id: @tutor_comment.id,
            tutor_comment: @new_tutor_comment_attrs
          }
          expect(response).to redirect_to(@tutor)
        end
      end

      context 'with invalid attributes' do
        before do
          allow_any_instance_of(TutorComment).to receive(:update) { false }
        end

        it "assigns the existing tutor_comment's tutor as @tutor" do
          post :update, params: {
            id: @tutor_comment.id,
            tutor_comment: @new_tutor_comment_attrs
          }
          expect(assigns(:tutor)).to eq(@tutor)
        end

        it 're-renders the :edit view' do
          post :update, params: {
            id: @tutor_comment.id,
            tutor_comment: @new_tutor_comment_attrs
          }
          expect(response).to render_template :edit
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the tutor_comment' do
        tutor_comment = create(:tutor_comment, tutor_id: @tutor.id)
        expect { delete :destroy, params: { id: tutor_comment } }
          .to change(TutorComment, :count).by(-1)
      end

      it 'redirects to the :index view' do
        tutor_comment = create(:tutor_comment, tutor_id: @tutor.id)
        delete :destroy, params: { id: tutor_comment }
        expect(response).to redirect_to tutor_path(@tutor)
      end
    end
  end
end
