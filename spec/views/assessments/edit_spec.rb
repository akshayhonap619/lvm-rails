require 'rails_helper'

RSpec.describe 'assessments/edit', type: :view do
  before(:each) do
    @student = create(:student)
    @assessment = create(:assessment, name: 'TABE 10',
                                      assessment_type: 'Does not apply',
                                      student: @student)
  end

  it 'renders the edit assessment form' do
    render

    expect(rendered).to match(@assessment.score)
    expect(rendered).to match(@assessment.date.strftime('%Y-%m-%d'))
    expect(rendered).to match(@assessment.category)
    expect(rendered).to match(@assessment.level)
    expect(rendered).to match(@assessment.name)
    expect(rendered).to match(@assessment.assessment_type)
  end
end
