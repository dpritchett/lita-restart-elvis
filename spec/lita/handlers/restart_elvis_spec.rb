require 'spec_helper'
require 'pry'

describe Lita::Handlers::RestartElvis, lita_handler: true do
  let(:robot) { Lita::Robot.new(registry) }
  use_vcr_cassette

  subject { described_class.new(robot) }

  before do
    ENV['HEROKU_OAUTH_TOKEN'] = 'abcdef'
    ENV['HEROKU_RESTARTABLE_APP_NAME'] = 'fake-elvis'
  end

  describe 'routes' do
    it { is_expected.to route('lita restart elvis') }
  end

  describe ':heroku' do
    it 'should connect with our oauth token' do
      expect(PlatformAPI).to receive(:connect_oauth)
      subject.heroku
    end
  end

  describe ':restart_dyno_named' do
    let(:heroku_double) { double }
    let(:dyno_double) { double }

    before { allow(subject).to receive(:heroku) { heroku_double } }
    before { allow(heroku_double).to receive(:dyno) { dyno_double } }

    it 'should ask to restart a dyno' do
      expect(dyno_double).to receive(:restart_all).with('xyz')

      subject.restart_dyno_named('xyz')
    end
  end
end
