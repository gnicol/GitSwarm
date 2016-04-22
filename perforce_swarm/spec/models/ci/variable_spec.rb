require 'spec_helper'

describe Ci::Variable, models: true do
  subject { Ci::Variable.new }

  let(:secret_value) { 'secret' }

  before :each do
    subject.value = secret_value
  end

  describe :value do
    it 'fails to decrypt if iv is incorrect', override: true do
      subject.encrypted_value_iv = nil
      subject.instance_variable_set(:@value, nil)
      expect { subject.value }.to raise_error(OpenSSL::Cipher::CipherError)
    end
  end
end
