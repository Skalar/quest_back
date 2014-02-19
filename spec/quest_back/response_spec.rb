require 'spec_helper'

describe QuestBack::Response, type: :request do
  let(:http) do
    double(
      body: success_fixture_for('get_quests'),
      error?: false
    )
  end
  let(:globals) { {} }
  let(:locals) { {} }
  let(:savon_response) { Savon::Response.new(http, globals, locals) }

  subject { described_class.new savon_response, :get_quests }


  describe "#result" do
    it "responds to it" do
      expect(subject).to respond_to :result
    end

    it "returns the inner result of it's body" do
      expect(subject.result).to eq savon_response.body['GetQuestsResponse']['GetQuestsResult']
    end
  end
end
