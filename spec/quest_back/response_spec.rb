require 'spec_helper'

describe QuestBack::Response, type: :request do
  let(:http) do
    double(
      body: success_fixture_for('get_quests'),
      error?: false
    )
  end
  let(:globals) { Savon::GlobalOptions.new }
  let(:locals) { {} }
  let(:savon_response) { Savon::Response.new(http, globals, locals) }

  subject { described_class.new savon_response, operation_name: :get_quests, result_key_nestings: [:quests, :quest] }


  describe "#result" do
    context "singular result" do
      before { http.stub(:body).and_return success_fixture_for('get_quests') }

      it "returns the result of it's body" do
        expect(subject.result).to eq savon_response.body[:get_quests_response][:get_quests_result][:quests][:quest]
      end
    end

    context "multiple result" do
      before { http.stub(:body).and_return success_fixture_for('get_quests_multiple_response') }

      it "fails" do
        expect { subject.result }.to raise_error QuestBack::Error::MultipleResultsFound
      end
    end
  end

  describe "#results" do
    context "singular result" do
      before { http.stub(:body).and_return success_fixture_for('get_quests') }

      it "returns the result of it's body wrapped in an array" do
        expect(subject.results).to eq Array.wrap(savon_response.body[:get_quests_response][:get_quests_result][:quests][:quest])
      end
    end

    context "multiple result" do
      before { http.stub(:body).and_return success_fixture_for('get_quests_multiple_response') }

      it "returns the result" do
        expect(subject.results).to eq savon_response.body[:get_quests_response][:get_quests_result][:quests][:quest]
      end
    end
  end
end
