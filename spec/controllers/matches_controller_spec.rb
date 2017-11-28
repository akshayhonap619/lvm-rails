require 'rails_helper'

RSpec.describe MatchesController, type: :controller do
  describe 'endpoints' do
    before do
      user = User.new(role: 2)
      sign_in_auth(user)

      create(:coordinator, id: 1, affiliate_id: 1)

      affiliate1 = create(:affiliate)
      affiliate2 = create(:affiliate)
      @tutor1 = create(:tutor)
      tutor2 = create(:tutor)
      @student1 = create(:student)
      student2 = create(:student)
      create(:enrollment, student: @student1, affiliate: affiliate1)
      create(:enrollment, student: student2, affiliate: affiliate2)
      create(:volunteer_job, tutor: @tutor1, affiliate: affiliate1)
      create(:volunteer_job, tutor: tutor2, affiliate: affiliate2)
      @match1 = create(:match, tutor: @tutor1, student: @student1)
      @match2 = create(:match, tutor: tutor2, student: student2)
    end

    describe 'GET #index' do
      it 'populates an array of all matches' do
        get :index
        expect(assigns(:models)).to eq([@match1, @match2])
      end

      it 'renders the :index view' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'as coordinator' do
      before do
        affiliate = create(:affiliate)
        coordinator = create(:coordinator, affiliate: affiliate)
        @student = create(:student)
        create(:enrollment, student: @student, affiliate: affiliate)

        @user = User.new(role: 1, coordinator_id: coordinator.id)
        sign_in_auth(@user)
      end

      it 'denys access for invalid matchid' do
        get :show, params: { id: @match1.id }
        expect((redirect_to root_path))
      end
    end

    describe 'GET #show' do
      it 'populates @match' do
        get :show, params: { id: @match1.id }
        expect(assigns(:match)).to eq(@match1)
      end

      it 'populates @student' do
        get :show, params: { id: @match1.id }
        expect(assigns(:student)).to eq(@student1)
      end

      it 'populates @tutor' do
        get :show, params: { id: @match1.id }
        expect(assigns(:tutor)).to eq(@tutor1)
      end

      it 'renders the :show view' do
        get :show, params: { id: @match1.id }
        expect(response).to render_template :show
      end
    end
  end
end
