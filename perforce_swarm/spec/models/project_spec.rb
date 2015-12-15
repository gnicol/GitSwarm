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
     'mirror://foo-fizzle/mc-dizzle',
     'mirror://foo-fizzle/mc-dizzle/fizzle',
     'mirror://foo-fizzle/mc-dizzle/my/bizzle'
    ].each do |url|
      it { should allow_value(url).for(:git_fusion_repo) }
    end
  end

  describe 'GitSwarm respond_to' do
    it { is_expected.to(respond_to(:git_fusion_repo)) }
    it { is_expected.to(respond_to(:git_fusion_mirrored)) }
    it { is_expected.to(respond_to(:git_fusion_mirrored?)) }
  end

  describe 'git_fusion_mirrored?' do
    context 'default project' do
      let(:project) { create(:empty_project, path: 'somewhere') }
      it { expect(project.git_fusion_mirrored?).to be_falsey }
    end

    context 'only git_fusion_repo value' do
      let(:project) do
        create(:empty_project,
               path: 'somewhere',
               git_fusion_repo: 'mirror://foo/bar')
      end
      it { expect(project.git_fusion_mirrored?).to be_falsey }
    end

    context 'only git_fusion_mirrored flag set' do
      let(:project) do
        create(:empty_project, path: 'somewhere', git_fusion_mirrored: true)
      end
      it { expect(project.git_fusion_mirrored?).to be_falsey }
    end

    context 'both git_fusion_mirrored and git_fusion_repo set' do
      let(:project) do
        create(:empty_project,
               path: 'somewhere',
               git_fusion_repo: 'mirror://foo/bar',
               git_fusion_mirrored: true)
      end
      it { expect(project.git_fusion_mirrored?).to be true }
    end
  end

  describe 'disable_git_fusion_mirroring' do
    context 'on a mirroring-enabled project' do
      let(:project) do
        create(:empty_project,
               path: 'somewhere',
               git_fusion_repo: 'mirror://foo/bar',
               git_fusion_mirrored: true)
      end
      it 'disables Git Fusion mirroring' do
        # stub out setting the mirror URL to nil, along with file existence checks
        File.stub(realpath: '')
        File.stub(exist?: true)
        PerforceSwarm::Repo.any_instance.stub('mirror_url=' => nil)

        expect(project.git_fusion_mirrored?).to be true
        project.disable_git_fusion_mirroring!
        expect(project.git_fusion_mirrored?).to be false
      end
    end

    context 'on a mirroring-disabled project' do
      let(:project) do
        create(:empty_project,
               path: 'somewhere',
               git_fusion_repo: 'mirror://foo/bar',
               git_fusion_mirrored: false)
      end
      it 'does not change the mirroring status of a project' do
        # stub out setting the mirror URL to nil, along with file existence checks
        File.stub(realpath: '')
        File.stub(exist?: true)
        PerforceSwarm::Repo.any_instance.stub('mirror_url=' => nil)

        expect(project.git_fusion_mirrored?).to be false
        project.disable_git_fusion_mirroring!
        expect(project.git_fusion_mirrored?).to be false
      end
    end
  end
end
