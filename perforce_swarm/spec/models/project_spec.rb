require 'spec_helper'

describe Project do
  describe 'validations' do
    it { is_expected.to validate_length_of(:git_fusion_repo).is_within(0..255) }

    # Everything but nil will be string cast
    ['mirror://',
     'mirror:',
     'foo/bar',
     'zirror://foo/bar',
     0,
     false,
     'mirror://foo/'
    ].each do |url|
      it { should_not allow_value(url).for(:git_fusion_repo), url }
    end

    # Everything but nil will be string cast
    [nil,
     '',
     'mirror://foo/bar',
     'mirror://foo/bar/baz',
     'mirror://foo-fizzle/mc-dizzle',
     'mirror://foo-fizzle/mc-dizzle/fizzle',
     'mirror://foo-fizzle/mc-dizzle/my/bizzle'
    ].each do |url|
      it { should allow_value(url).for(:git_fusion_repo) }
    end
  end
end
