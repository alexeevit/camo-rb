require "spec_helper"

describe Camo::Logger do
  subject(:logger) { described_class.stdio }
  let(:message) { "Some message" }

  describe ".stdio" do
    subject(:stdio) { described_class.stdio }

    it "creates a logger with standard pipes" do
      expect(stdio.outpipe).to eq($stdout)
      expect(stdio.errpipe).to eq($stderr)
    end
  end

  describe "#info" do
    context "when log_level is info" do
      before { stub_const("Camo::Logger::LOG_LEVEL", "info") }

      it "puts the message to the out pipe" do
        expect { logger.info(message) }.to output("[INFO] #{message}\n").to_stdout
      end
    end

    context "when log_level is error" do
      before { stub_const("Camo::Logger::LOG_LEVEL", "error") }

      it "does nothing" do
        expect { logger.info(message) }.not_to output.to_stdout
      end
    end
  end

  describe "#debug" do
    context "when log_level is debug" do
      before { stub_const("Camo::Logger::LOG_LEVEL", "debug") }

      it "puts the message to the out pipe" do
        expect { logger.debug(message) }.to output("[DEBUG] #{message}\n").to_stdout
      end
    end

    context "when log_level is info" do
      before { stub_const("Camo::Logger::LOG_LEVEL", "info") }

      it "does nothing" do
        expect { logger.debug(message) }.not_to output.to_stdout
      end
    end
  end

  describe "#error" do
    context "when log_level is debug" do
      before { stub_const("Camo::Logger::LOG_LEVEL", "debug") }

      it "puts the message to the err pipe" do
        expect { logger.error(message) }.to output("[ERROR] #{message}\n").to_stderr
      end
    end

    context "when log_level is error" do
      before { stub_const("Camo::Logger::LOG_LEVEL", "error") }

      it "puts the message to the err pipe" do
        expect { logger.error(message) }.to output("[ERROR] #{message}\n").to_stderr
      end
    end
  end

  describe "#compile_output" do
    context "when message is array" do
      it "joins the array with comma" do
        expect(logger.send(:compile_output, :level, ["hello", "world"], {})).to eq("[LEVEL] hello, world")
      end
    end

    context "when there are no params" do
      it "returns only the message" do
        expect(logger.send(:compile_output, :level, message, {})).to eq("[LEVEL] Some message")
      end
    end

    context "when there are params" do
      it "returns the message and the params" do
        expect(logger.send(:compile_output, :level, message, {request: {status: 200}})).to eq('[LEVEL] Some message | { request: { status: "200" } }')
      end
    end
  end
end
