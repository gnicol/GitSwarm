shared_examples 'an email sent from GitLab' do
  it 'is sent from GitLab' do
    sender = subject.header[:from].addrs[0]
    expect(sender.display_name).to eq('GitSwarm')
    expect(sender.address).to eq(gitlab_sender)
  end
end
