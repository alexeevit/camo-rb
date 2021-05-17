require 'spec_helper'

describe Camo::Logger do
  subject(:logger) { described_class.stdio }
  let(:message) { 'Some message' }

  describe '.stdio' do
    subject(:stdio) { described_class.stdio }

    it 'creates a logger with standard pipes' do
      expect(stdio.outpipe).to eq($stdout)
      expect(stdio.errpipe).to eq($stderr)
    end
  end

  describe '#debug' do
    context 'when log_level is debug' do
      before { stub_const('Camo::Logger::LOG_LEVEL', 'debug') }

      it 'puts the message to the out pipe' do
        expect { logger.debug(message) }.to output("#{message}\n").to_stdout
      end
    end

    context 'when log_level is error' do
      before { stub_const('Camo::Logger::LOG_LEVEL', 'error') }

      it 'does nothing' do
        expect { logger.debug(message) }.not_to output.to_stdout
      end
    end
  end

  describe '#error' do
    context 'when log_level is debug' do
      before { stub_const('Camo::Logger::LOG_LEVEL', 'debug') }

      it 'puts the message to the err pipe' do
        expect { logger.error(message) }.to output("#{message}\n").to_stderr
      end
    end

    context 'when log_level is error' do
      before { stub_const('Camo::Logger::LOG_LEVEL', 'error') }

      it 'puts the message to the err pipe' do
        expect { logger.error(message) }.to output("#{message}\n").to_stderr
      end
    end

    context 'when log_level is fatal' do
      before { stub_const('Camo::Logger::LOG_LEVEL', 'fatal') }

      it 'does nothing' do
        expect { logger.error(message) }.not_to output.to_stdout
      end
    end
  end

  describe '#compile_output' do
    context 'when message is array' do
      it 'joins the array with comma' do
        expect(logger.send(:compile_output, ['hello', 'world'], {})).to eq('hello, world')
      end
    end

    context 'when there are no params' do
      it 'returns only the message' do
        expect(logger.send(:compile_output, message, {})).to eq('Some message')
      end
    end

    context 'when there are params' do
      it 'returns the message and the params' do
        expect(logger.send(:compile_output, message, { request: { status: 200 } })).to eq('Some message | { request: { status: "200" } }')
      end
    end
  end
end
