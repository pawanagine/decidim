# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalVotesHelper do
      let(:organization) { create(:organization) }
      let(:vote_limit) { 10 }
      let(:votes_enabled) { true }
      let(:proposal_feature) { create(:proposal_feature, organization: organization) }
      let(:user) { create(:user, organization: organization) }

      before do
        allow(helper).to receive(:current_user).and_return(user)
        allow(helper).to receive(:current_feature).and_return(proposal_feature)
        allow(helper).to receive(:feature_settings).and_return(double(vote_limit: vote_limit))
        allow(helper).to receive(:current_settings).and_return(double(votes_enabled?: votes_enabled))
      end

      describe "#vote_button_classes" do
        it "returns small buttons classes from proposals list" do
          expect(helper.vote_button_classes(true)).to eq("small")
        end

        it "returns expanded buttons classes if it's not from proposals list'" do
          expect(helper.vote_button_classes(false)).to eq("expanded button--sc")
        end
      end

      describe "#votes_count_classes" do
        it "returns small count classes from proposals list" do
          expect(helper.votes_count_classes(true)).to eq(number: "card__support__number", label: "")
        end

        it "returns expanded count classes if it's not from proposals list'" do
          expect(helper.votes_count_classes(false)).to eq(number: "extra__suport-number", label: "extra__suport-text")
        end
      end

      describe "#vote_limit_enabled?" do
        context "when the current_user is not present" do
          let(:user) { nil }

          it "returns false" do
            expect(helper).to receive(:current_user).and_return(nil)
            expect(helper.vote_limit_enabled?).to be_falsy
          end
        end

        context "when the step_settings votes_enabled is false" do
          let(:votes_enabled) { false }

          it "returns false" do
            expect(helper.vote_limit_enabled?).to be_falsy
          end
        end

        context "when the current_settings vote_limit is not present" do
          let(:vote_limit) { nil }

          it "returns false" do
            expect(helper.vote_limit_enabled?).to be_falsy
          end
        end

        context "when the current_settings vote_limit is less or equal 0" do
          let(:vote_limit) { 0 }

          it "returns false" do
            expect(helper.vote_limit_enabled?).to be_falsy
          end
        end

        context "when the current_settings vote_limit is greater than 0" do
          it "returns true" do
            expect(helper.vote_limit_enabled?).to be_truthy
          end
        end
      end

      describe "#remaining_votes_count_for" do
        it "returns the remaining votes for a user based on the feature votes limit" do
          proposal = create(:proposal, feature: proposal_feature)
          create(:proposal_vote, author: user, proposal: proposal)

          expect(helper.remaining_votes_count_for(user)).to eq(9)
        end
      end
    end
  end
end
