require 'spec_helper'

describe ProofsController do
  let(:prover) { create :prover }
  let(:theorem) { create :theorem }
  let(:ontology) { theorem.ontology }
  let(:repository) { ontology.repository }
  let(:proof_params) do
    {'prover_ids' => [prover.id.to_s, ''],
     'timeout' => '',
     'axiom_selection_method' => 'manual_axiom_selection',
     'axioms' => [''],
     'sine_axiom_selection' => {'commonness_threshold'=>'0',
                                'depth_limit'=>'-1',
                                'tolerance'=>'1.0'}}
  end

  context 'on ontology' do
    context 'signed in with write access' do
      let(:user) { create(:permission, item: repository).subject }
      before { sign_in user }

      context 'new' do
        before do
          get :new,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param
        end

        it { should respond_with :ok }
        it { should render_template :new }
      end

      context 'create' do
        before do
          allow(Proof).to receive(:new).and_call_original
          expect_any_instance_of(Proof).to receive(:save!)
          post :create,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            proof: proof_params
        end

        it 'set the flash/success' do
          expect(flash[:success]).not_to be(nil)
        end

        it { should respond_with :found }

        it 'redirect to the theorems view' do
          expect(response).to redirect_to(url_for([ontology, :theorems]))
        end

        it 'instantiates a Proof object' do
          expect(Proof).to have_received(:new).with(request.params)
        end
      end

      context 'create with wrong prover' do
        let(:bad_proof_params) { proof_params.merge({'prover_ids' => ['-1', '']}) }
        before do
          allow(Proof).to receive(:new).and_call_original
          expect_any_instance_of(Proof).not_to receive(:save!)
          post :create,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            proof: bad_proof_params
        end

        it 'set the flash/alert' do
          expect(flash[:alert]).not_to be(nil)
        end

        it { should respond_with :found }

        it 'redirect to the new action again' do
          expect(response).to redirect_to(action: :new,
                                          params: {proof: bad_proof_params})
        end

        it 'instantiates a Proof object' do
          expect(Proof).to have_received(:new).with(request.params)
        end
      end
    end

    context 'signed in, without write access' do
      let(:user) { create :user }
      before do
        sign_in user
        post :create,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param
      end

      it 'set the flash/alert' do
        expect(flash[:alert]).to match(/not authorized/)
      end

      it 'redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'not signed in' do
      let(:user) { create :user }
      before do
        sign_in user
        post :create,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param
      end

      it 'set the flash/alert' do
        expect(flash[:alert]).to match(/not authorized/)
      end

      it 'redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context 'on theorem' do
    context 'signed in with write access' do
      let(:user) { create(:permission, item: repository).subject }
      before { sign_in user }

      context 'new' do
        before do
          get :new,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            theorem_id: theorem.to_param
        end

        it { should respond_with :ok }
        it { should render_template :new }
      end

      context 'create' do
        before do
          allow(Proof).to receive(:new).and_call_original
          expect_any_instance_of(Proof).to receive(:save!)
          post :create,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            theorem_id: theorem.to_param,
            proof: proof_params
        end

        it 'set the flash/success' do
          expect(flash[:success]).not_to be(nil)
        end

        it { should respond_with :found }

        it 'redirect to the proof_attempts index' do
          expect(response).
            to redirect_to(url_for([theorem, :proof_attempts]))
        end

        it 'instantiates a Proof object' do
          expect(Proof).to have_received(:new).with(request.params)
        end
      end

      context 'create with wrong prover' do
        let(:bad_proof_params) { proof_params.merge({'prover_ids' => ['-1', '']}) }
        before do
          allow(Proof).to receive(:new).and_call_original
          expect_any_instance_of(Proof).not_to receive(:save!)
          post :create,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            theorem_id: theorem.to_param,
            proof: bad_proof_params
        end

        it 'set the flash/alert' do
          expect(flash[:alert]).not_to be(nil)
        end

        it { should respond_with :found }

        it 'redirect to the new action again' do
          expect(response).to redirect_to(action: :new,
                                          params: {proof: bad_proof_params})
        end

        it 'instantiates a Proof object' do
          expect(Proof).to have_received(:new).with(request.params)
        end
      end
    end

    context 'signed in, without write access' do
      let(:user) { create :user }
      before do
        sign_in user
        post :create,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          theorem_id: theorem.to_param
      end

      it 'set the flash/alert' do
        expect(flash[:alert]).to match(/not authorized/)
      end

      it 'redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'not signed in' do
      let(:user) { create :user }
      before do
        sign_in user
        post :create,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          theorem_id: theorem.to_param
      end

      it 'set the flash/alert' do
        expect(flash[:alert]).to match(/not authorized/)
      end

      it 'redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
