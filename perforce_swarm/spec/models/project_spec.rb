require 'spec_helper'

describe Project do
    let!(:project) { create(:project) }
    describe "makes sure that a migration was added from the rails instance." do
   	it { should respond_to(:source_control_type) }
    end
end
