#!/bin/bash
set -ex

bazel build @com_github_bazelbuild_buildtools//buildifier
buildifier=$(bazel info bazel-bin)/external/com_github_bazelbuild_buildtools/buildifier/buildifier
$buildifier -showlog -mode=check \
  $(find . -type f \( -name 'BUILD' -or -name 'WORKSPACE' -or -wholename '.*bazel$' -or -wholename '.*bzl$' \) -print )

NUM_CPU=$(getconf _NPROCESSORS_ONLN)

gometalinter="docker run \
  -v $(bazel info output_base):$(bazel info output_base) \
  -v $(pwd):/go/src/istio.io/pilot \
  gcr.io/istio-testing/linter:bfcc1d6942136fd86eb6f1a6fb328de8398fbd80"
$gometalinter \
  --concurrency=${NUM_CPU} --enable-gc --deadline=300s \
  --disable-all\
  --enable=aligncheck\
  --enable=deadcode\
  --enable=errcheck\
  --enable=gas\
  --enable=goconst\
  --enable=gofmt\
  --enable=goimports\
  --enable=golint\
  --enable=gotype\
  --exclude=.pb.go\
  --exclude=gen_test.go\
  --enable=ineffassign\
  --enable=interfacer\
  --enable=lll --line-length=120\
  --enable=megacheck\
  --enable=misspell\
  --enable=structcheck\
  --enable=unconvert\
  --enable=varcheck\
  --enable=vet\
  --enable=vetshadow\
  /go/src/istio.io/pilot/...

# Disabled linters:
# --enable=dupl\
# --enable=gocyclo\
# --cyclo-over=15\
