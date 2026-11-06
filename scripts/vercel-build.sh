#!/usr/bin/env bash
set -euo pipefail

flutter_dir="${HOME}/flutter"
flutter_bin="$(command -v flutter || true)"
if [ -z "${flutter_bin}" ] && [ ! -x "${flutter_dir}/bin/flutter" ]; then
  release_url="$(
    curl --fail --silent --show-error \
      https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json |
      node -e '
        let input = "";
        process.stdin.on("data", chunk => input += chunk);
        process.stdin.on("end", () => {
          const manifest = JSON.parse(input);
          const stable = manifest.releases.find(release => release.channel === "stable");
          process.stdout.write(`${manifest.base_url}/${stable.archive}`);
        });
      '
  )"
  mkdir -p "${HOME}"
  curl --fail --silent --show-error --location "${release_url}" | tar -xJ -C "${HOME}"
fi

if [ -z "${flutter_bin}" ]; then
  flutter_bin="${flutter_dir}/bin/flutter"
fi

"${flutter_bin}" config --no-analytics
"${flutter_bin}" pub get
"${flutter_bin}" build web --release --base-href /
