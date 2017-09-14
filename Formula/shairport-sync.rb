class ShairportSync < Formula
  desc "AirTunes emulator. Shairport Sync adds multi-room capability."
  homepage "https://github.com/mikebrady/shairport-sync"
  url "https://github.com/mikebrady/shairport-sync/archive/3.1.2.tar.gz"
  sha256 "8c13f7ebbd417e8cab07ea9f74392ced0f54315d8697d4513580f472859a9c65"
  head "https://github.com/mikebrady/shairport-sync.git", :branch => "development"

  bottle do
    sha256 "dd52fdf8231291935fbe2abb210ae311b734867f7fb8c8b3b14ba2b7b2d8e1f1" => :sierra
    sha256 "84839e394d2fad0c09e3b46ff2dad5cdecea4c3be76bc20f4bbdfd047a3a618c" => :el_capitan
    sha256 "fbeda2021f5b2dbd1f8a8c05b54eefe1b5469197a7f93e621010573901f66765" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "openssl"
  depends_on "popt"
  depends_on "libsoxr"
  depends_on "libao"
  depends_on "libdaemon"
  depends_on "libconfig"

  def install
    system "autoreconf", "-fvi"
    args = %W[
      --with-os=darwin
      --with-ssl=openssl
      --with-ao
      --with-stdout
      --with-pipe
      --with-soxr
      --with-metadata
      --with-piddir=#{var}/run
      --sysconfdir=#{etc}/shairport-sync
      --prefix=#{prefix}
    ]
    args << "--with-dns_sd" if OS.mac? # Disable bonjour in Linux
    system "./configure", *args
    system "make", "install"
  end

  def post_install
    (var/"run").mkpath
  end

  test do
    output = shell_output("#{bin}/shairport-sync -V", 1)
    assert_match "OpenSSL-ao-stdout-pipe-soxr-metadata", output
  end
end
