require 'spec_helper'

describe Project do
  describe 'validations' do
    it { is_expected.to validate_length_of(:git_fusion_repo).is_within(0..255) }

    ['mirror://',
     'mirror:',
     'foo/bar',
     'zirror://foo/bar',
     0,
     'mirror://foo/'
    ].each do |url|
      it { should_not allow_value(url).for(:git_fusion_repo), url }
    end

    [nil,
     false,
     '',
     'mirror://foo/bar',
     'mirror://foo/bar/baz',
     'mirror://foo-fizzle/mc-dizzle'
    ].each do |url|
      it { should allow_value(url).for(:git_fusion_repo) }
    end
  end
end
