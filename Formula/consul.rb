class Consul < Formula
  desc "Tool for service discovery, monitoring and configuration"
  homepage "https://www.consul.io"
  url "https://github.com/hashicorp/consul.git",
      :tag => "v1.2.1",
      :revision => "39f93f011e591c842acc8053a7f5972aa6e592fd"
  head "https://github.com/hashicorp/consul.git",
       :shallow => false

  bottle do
    cellar :any_skip_relocation
    sha256 "ebd69f5dbef52aa71982370f7695cefdfb9a31efd3f153821e56003230230d24" => :high_sierra
    sha256 "befa97a8a08c8bfc1db0ff4ee92d26871e5a8df4852e83080e100332861efa4b" => :sierra
    sha256 "bae08713b1574ddeb20ff25cd825deb652c151cdc470991f77edb9db4cc22795" => :el_capitan
    sha256 "c9eb1659d92a23cb2255edfdf45a02bd84890d078163a7b65b379be19421723d" => :x86_64_linux
  end

  depends_on "go" => :build
  depends_on "gox" => :build
  depends_on "zip" => :build unless OS.mac?

  def install
    inreplace *(OS.mac? ? "scripts/build.sh" : "build-support/functions/20-build.sh"), "-tags=\"${GOTAGS}\" \\", "-tags=\"${GOTAGS}\" -parallel=4 \\"

    # Avoid running `go get`
    inreplace "GNUmakefile", "go get -u -v $(GOTOOLS)", ""

    ENV["XC_OS"] = OS.mac? ? "darwin" : "linux"
    ENV["XC_ARCH"] = MacOS.prefer_64_bit? ? "amd64" : "386" if OS.mac?
    ENV["XC_ARCH"] = "amd64" unless OS.mac?
    ENV["GOPATH"] = buildpath
    contents = Dir["{*,.git,.gitignore}"]
    (buildpath/"src/github.com/hashicorp/consul").install contents

    (buildpath/"bin").mkpath

    cd "src/github.com/hashicorp/consul" do
      system "make"
      bin.install "bin/consul"
      prefix.install_metafiles
    end
  end

  plist_options :manual => "consul agent -dev -advertise 127.0.0.1"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/consul</string>
          <string>agent</string>
          <string>-dev</string>
          <string>-advertise</string>
          <string>127.0.0.1</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/consul.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/consul.log</string>
      </dict>
    </plist>
  EOS
  end

  test do
    # Workaround for Error creating agent: Failed to get advertise address: Multiple private IPs found. Please configure one.
    return if ENV["CIRCLECI"] || ENV["TRAVIS"]

    fork do
      exec "#{bin}/consul", "agent", *("-bind" unless OS.mac?), *("127.0.0.1" unless OS.mac?), "-data-dir", "."
    end
    sleep 3
    system "#{bin}/consul", "leave"
  end
end
