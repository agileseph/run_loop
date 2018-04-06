
describe RunLoop::PhysicalDevice::IOSDeviceManager do

  if RunLoop::Environment.ci?
    it "skipping tests on CI" do
      expect(true).to be == true
    end
  else

    Resources.shared.xcode_install_paths.each do |xcode_path|
      Resources.shared.with_developer_dir(xcode_path) do
        connected_devices = Resources.shared.physical_devices_for_testing

        if connected_devices.empty?
          it "skipping physical device tests because no devices are connected" do
            expect(true).to be == true
          end
        else

          before do
            #allow(RunLoop::Environment).to receive(:debug?).and_return(true)
          end

          # For every installed Xcode
          context "#{xcode_path}" do

            # For every connected (compatible) device
            connected_devices.each do |device|
              device_str = %Q['#{device.name} (#{device.version.to_s})']

              # Run these tests

              context "#app_installed?" do
                it "returns true if app is installed on #{device_str}" do
                  idm = RunLoop::PhysicalDevice::IOSDeviceManager.new(device)
                  expect(idm.app_installed?("com.apple.Preferences")).to be_truthy
                end

                it "returns false if app is not installed on #{device_str}" do
                  idm = RunLoop::PhysicalDevice::IOSDeviceManager.new(device)
                  expect(idm.app_installed?("com.example.MyApp")).to be_falsey
                end
              end

            end
          end
        end
      end
    end
  end
end
