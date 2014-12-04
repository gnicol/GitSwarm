module SharedGroups
  include Spinach::DSL

  step 'group "QA" exists' do
    create(:group, name: 'QA')
  end
end
