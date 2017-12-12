require 'rails_helper'

RSpec.describe TutoringSessionsController, type: :controller do
  let(:valid_session) { {} }
  describe 'endpoints' do
    before do
      user = User.new(role: 2)
      sign_in_auth(user)

      @tutor1 = create(:tutor)
      @tutor2 = create(:tutor)
      @student1 = create(:student)
      student2 = create(:student)
      affiliate = create(:affiliate)

      create(:volunteer_job, tutor: @tutor1, affiliate: affiliate)
      create(:enrollment, student: @student1, affiliate: affiliate)
      create(:volunteer_job, tutor: @tutor2, affiliate: affiliate)
      create(:enrollment, student: student2, affiliate: affiliate)

      @m1 = create(:match, student: @student1, tutor: @tutor1)
      @m2 = create(:match, student: student2, tutor: @tutor2)

      create(:tutoring_session, match: @m2)
      @tutoring_session = create(:tutoring_session, match: @m1)
      @tutoring_session_attrs = attributes_for(:tutoring_session)
      @tutoring_session_attrs[:match_id] = @m1.id
      @tutoring_session_attrs[:tutor_id] = @tutor1.id
    end

    describe 'GET #student_index' do
      it 'populates an array of tutoring_session for specified student' do
        get :student_index, params: { id: @student1.id }
        expect(assigns(:models)).to eq([@tutoring_session])
      end

      it 'renders the index template' do
        get :student_index, params: { id: @student1.id }
        expect(response).to render_template('student_index')
      end
    end

    describe 'as Coordinator' do
      before do
        user = User.new(role: 1, coordinator_id: 1)
        sign_in_auth(user)
        @student3 = create(:student)
        @tutor3 = create(:tutor)
      end

      it 'denys access to show the index of incorrect student_id' do
        get :student_index, params: { id: @student3.id }
        expect((redirect_to root_path))
      end

      it 'denys access to incorrect student_id' do
        get :tutor_index, params: { id: @tutor3.id }
        expect((redirect_to root_path))
      end
    end

    describe 'GET #tutor_index' do
      it 'populates an array of tutoring_session for specified tutor' do
        get :tutor_index, params: { id: @tutor1.id }
        expect(assigns(:models)).to eq([@tutoring_session])
      end

      it 'renders the index template' do
        get :tutor_index, params: { id: @tutor1.id }
        expect(response).to render_template('tutor_index')
      end
    end

    describe 'GET #new' do
      it 'populates the specified tutor' do
        get :new, params: { tutor_id: @tutor1.id }
        expect(assigns(:tutor)).to eq(@tutor1)
      end

      it 'populates a new tutoring session' do
        get :new, params: { tutor_id: @tutor1.id }
        expect(assigns(:tutoring_session)).to be_a_new(TutoringSession)
      end

      it 'populates students from matches' do
        get :new, params: { tutor_id: @tutor1.id }
        expect(assigns(:students)).to eq([[@student1.name, @student1.id]])
      end

      it 'renders the :new view' do
        get :new, params: { tutor_id: @tutor1.id }
        expect(response).to render_template :new
      end
    end

    describe 'GET #show' do
      describe 'when accessed incorrectly by a tutor' do
        it 'redirects the tutor to root view' do
          user = User.new(role: 0, tutor_id: @tutor1.id)
          sign_in_auth(user)
          get :show, params: { id: @tutoring_session, tutor_id: @tutor2.id }
          expect(response).to redirect_to root_path
        end
      end

      it 'shows the specified tutoring_session' do
        get :show, params: { id: @tutoring_session, tutor_id: @tutor1.id }
        expect(assigns(:tutoring_session)).to eq(@tutoring_session)
      end

      it 'renders the :show view' do
        get :show, params: { id: @tutoring_session, tutor_id: @tutor1.id }
        expect(response).to render_template('show')
      end
    end

    describe 'GET #edit' do
      it 'populates the correct current_student_id' do
        get :edit, params: { id: @tutoring_session.id }
        expect(assigns(:current_student_id)).to be(@tutor1.id)
      end

      it 'populates the correct students' do
        get :edit, params: { id: @tutoring_session.id }
        expect(assigns(:students)).to eq([[@student1.name, @student1.id]])
      end

      it 'renders the edit view' do
        get :edit, params: { id: @tutoring_session.id }
        expect(response).to render_template :edit
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        it 'saves the new tutoring_session to the database' do
          post :create, params: { tutoring_session: @tutoring_session_attrs }
          expect(assigns(:tutoring_session)).to be_persisted
        end

        it 'assigns newly created tutoring_session as @tutoring_session' do
          post :create, params: { tutoring_session: @tutoring_session_attrs }
          expect(assigns(:tutoring_session)).to be_a(TutoringSession)
        end

        it 'redirects to the newly created tutoring_session view' do
          post :create, params: { tutoring_session: @tutoring_session_attrs }
          expect(response).to redirect_to(TutoringSession.last)
        end
      end

      context 'with invalid attributes' do
        before do
          allow_any_instance_of(TutoringSession).to receive(:save) { false }
        end

        it 'assigned a newly created but unsaved tutoring_session
            as @tutoring_session' do
          post :create, params: { tutoring_session: @tutoring_session_attrs }
          expect(assigns(:tutoring_session)).to be_a_new(TutoringSession)
        end

        it 're-renders the new tutoring_session view' do
          post :create, params: { tutoring_session: @tutoring_session_attrs }
          expect(response).to render_template :new
        end
      end
    end

    describe 'PATCH #update' do
      context 'with valid attributes' do
        it 'saves the updated tutoring_session to the database' do
          patch :update, params: { id: @tutoring_session,
                                   tutoring_session: @tutoring_session_attrs }
          expect(TutoringSession.last).to eq(@tutoring_session)
        end

        it 'assigns the updated tutoring_session as @tutoring_session' do
          patch :update, params: { id: @tutoring_session,
                                   tutoring_session: @tutoring_session_attrs }
          expect(assigns(:tutoring_session)).to eq(@tutoring_session)
        end

        it 'redirects to the tutoring_session view' do
          patch :update, params: { id: @tutoring_session,
                                   tutoring_session: @tutoring_session_attrs }
          expect(response).to redirect_to(@tutoring_session)
        end
      end

      context 'with invalid attributes' do
        before do
          allow_any_instance_of(TutoringSession).to receive(:update) { false }
        end

        it 'assigns the existing tutoring_session as @tutoring_session' do
          post :update, params: { id: @tutoring_session,
                                  tutoring_session: @tutoring_session_attrs }
          expect(assigns(:tutoring_session)).to eq(@tutoring_session)
        end

        it 're-renders the :edit view' do
          post :update, params: { id: @tutoring_session,
                                  tutoring_session: @tutoring_session_attrs }
          expect(response).to render_template :edit
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the tutoring_session' do
        expect { delete :destroy, params: { id: @tutoring_session } }
          .to change(TutoringSession, :count).by(-1)
      end

      it 'redirects to tutoring_session :index view' do
        delete :destroy, params: { id: @tutoring_session }
        expect(response).to redirect_to tutors_tutoring_sessions_path(@tutor1)
      end
    end
  end
end
