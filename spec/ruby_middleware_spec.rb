require 'spec_helper'
require 'fileutils'

describe I18n::Instrument::Middleware, type: :request do
  let(:recorded_params) { [] }
  let(:config) { I18n::Instrument.config }
  let(:control_file) do
    File.join('spec', 'config', 'enable_i18n_instrumentation')
  end

  before(:each) do
    I18n::Instrument.configure do |config|
      config.on_record { |params| recorded_params << params }
    end
  end

  def with_control_file
    FileUtils.touch(control_file)
    yield
  ensure
    File.unlink(control_file)
  end

  it "with default enable behavior, is disabled if the control file doesn't exist" do
    expect { get('/tests') }.to_not change { recorded_params.size }.from(0)
  end

  it "with default enable behavior, is enabled if the control file exists" do
    with_control_file do
      expect { get('/tests') }.to change { recorded_params.size }.from(0).to(1)
    end
  end

  context 'with instrumentation enabled' do
    before(:each) do
      config.on_check_enabled { true }
    end

    it 'records ruby I18n.t calls' do
      expect { get('/tests') }.to change { recorded_params.size }.from(0).to(1)
      expect(response).to be_success
      params = recorded_params.first

      expect(params[:source]).to eq('ruby')
      expect(params[:trace]).to include('app/controllers/tests_controller.rb')
      expect(params[:url]).to eq('/tests')
      expect(params[:key]).to eq('en.foo.bar')
      expect(params[:locale]).to eq('en')
    end

    it 'by default, renders a 500 for errors that happen during lookup' do
      config.on_record { raise 'jelly beans' }
      get '/tests'
      expect(response).to_not be_success
    end

    # @TODO
    it 'by default, renders a 500 for for errors that happen in the middleware stack' do
      expect_any_instance_of(I18n::Instrument::Middleware).to(
        receive(:handle_regular_request).and_raise('jelly beans')
      )

      get '/tests'
      expect(response).to_not be_success
    end

    context 'with errors recorded' do
      let(:recorded_errors) { [] }

      before(:each) do
        config.on_error { |e| recorded_errors << e }
      end

      it 'reports errors that happen during lookup' do
        config.on_record { raise 'jelly beans' }
        expect { get('/tests') }.to change { recorded_errors.size }.from(0).to(1)
        expect(recorded_errors.first.message).to eq('jelly beans')
        expect(response).to be_success
      end

      it 'reports errors that happen during the middleware stack' do
        expect_any_instance_of(I18n::Instrument::Middleware).to(
          receive(:store).twice.and_raise('jelly beans')
        )

        expect { get '/tests' }.to change { recorded_errors.size }.from(0).to(2)
        expect(response).to be_success
      end
    end
  end

  context 'with instrumentation disabled' do
    before(:each) do
      config.on_check_enabled { false }
    end

    it "doesn't record ruby I18n.t calls" do
      expect { get('/tests') }.to_not change { recorded_params.size }.from(0)
      expect(response).to be_success
    end
  end
end
