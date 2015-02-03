require 'gitlab_git'

# Filter mirror remotes out of the branch listing
class Gitlab::Git::Repository
  def branches
    rugged_branches = rugged.branches.select { |branch| branch.remote_name != 'mirror' }
    rugged_branches.map do |rugged_ref|
      Gitlab::Git::Branch.new(rugged_ref.name, rugged_ref.target)
    end.sort_by(&:name)
  end
end
