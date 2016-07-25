require 'spec_helper'

describe I18n::Instrument::Middleware, type: :request do
  let(:recorded_params) { [] }
  let(:config) { I18n::Instrument.config }
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
  let(:valid_url) { 'http://localhost:1234/tests' }
  let(:invalid_url) { 'http://localhost:1234/no' }
  let(:valid_key) { 'en.bar.baz' }
  let(:invalid_key) { '' }

  before(:each) do
    I18n::Instrument.configure do |config|
      config.on_check_enabled { true }
      config.on_record { |params| recorded_params << params }
    end
  end

  it 'records I18n.t calls in javascript' do
    params = { url: valid_url, key: valid_key, locale: 'en' }

    expect { post(config.js_endpoint, params.to_json, headers) }.to(
      change { recorded_params.size }.from(0).to(1)
    )

    expect(response).to be_success

    params = recorded_params.first
    expect(params[:source]).to eq('javascript')
    expect(params[:trace]).to be_nil
    expect(params[:controller]).to eq('tests')
    expect(params[:action]).to eq('index')
    expect(params[:key]).to eq(valid_key)
    expect(params[:locale]).to eq('en')
  end

  it "doesn't record anything for unrecognized URLs" do
    params = { url: invalid_url, key: valid_key, locale: 'en' }

    expect { post(config.js_endpoint, params.to_json, headers) }.to_not(
      change { recorded_params.size }.from(0)
    )

    expect(response).to be_success
  end

  it "doesn't record anything when given a blank key" do
    params = { url: valid_url, key: invalid_key, locale: 'en' }

    expect { post(config.js_endpoint, params.to_json, headers) }.to_not(
      change { recorded_params.size }.from(0)
    )

    expect(response).to be_success
  end

  context 'with instrumentation disabled' do
    before(:each) do
      config.on_check_enabled { false }
    end

    it "doesn't record any javascript I18n.t calls" do
      params = { url: valid_url, key: valid_key, locale: 'en' }

      expect { post(config.js_endpoint, params.to_json, headers) }.to_not(
        change { recorded_params.size }.from(0)
      )
    end
  end
end
