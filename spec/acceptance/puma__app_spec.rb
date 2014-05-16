require 'spec_helper_acceptance'

describe 'puma::app class' do
  describe 'running puppet code' do
    it 'should work without errors' do
      pp = 'puma::app { "redmine": }'

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end
end
