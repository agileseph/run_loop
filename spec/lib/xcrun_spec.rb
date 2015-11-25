# encoding: utf-8

describe RunLoop::Xcrun do

  let(:xcrun) { RunLoop::Xcrun.new }

  let(:process_status) do
    # It is not possible call Process::Status.new
    `echo`
    $?
  end

  let(:command_output) do
    {
          :out => '',
          :status => process_status
    }
  end

  describe '#exec' do
    it 'raises an error if arg is not an Array' do
      expect do
        xcrun.exec('simctl list devices')
      end.to raise_error ArgumentError, /Expected args/
    end

    it 'raises an error if any arg is not a string' do
      expect do
        xcrun.exec(['sleep', 5])
      end.to raise_error ArgumentError,
      /Expected arg '5' to be a String, but found 'Fixnum'/
    end

    it 're-raises error thrown by CommandRunner' do
      expect(CommandRunner).to receive(:run).and_raise RuntimeError, 'Some error'

      expect do
        xcrun.exec(['sleep', '0.5'])
      end.to raise_error RunLoop::Xcrun::Error, /Some error/
    end

    describe 'raises timeout error if CommandRunner timed out' do
      it 'mocked' do
        expect(process_status).to receive(:exitstatus).and_return(nil)
        expect(CommandRunner).to receive(:run).and_return(command_output)

        expect do
          xcrun.exec(['sleep', '0.5'])
        end.to raise_error RunLoop::Xcrun::TimeoutError, /Xcrun timed out after/
      end

      it 'actual' do
        expect do
          xcrun.exec(['sleep', '0.5'], timeout: 0.05)
        end.to raise_error RunLoop::Xcrun::TimeoutError, /Xcrun timed out after/
      end
    end

    it 'forces UTF-8 encoding and chomps' do
      # Force C (non UTF-8 encoding)
      stub_env({'LC_ALL' => 'C'})
      args = ['cat', 'spec/resources/encoding.txt']

      # Confirm that the string is read as ASCII whatever
      command_runner_hash = CommandRunner.run(args, timeout: 0.2)
      command_runner_out = command_runner_hash[:out]
      expect(command_runner_out.length).to be == 20

      xcrun_hash = xcrun.exec(args, timout: 0.2)
      xcrun_out = xcrun_hash[:out]

      expect(xcrun_out).to be == 'ITZVÃ ●℆❡♡'
    end

    describe 'contents of returned hash' do
      it 'mocked' do
        expect(process_status).to receive(:exitstatus).and_return(256)
        expect(process_status).to receive(:pid).and_return(3030)
        command_output[:out] = 'mocked'
        expect(CommandRunner).to receive(:run).and_return(command_output)

        xcrun_hash = xcrun.exec(['sleep', '0.1'])

        expect(xcrun_hash[:out]).to be == 'mocked'
        expect(xcrun_hash[:pid]).to be == 3030
        expect(xcrun_hash[:exit_status]).to be == 256
      end
    end
  end
end

