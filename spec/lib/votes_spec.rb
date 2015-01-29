require 'spec_helper'

describe Issue, 'Votes' do
  let(:issue) { create(:issue) }

  describe "#upvotes" do
    it "with no notes has a 0/0 score" do
      issue.upvotes.should == 0
    end

    it "should recognize non-+1 notes" do
      add_note "No +1 here"
      issue.should have(1).note
      issue.notes.first.upvote?.should be_false
      issue.upvotes.should == 0
    end

    it "should recognize a single +1 note" do
      add_note "+1 This is awesome"
      issue.upvotes.should == 1
    end

    it 'should recognize multiple +1 notes' do
      add_note '+1 This is awesome', create(:user)
      add_note '+1 I want this', create(:user)
      issue.upvotes.should == 2
    end

    it 'should not count 2 +1 votes from the same user' do
      add_note '+1 This is awesome'
      add_note '+1 I want this'
      issue.upvotes.should == 1
    end
  end

  describe "#downvotes" do
    it "with no notes has a 0/0 score" do
      issue.downvotes.should == 0
    end

    it "should recognize non--1 notes" do
      add_note "Almost got a -1"
      issue.should have(1).note
      issue.notes.first.downvote?.should be_false
      issue.downvotes.should == 0
    end

    it "should recognize a single -1 note" do
      add_note "-1 This is bad"
      issue.downvotes.should == 1
    end

    it "should recognize multiple -1 notes" do
      add_note('-1 This is bad', create(:user))
      add_note('-1 Away with this', create(:user))
      issue.downvotes.should == 2
    end
  end

  describe "#votes_count" do
    it "with no notes has a 0/0 score" do
      issue.votes_count.should == 0
    end

    it "should recognize non notes" do
      add_note "No +1 here"
      issue.should have(1).note
      issue.votes_count.should == 0
    end

    it "should recognize a single +1 note" do
      add_note "+1 This is awesome"
      issue.votes_count.should == 1
    end

    it "should recognize a single -1 note" do
      add_note "-1 This is bad"
      issue.votes_count.should == 1
    end

    it "should recognize multiple notes" do
      add_note('+1 This is awesome', create(:user))
      add_note('-1 This is bad', create(:user))
      add_note('+1 I want this', create(:user))
      issue.votes_count.should == 3
    end

    it 'should not count 2 -1 votes from the same user' do
      add_note '-1 This is suspicious'
      add_note '-1 This is bad'
      issue.votes_count.should == 1
    end
  end

  describe "#upvotes_in_percent" do
    it "with no notes has a 0% score" do
      issue.upvotes_in_percent.should == 0
    end

    it "should count a single 1 note as 100%" do
      add_note "+1 This is awesome"
      issue.upvotes_in_percent.should == 100
    end

    it 'should count multiple +1 notes as 100%' do
      add_note('+1 This is awesome', create(:user))
      add_note('+1 I want this', create(:user))
      issue.upvotes_in_percent.should == 100
    end

    it 'should count fractions for multiple +1 and -1 notes correctly' do
      add_note('+1 This is awesome', create(:user))
      add_note('+1 I want this', create(:user))
      add_note('-1 This is bad', create(:user))
      add_note('+1 me too', create(:user))
      issue.upvotes_in_percent.should == 75
    end
  end

  describe "#downvotes_in_percent" do
    it "with no notes has a 0% score" do
      issue.downvotes_in_percent.should == 0
    end

    it "should count a single -1 note as 100%" do
      add_note "-1 This is bad"
      issue.downvotes_in_percent.should == 100
    end

    it 'should count multiple -1 notes as 100%' do
      add_note('-1 This is bad', create(:user))
      add_note('-1 Away with this', create(:user))
      issue.downvotes_in_percent.should == 100
    end

    it 'should count fractions for multiple +1 and -1 notes correctly' do
      add_note('+1 This is awesome', create(:user))
      add_note('+1 I want this', create(:user))
      add_note('-1 This is bad', create(:user))
      add_note('+1 me too', create(:user))
      issue.downvotes_in_percent.should == 25
    end
  end

  describe '#filter_superceded_votes' do

    it 'should count a users vote only once amongst multiple votes' do
      add_note('-1 This needs work before I will accept it')
      add_note('+1 I want this', create(:user))
      add_note('+1 This is is awesome', create(:user))
      add_note('+1 this looks good now')
      add_note('+1 This is awesome', create(:user))
      add_note('+1 me too', create(:user))
      issue.downvotes.should == 0
      issue.upvotes.should == 5
    end

    it 'should count each users vote only once' do
      add_note '-1 This needs work before it will be accepted'
      add_note '+1 I like this'
      add_note '+1 I still like this'
      add_note '+1 I really like this'
      add_note '+1 Give me this now!!!!'
      p issue.downvotes.should == 0
      p issue.upvotes.should == 1
    end

    it 'should count a users vote only once without caring about comments' do
      add_note '-1 This needs work before it will be accepted'
      add_note 'Comment 1'
      add_note 'Another comment'
      add_note '+1 vote'
      add_note 'final comment'
      p issue.downvotes.should == 0
      p issue.upvotes.should == 1
    end

  end

  def add_note(text, author = issue.author)
    created_at = Time.now - 1.hour + Note.count.seconds
    issue.notes << create(:note, note: text, project: issue.project,
                          author_id: author.id, created_at: created_at)
  end
end
