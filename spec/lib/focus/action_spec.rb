require "spec_helper"

RSpec.describe Focus::Action do
  subject { described_class.new }

  it "exists" do
    expect { subject }.to_not raise_error
  end

  describe "#config" do
    let(:context) { double(:context) }

    before do
      allow(subject).to receive(:context).and_return context
    end

    it "is defined" do
      expect(subject).to respond_to :config
    end

    it "defaults to whatever is in context" do
      allow(context).to receive(:foo).and_return :context_foo
      expect(subject.config.foo).to eq(:context_foo)
    end

    it "uses Focus::Config if there is no configuration in the context" do
      allow(context).to receive(:foo).and_return nil
      allow(Focus::Config).to receive(:foo).and_return :config_foo
      expect(subject.config.foo).to eq(:config_foo)
    end
  end
end
