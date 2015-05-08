SET GOBIN=%CD%\DiegoWindowsMSI\DiegoWindowsMSI\go-executables

:: Install metron, it contains all relevant gocode inside itself.
pushd src\github.com\cloudfoundry\loggregator || exit /b 1
  SET OLD_GOPATH=%GOPATH%
  SET GOPATH=%CD%
  go install metron || exit /b 1
  SET GOPATH=%OLD_GOPATH%
popd

:: Install the garden-windows, rep and executor in the MSI go-executables directory
go install github.com/cloudfoundry-incubator/garden-windows || exit /b 1
go install github.com/cloudfoundry-incubator/executor/cmd/executor || exit /b 1
go install github.com/cloudfoundry-incubator/rep/cmd/rep || exit /b 1
copy bin\consul.exe %GOBIN%

for /f "tokens=*" %%a in ('git rev-parse --short HEAD') do (
    set VERSION=%%a
)

REM  pushd src\github.com\cloudfoundry-incubator\garden-windows\Containerizer || exit /b 1
  REM  :: call make.bat
  REM  rmdir /S /Q packages
  REM  nuget restore || exit /b 1

  REM  pushd IronFrame || exit /b 1
    REM  rmdir /S /Q packages
    REM  nuget restore || exit /b 1
  REM  popd
REM  popd

pushd DiegoWindowsMSI || exit /b 1
  rmdir /S /Q packages
  REM  nuget restore || exit /b 1
  echo SHA: %VERSION% > RELEASE_SHA
  devenv DiegoWindowsMSI\DiegoWindowsMSI.vdproj /build "Release" || exit /b 1
  xcopy DiegoWindowsMSI\Release\DiegoWindowsMSI.msi ..\output\ || exit /b 1
popd
move /Y output\DiegoWindowsMSI.msi output\DiegoWindowsMSI-%VERSION%.msi || exit /b 1
