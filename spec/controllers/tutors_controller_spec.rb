require 'rails_helper'

RSpec.describe TutorsController, type: :controller do
  describe 'endpoints' do
    describe 'GET #index' do
      before do
        affiliate = create(:affiliate)

        create(:coordinator, affiliate: affiliate)

        tutor1 = create(:tutor)
        tutor2 = create(:tutor)

        create(:volunteer_job, tutor: tutor1, affiliate: affiliate)

        @all_tutors = [tutor1, tutor2]
        @coordinator_tutors = [tutor1]
      end

      describe 'as admin' do
        before do
          user = User.new(role: 2)
          sign_in_auth(user)
        end

        it 'populates an array of all tutors' do
          get :index
          expect(assigns(:models)).to eq(@all_tutors)
        end

        it 'renders the :index view' do
          get :index

          expect(response).to render_template :index
        end
      end

      describe 'as coordinator' do
        before do
          user = User.new(role: 1, coordinator_id: 1)
          sign_in_auth(user)
          @tutor3 = create(:tutor)
        end

        it 'populates an array of affiliate tutors' do
          get :index
          expect(assigns(:models)).to eq(@coordinator_tutors)
        end

        it 'renders the :index view' do
          get :index

          expect(response).to render_template :index
        end

        it 'denys access to show tutor who doesnt belong to this coordinator' do
          get :show, params: { id: @tutor3 }
          expect((redirect_to root_path))
        end

        it 'denys access to edit tutor who doesnt belong to this coordinator' do
          get :edit, params: { id: @tutor3 }
          expect((redirect_to root_path))
        end
      end

      describe 'as tutor' do
        before do
          user = User.new(role: 0, tutor_id: 1)
          sign_in_auth(user)
        end

        it 'redirects to the welcome view' do
          get :index

          expect(response).to redirect_to root_path
        end
      end
    end

    describe 'GET #deleted_index' do
      before do
        affiliate = create(:affiliate)

        create(:coordinator, affiliate: affiliate)

        tutor1 = create(:tutor)
        tutor2 = create(:tutor, deleted_on: Date.today, deleted_by: 1)

        create(:volunteer_job, tutor: tutor1, affiliate: affiliate)

        @all_tutors = [tutor2]
      end

      describe 'as admin' do
        before do
          user = User.new(role: 2)
          sign_in_auth(user)
        end

        it 'populates an array of all deleted tutors' do
          get :deleted_index
          expect(assigns(:models)).to eq(@all_tutors)
        end

        it 'renders the :deleted_index view' do
          get :deleted_index

          expect(response).to render_template :deleted_index
        end
      end

      describe 'as coordinator' do
        before do
          user = User.new(role: 1, coordinator_id: 1)
          sign_in_auth(user)
        end

        it 'redirects to the welcome view' do
          get :deleted_index

          expect(response).to redirect_to root_path
        end
      end

      describe 'as tutor' do
        before do
          user = User.new(role: 0, tutor_id: 1)
          sign_in_auth(user)
        end

        it 'redirects to the welcome view' do
          get :deleted_index

          expect(response).to redirect_to root_path
        end
      end
    end

    describe 'GET #show' do
      before do
        user = User.new(role: 2)
        sign_in_auth(user)

        affiliate = create(:affiliate)
        @student = create(:student)
        @tutor = create(:tutor)
        @student3 = create(:student)
        @tutor3 = create(:tutor)
        @tutor2 = create(:tutor, deleted_on: Date.today, deleted_by: 1)

        create(:student) # not the same affiliate
        s2 = create(:student) # already being tutored
        t2 = create(:tutor) # to tutor s2

        create(:volunteer_job, tutor: @tutor, affiliate: affiliate)
        create(:volunteer_job, tutor: @tutor3, affiliate: affiliate)
        create(:volunteer_job, tutor: t2, affiliate: affiliate)
        create(:enrollment, student: @student, affiliate: affiliate)
        create(:enrollment, student: @student3, affiliate: affiliate)
        create(:enrollment, student: s2, affiliate: affiliate)
        create(:match, student: s2, tutor: t2)
        create(:match, student: @student3, tutor: @tutor3)
      end

      describe 'a deleted tutor' do
        it 'populates the specified tutor' do
          get :show, params: { id: @tutor2 }
          expect(assigns(:tutor)).to eq(@tutor2)
        end

        it 'shows the correct breadcrumbs' do
          allow(controller).to receive(:add_breadcrumb)

          get :show, params: { id: @tutor2 }

          expect(controller).to have_received(:add_breadcrumb)
            .with('Home', :root_path, {}).ordered
          expect(controller).to have_received(:add_breadcrumb)
            .with('Deleted Tutors', deleted_tutors_path).ordered
          expect(controller).to have_received(:add_breadcrumb)
            .with(@tutor2.name).ordered
        end

        it 'renders the :show view' do
          get :show, params: { id: @tutor3 }
          expect(response).to render_template :show
        end
      end

      describe 'a not deleted tutor' do
        it 'populates the specified tutor' do
          get :show, params: { id: @tutor }
          expect(assigns(:tutor)).to eq(@tutor)
        end

        it 'populates the students of the specified tutor' do
          students = Match.where(tutor_id: @tutor.id, end: nil)
                          .to_a.map { |m| Student.find(m.student_id) }

          get :show, params: { id: @tutor }
          expect(assigns(:students)).to eq(students)
        end

        it 'populates possible further student matches' do
          get :show, params: { id: @tutor }

          expect(assigns(:student_options)).to eq(
            [[@student.name, @student.id]]
          )
        end

        it 'shows the correct breadcrumbs' do
          allow(controller).to receive(:add_breadcrumb)

          get :show, params: { id: @tutor }

          expect(controller).to have_received(:add_breadcrumb)
            .with('Home', :root_path, {}).ordered
          expect(controller).to have_received(:add_breadcrumb)
            .with('Tutors', tutors_path).ordered
          expect(controller).to have_received(:add_breadcrumb)
            .with(@tutor.name).ordered
        end

        it 'renders the :show view' do
          get :show, params: { id: @tutor }
          expect(response).to render_template :show
        end
      end
    end

    describe 'GET #new' do
      before do
        user = User.new(role: 2)
        sign_in_auth(user)
      end

      it 'populates a new tutor' do
        get :new
        expect(assigns(:tutor)).to be_a_new(Tutor)
      end

      it 'renders the :new view' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'GET #edit' do
      before do
        user = User.new(role: 2)
        sign_in_auth(user)
        @tutor = create(:tutor)
      end

      it 'populates the specified tutor' do
        get :edit, params: { id: @tutor }
        expect(assigns(:tutor)).to eq(@tutor)
      end

      it 'renders the :edit view' do
        get :edit, params: { id: @tutor }
        expect(response).to render_template :edit
      end
    end

    describe 'POST #create' do
      before do
        user = User.new(role: 2)
        sign_in_auth(user)
        @tutor_attrs = attributes_for(:tutor)
      end

      context 'with valid attributes' do
        it 'saves the new tutor in the database' do
          post :create, params: { tutor: @tutor_attrs }
          expect(assigns(:tutor)).to be_persisted
        end

        it 'assigns the newly created tutor as @tutor' do
          post :create, params: { tutor: @tutor_attrs }
          expect(assigns(:tutor)).to be_a(Tutor)
        end

        it 'redirects to the newly created tutor view' do
          post :create, params: { tutor: @tutor_attrs }
          expect(response).to redirect_to(Tutor.last)
        end
      end

      context 'with invalid attributes' do
        before do
          allow_any_instance_of(Tutor).to receive(:save) { false }
        end

        it 'assigns a newly created but unsaved tutor as @tutor' do
          post :create, params: { tutor: @tutor_attrs }
          expect(assigns(:tutor)).to be_a_new(Tutor)
        end

        it 're-renders the :new view' do
          post :create, params: { tutor: @tutor_attrs }
          expect(response).to render_template :new
        end
      end
    end

    describe 'PUT #update' do
      before do
        user = User.new(role: 2)
        sign_in_auth(user)
        @tutor = create(:tutor)
        @new_tutor_attrs = attributes_for(:tutor)
      end

      context 'with valid attributes' do
        it 'saves the updated tutor in the database' do
          post :update, params: { id: @tutor.id, tutor: @new_tutor_attrs }
          expect(Tutor.last.last_name).to eq(@new_tutor_attrs[:last_name])
        end

        it 'assigns the updated tutor as @tutor' do
          post :update, params: { id: @tutor.id, tutor: @new_tutor_attrs }
          expect(assigns(:tutor).last_name).to eq(@new_tutor_attrs[:last_name])
        end

        it 'redirects to the tutor view' do
          post :update, params: { id: @tutor.id, tutor: @new_tutor_attrs }
          expect(response).to redirect_to(@tutor)
        end
      end

      context 'with invalid attributes' do
        before do
          allow_any_instance_of(Tutor).to receive(:update) { false }
        end

        it 'assigns the existing tutor as @tutor' do
          post :update, params: { id: @tutor, tutor: @new_tutor_attrs }
          expect(assigns(:tutor)).to eq(@tutor)
        end

        it 're-renders the :edit view' do
          post :update, params: { id: @tutor, tutor: @new_tutor_attrs }
          expect(response).to render_template :edit
        end
      end
    end

    describe 'PATCH #update_tags' do
      before do
        user = User.new(role: 2)
        sign_in_auth(user)
        @tutor = create(:tutor)
        @params = { id: @tutor.id, tutor: { 'all_tags' => ['', 'test'] } }
      end

      context 'with valid attributes' do
        it 'updates the tags for a tutor' do
          patch :update_tags, params: @params
          expect(Tutor.last.tags).to eq([Tag.last])
          expect(Tag.last.name).to eq 'test'
        end

        it 'redirects to the tutor view' do
          post :update, params: @params
          expect(response).to redirect_to(@tutor)
        end
      end
    end

    describe 'DELETE #destroy' do
      before do
        user = User.new(role: 2)
        sign_in_auth(user)
      end

      it 'destroys the tutor' do
        tutor = create(:tutor)
        expect { delete :destroy, params: { id: tutor } }
          .to change(Tutor, :count).by(-1)
      end
      it 'redirects to the :index view' do
        tutor = create(:tutor)
        delete :destroy, params: { id: tutor }
        expect(response).to redirect_to tutors_path
      end
    end

    describe 'PUT #add_student' do
      before do
        user = User.new(role: 2)
        sign_in_auth(user)
        affiliate = create(:affiliate)
        @tutor = create(:tutor)
        @student = create(:student)
        create(:volunteer_job, tutor: @tutor, affiliate: affiliate)
        create(:enrollment, student: @student, affiliate: affiliate)
      end

      it 'matches the student with the specified tutor' do
        put :add_student, params: { tutor_id: @tutor, student_id: @student }
        expect(
          Match.where(
            student_id: @student, tutor_id: @tutor, end: nil
          ).length
        ).to eq(1)
      end

      it 'redirects to tutor#show' do
        put :add_student, params: { tutor_id: @tutor, student_id: @student }
        expect(response).to redirect_to(@tutor)
      end
    end

    describe 'PUT #remove_student' do
      before do
        user = User.new(role: 2)
        sign_in_auth(user)
        affiliate = create(:affiliate)
        @tutor = create(:tutor)
        @student = create(:student)
        create(:volunteer_job, tutor: @tutor, affiliate: affiliate)
        create(:enrollment, student: @student, affiliate: affiliate)
        create(:match, student: @student, tutor: @tutor)
      end

      it 'ends the match with the specified student and tutor' do
        put :remove_student, params: { tutor_id: @tutor, student_id: @student }
        expect(Match.where(student_id: @student, tutor_id: @tutor).take.end)
          .not_to be nil
      end

      it 'redirects to tutor#show' do
        put :remove_student, params: { tutor_id: @tutor, student_id: @student }
        expect(response).to redirect_to(@tutor)
      end
    end

    describe 'PATCH #reinstate' do
      before do
        user = User.new(role: 2)
        sign_in_auth(user)
        @tutor = create(:tutor, deleted_on: Date.today, deleted_by: 1)
      end

      it 'updates the tutor correctly' do
        patch :reinstate, params: { id: @tutor.id }
        expect(Tutor.find(@tutor.id).deleted_on).to be nil
        expect(Tutor.find(@tutor.id).deleted_by).to be nil
      end

      it 'redirects to the student view' do
        patch :reinstate, params: { id: @tutor.id }
        expect(response).to redirect_to(tutor_path(@tutor.id))
      end
    end

    describe 'PATCH #delete' do
      describe 'for admin' do
        before(:each) do
          @user = User.new(role: 2)
          sign_in_auth(@user)
          affiliate = create(:affiliate)
          @tutor = create(:tutor)
          student = create(:student)
          create(:enrollment, student: student, affiliate: affiliate)
          create(:volunteer_job, tutor: @tutor, affiliate: affiliate)
          create(:match, student: student, tutor: @tutor)
        end

        it 'updates the tutor correctly' do
          patch :delete, params: { id: @tutor.id }
          expect(Tutor.find(@tutor.id).deleted_on.strftime('%F'))
            .to eq Date.today.strftime('%F')
          expect(Tutor.find(@tutor.id).deleted_by).to be @user.id
        end

        it 'unmatches all matches' do
          patch :delete, params: { id: @tutor.id }
          expect(Match.take.end).not_to be nil
        end

        it 'redirects to the tutor view' do
          patch :delete, params: { id: @tutor.id }
          expect(response).to redirect_to(tutor_path(@tutor.id))
        end
      end

      describe 'as coordinator' do
        before do
          affiliate = create(:affiliate)
          coordinator = create(:coordinator, affiliate: affiliate)
          @tutor = create(:tutor)
          student = create(:student)
          create(:volunteer_job, tutor: @tutor, affiliate: affiliate)
          create(:enrollment, student: student, affiliate: affiliate)
          create(:match, student: student, tutor: @tutor)

          @user = User.new(role: 1, coordinator_id: coordinator.id)
          sign_in_auth(@user)
        end

        it 'updates the tutor correctly' do
          patch :delete, params: { id: @tutor.id }
          expect(Tutor.find(@tutor.id).deleted_on.strftime('%F'))
            .to eq Date.today.strftime('%F')
          expect(Tutor.find(@tutor.id).deleted_by).to be @user.id
        end

        it 'unmatches all matches' do
          patch :delete, params: { id: @tutor.id }
          expect(Match.take.end).not_to be nil
        end

        it 'redirects to the tutors index view' do
          patch :delete, params: { id: @tutor.id }
          expect(response).to redirect_to(tutors_path)
        end
      end
    end
  end
end
