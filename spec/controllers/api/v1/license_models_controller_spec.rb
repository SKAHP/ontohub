require 'spec_helper'

describe Api::V1::LicenseModelsController do
  context 'on GET to show' do
    let(:license_model) { create :license_model }

    context 'requesting json representation', api_specification: true do
      let(:license_model_schema) { schema_for('license_model') }

      before do
        get :show,
          id: license_model.to_param,
          format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/license_model' do
          expect(response.body).to match_json_schema(license_model_schema)
        end
      end
    end
  end
end
