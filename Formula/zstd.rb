class Zstd < Formula
  desc "Zstandard is a real-time compression algorithm"
  homepage "http://zstd.net/"
  url "https://github.com/facebook/zstd/archive/v1.3.5.tar.gz"
  sha256 "d6e1559e4cdb7c4226767d4ddc990bff5f9aab77085ff0d0490c828b025e2eea"

  bottle do
    cellar :any
    sha256 "85584f4a814eb5b29942ba9592416bbb042df83394cf413140109470431bd729" => :high_sierra
    sha256 "59af401ee0f9bf3cae57e4f035f1d7f62b7fdc44f34ccd384c343dc0a68c8ff6" => :sierra
    sha256 "ce6df98dc4ebb218c5189cd5e30fa46c665f4917843a75935d0b9adf9a1baf86" => :el_capitan
    sha256 "304d5330673b5d4aae229474cf6cebf526b98b72a204db1053c592db257b2ee2" => :x86_64_linux
  end

  option "without-pzstd", "Build without parallel (de-)compression tool"

  depends_on "cmake" => :build
  depends_on "zlib" unless OS.mac?

  def install
    system "make", "install", "PREFIX=#{prefix}/"

    if build.with? "pzstd"
      system "make", "-C", "contrib/pzstd", "googletest"
      system "make", "-C", "contrib/pzstd", "PREFIX=#{prefix}"
      bin.install "contrib/pzstd/pzstd"
    end
  end

  test do
    assert_equal "hello\n",
      pipe_output("#{bin}/zstd | #{bin}/zstd -d", "hello\n", 0)

    if build.with? "pzstd"
      assert_equal "hello\n",
        pipe_output("#{bin}/pzstd | #{bin}/pzstd -d", "hello\n", 0)
    end
  end
end
