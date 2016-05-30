require 'spec_helper'

describe Ci::Variable, models: true do
  subject { Ci::Variable.new }

  let(:secret_value) { 'secret' }

  before :each do
    subject.value = secret_value
  end

  # override the test so it runs on OSX as well as Linux - we just check for the exception
  # to be thrown because the exception message varies by OS
  describe :value do
    it 'fails to decrypt if iv is incorrect', override: true do
      subject.encrypted_value_iv = nil
      subject.instance_variable_set(:@value, nil)
      expect { subject.value }.to raise_error(OpenSSL::Cipher::CipherError)
    end
  end
end
