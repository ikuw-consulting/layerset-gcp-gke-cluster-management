#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_manifest="${repo_root}/KaptainPM.yaml"
source_manifest="${repo_root}/src/layerset/KaptainPM.yaml"
readme="${repo_root}/README.md"
release_version_file="${repo_root}/version.txt"
workflow="${repo_root}/.github/workflows/build.yaml"

compatible_layer='    - layer-gcp-gke-cluster-management:[1.1.0,2.0)'
legacy_layer='    - layer-gcp-gke-cluster-management:[1.0,2.0)'
downstream_contract='layerset-gcp-gke-cluster-management:[1.1.0,2.0)'
version_pattern="          pattern: '^([0-9]+\\.[0-9]+\\.[0-9]+)$'"
pinned_workflow='    uses: kube-kaptain/buildon-github-actions/.github/workflows/layer-and-layerset-build.yaml@1.1.46'

require_exact_line() {
  local file="$1"
  local expected="$2"
  local description="$3"
  local count

  count="$(grep -Fxc -- "${expected}" "${file}" || true)"
  if [[ "${count}" != "1" ]]; then
    printf 'expected exactly one %s in %s, found %s\n' \
      "${description}" "${file#"${repo_root}"/}" "${count}" >&2
    return 1
  fi
}

require_text() {
  local file="$1"
  local expected="$2"
  local description="$3"

  if ! grep -Fq -- "${expected}" "${file}"; then
    printf 'missing %s in %s: %s\n' \
      "${description}" "${file#"${repo_root}"/}" "${expected}" >&2
    return 1
  fi
}

extract_workflow_job() {
  local file="$1"
  local job="$2"

  awk -v job="  ${job}:" '
    $0 == job {
      found = 1
      print
      next
    }
    found && $0 ~ /^  [[:alnum:]_-]+:$/ {
      exit
    }
    found {
      print
    }
    END {
      if (!found) {
        exit 1
      }
    }
  ' "${file}"
}

require_exact_line \
  "${build_manifest}" \
  'apiVersion: kaptain.org/1.22' \
  'Kaptain 1.22 API version'
require_exact_line \
  "${build_manifest}" \
  "        maxParts: '3'" \
  'three-part release limit'
require_exact_line \
  "${build_manifest}" \
  '        strategy: file-pattern-match' \
  'file-backed release strategy'
require_exact_line \
  "${build_manifest}" \
  '        patternType: custom' \
  'custom release-version pattern type'
require_exact_line \
  "${build_manifest}" \
  '        useSourceVersionExact: true' \
  'exact source-version mode'
require_exact_line \
  "${build_manifest}" \
  '          subPath: .' \
  'release-version source path'
require_exact_line \
  "${build_manifest}" \
  '          fileName: version.txt' \
  'release-version source file'
require_exact_line \
  "${build_manifest}" \
  "${version_pattern}" \
  'three-part release-version pattern'
require_exact_line \
  "${release_version_file}" \
  '1.1.0' \
  'first consumer-safe release version'

release_version_lines="$(wc -l < "${release_version_file}" | tr -d '[:space:]')"
if [[ "${release_version_lines}" != "1" ]]; then
  printf 'expected version.txt to contain exactly one line, found %s\n' \
    "${release_version_lines}" >&2
  exit 1
fi

require_exact_line \
  "${source_manifest}" \
  "${compatible_layer}" \
  'consumer-safe GKE management layer range'

if grep -Fq -- "${legacy_layer}" "${source_manifest}"; then
  printf 'legacy pre-consumer-mode layer range remains in %s\n' \
    "${source_manifest#"${repo_root}"/}" >&2
  exit 1
fi

require_text \
  "${readme}" \
  "${downstream_contract}" \
  'downstream consumer range'
require_text \
  "${readme}" \
  'not been published yet' \
  'unpublished-release warning'

build_job="$(extract_workflow_job "${workflow}" build)"
for expected in \
  '    needs: validate' \
  "${pinned_workflow}" \
  '      contents: write' \
  '      packages: write' \
  '      checks: write'; do
  if ! grep -Fqx -- "${expected}" <<< "${build_job}"; then
    printf 'build workflow job is missing required contract line: %s\n' \
      "${expected}" >&2
    exit 1
  fi
done

printf 'layerset compatibility contract is valid\n'
