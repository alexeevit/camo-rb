require 'spec_helper'

describe Camo::Logger do
  subject(:logger) { described_class.stdio }
  let(:message) { 'Some message' }

  describe '.stdio' do
    it 'creates a logger with standard pipes' do
      stdio = described_class.stdio
      expect(stdio.outpipe).to eq($stdout)
      expect(stdio.errpipe).to eq($stderr)
    end
  end

  describe '#debug' do
    it 'puts the message to the out pipe' do
      expect { logger.debug(message) }.to output("#{message}\n").to_stdout
    end
  end

  describe '#error' do
    it 'puts the message to the err pipe' do
      expect { logger.error(message) }.to output("#{message}\n").to_stderr
    end
  end
end
