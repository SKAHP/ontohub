require 'spec_helper'

describe ProofAttempt do
  context 'Associations' do
    it { should belong_to(:theorem) }
    it { should belong_to(:proof_status) }
    it { should belong_to(:proof_attempt_configuration) }
    it { should have_one(:prover_output) }
    it { should have_one(:tactic_script) }
  end

  let(:proof_attempt) { create :proof_attempt }

  context 'Updating Theorem Proof Status' do
    let(:proven) { create :proof_status_proven }
    let(:theorem) { proof_attempt.theorem }

    before do
      allow(theorem).to receive(:update_proof_status!)
      proof_attempt.proof_status = proven
      proof_attempt.save!
    end

    it 'calls update_status on the theorem' do
      expect(theorem).to have_received(:update_proof_status!)
    end
  end

  context 'state' do
    it "is 'pending'" do
      expect(proof_attempt.state).to eq('pending')
    end
  end

  context 'retry_failed' do
    let(:theorem) { proof_attempt.theorem }
    let(:pac) { proof_attempt.proof_attempt_configuration }
    before do
      proof_attempt.update_state!(:failed)
      allow(ProofExecutionWorker).to receive(:perform_async)
      proof_attempt.retry_failed
    end

    it 'calls perform_async' do
      expect(ProofExecutionWorker).
        to have_received(:perform_async).with(proof_attempt.id)
    end
  end
end
