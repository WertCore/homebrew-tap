class Klart < Formula
  desc "Brightness for every display attached to the machine, built-in or not"
  homepage "https://github.com/WertCore/klart"
  license any_of: ["MIT", "Apache-2.0"]

  # Source builds are still available, through `--HEAD`. That is where the Rust
  # dependency belongs: asked for rather than imposed.
  head do
    url "https://github.com/WertCore/klart.git", branch: "main"
    depends_on "rust" => :build
  end

  # Released binaries rather than a build from source. Building would pull the
  # whole Rust toolchain onto the machine as a build dependency and leave it
  # there — `brew autoremove` clears it, but few people run that, and asking for
  # a gigabyte to produce a four-hundred-kilobyte binary is a poor trade.
  #
  # There is no quarantine to worry about either: that attribute is set by
  # browsers and LaunchServices rather than by Homebrew's downloader, and the
  # arm64 binaries are ad-hoc signed by the linker as that architecture requires.
  on_macos do
    # Stated as a dependency rather than raised while the formula loads, so that
    # `brew info` and `brew search` keep working on a machine that cannot
    # install it. Nothing is published for Intel and it would not work if it
    # were: the registry walk that finds a monitor's name and its I2C channel
    # matches a class Intel Macs do not publish.
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/WertCore/klart/releases/download/v0.3.0/klart-0.3.0-macos-arm64.zip"
      sha256 "947c3104067e1e99168cef5f880399cfbc44ec160a2f9f9ac47f8a34047dcc06"
    end
  end

  on_linux do
    # No aarch64 build is published yet; `brew install --HEAD klart` builds one.
    depends_on arch: :x86_64

    on_intel do
      url "https://github.com/WertCore/klart/releases/download/v0.3.0/klart-0.3.0-linux-x86_64.tar.gz"
      sha256 "70b3bf3cdc0609315e07b937059b984baf9eed6d3b5c219d99d4bb1af18b5f9b"
    end
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args(path: "cli")
      # The menu bar agent is AppKit and refuses to compile anywhere else.
      system "cargo", "install", *std_cargo_args(path: "tray") if OS.mac?
    elsif OS.mac?
      # The macOS archive is the application bundle, which is what the agent
      # needs when it is launched from Finder. Homebrew installs command line
      # programs, so only the two binaries inside it come across.
      #
      # No `Klart.app/` prefix: an archive with a single top-level directory
      # leaves Homebrew already inside it, so the working directory *is* the
      # bundle.
      bin.install "Contents/MacOS/klart"
      bin.install "Contents/MacOS/klart-tray"
    else
      bin.install "klart"
    end
  end

  # A plain conditional rather than `on_macos`, which does not accept a service
  # block. There is no agent on Linux — it is AppKit and refuses to compile
  # there — so defining one would point at a binary that does not exist, which
  # is what the Linux audit says when it is defined unconditionally.
  if OS.mac?
    service do
      run [opt_bin/"klart-tray"]
      run_type :immediate
      # Deliberately not kept alive: "Quit klart" in the menu should mean quit,
      # and a service that restarted it would make that item do nothing.
      keep_alive false
      log_path var/"log/klart-tray.log"
      error_log_path var/"log/klart-tray.log"
    end
  end

  def caveats
    return unless OS.mac?

    <<~EOS
      The menu bar agent is a separate binary, `klart-tray`. To have it start
      with your session:

        brew services start klart

      Use that rather than `klart autostart`, which registers an application
      bundle with macOS and there is no bundle in a Homebrew install.

      It is worth starting if any display falls back to the gamma ramp — macOS
      reverts a ramp when the process that set it exits, so such a display
      returns to full brightness after every restart unless something is holding
      it. `klart list` marks those with a `*`.
    EOS
  end

  test do
    assert_match "klart #{version}", shell_output("#{bin}/klart --version")

    # A machine with no displays is an answer rather than a failure — the same
    # reason `ls` succeeds on an empty directory — so this holds on a builder
    # with no screen attached.
    assert_match(/IDX|no displays are attached/, shell_output("#{bin}/klart list"))
  end
end
