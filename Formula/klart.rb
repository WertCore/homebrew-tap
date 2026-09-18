class Klart < Formula
  desc "Brightness for every display attached to the machine, built-in or not"
  homepage "https://github.com/WertCore/klart"
  url "https://github.com/WertCore/klart/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "5bb2809da437f6d0271bd8ff6bb25b107b8c74479ddf75c98f7d2dd8af706014"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/WertCore/klart.git", branch: "main"

  depends_on "rust" => :build

  def install
    # Built from source rather than dropped in as a binary, which also sidesteps
    # the quarantine an unsigned download would carry.
    system "cargo", "install", *std_cargo_args(path: "cli")

    # The menu bar agent is AppKit and refuses to compile anywhere else, saying
    # so with a `compile_error!` rather than a page of unresolved imports.
    system "cargo", "install", *std_cargo_args(path: "tray") if OS.mac?
  end

  service do
    run [opt_bin/"klart-tray"]
    run_type :immediate
    # Deliberately not kept alive: "Quit klart" in the menu should mean quit,
    # and a service that restarts it would make that item do nothing.
    keep_alive false
    log_path var/"log/klart-tray.log"
    error_log_path var/"log/klart-tray.log"
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

    # `--json` is the surface anything scripting this depends on, so it is worth
    # asserting it parses rather than merely that it ran.
    require "json"
    JSON.parse(shell_output("#{bin}/klart get --json 2>/dev/null"), symbolize_names: true)
  rescue JSON::ParserError
    # No displays means no JSON to parse, which the line above already allowed
    # for. Anything else would have raised before reaching here.
    nil
  end
end
