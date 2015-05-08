:: diego-windows-msi

:: Consul agent is in bin/consul.exe

:: Testing

rmdir /S /Q output
mkdir output
::SET GOROOT= C:\Go
SET GOBIN=%CD%\bin
SET DEVENV_PATH=%programfiles(x86)%\Microsoft Visual Studio 12.0\Common7\IDE
SET PATH=%GOBIN%;%GOROOT%;%PATH%;%DEVENV_PATH%
:: TODO: get rid of godeps
SET GOPATH=%CD%
SET CONTAINERIZER_BIN=%CD%\src\\github.com\cloudfoundry-incubator\garden-windows\containerizer\Containerizer\bin\Containerizer.exe

:: Visual Studio must be in path
where devenv
if errorLevel 1 ( echo "devenv was not found on PATH")

:: https://visualstudiogallery.msdn.microsoft.com/9abe329c-9bba-44a1-be59-0fbf6151054d
REGEDIT.EXE  /S  "%~dp0\fix_visual_studio_building_msi.reg" || exit /b 1

:: install the binaries in %GOBIN%
go install github.com/coreos/etcd || exit /b 1
go install github.com/onsi/ginkgo/ginkgo || exit /b 1
go install github.com/onsi/gomega || exit /b 1

pushd src\github.com\cloudfoundry-incubator\garden-windows\containerizer || exit /b 1
  call make.bat || exit /b 1
popd

:: Run the tests

ginkgo -r -noColor src/github.com/cloudfoundry-incubator/garden-windows || exit /b 1
:: windows cmd doesn't like quoting arguments, use -skip=foo.bar instead of -skip='foo bar'
:: we use the dot operator to match anything, -skip expects a regex
ginkgo -skip=reports.garden.containers.as.-1  -r -noColor src/github.com/cloudfoundry-incubator/executor || exit /b 1
ginkgo -skip=when.an.interrupt.signal.is.sent.to.the.representative^|should.not.exit,.but.keep.trying.to.maintain.presence.at.the.same.ID^|The.Rep.Evacuation.when.it.has.running.LRP.containers^|when.a.Ping.request.comes.in -noColor src/github.com/cloudfoundry-incubator/rep || exit /b 1


call scripts\make_msi.bat || exit /b 1

pushd src\github.com\cloudfoundry-incubator\windows_app_lifecycle || exit /b 1
  call make.bat || exit /b 1
  xcopy windows_app_lifecycle-*.tgz ..\..\..\..\output\ || exit /b 1
popd
