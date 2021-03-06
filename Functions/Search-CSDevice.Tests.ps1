﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.','.'
. "$here\$sut"
. ./Invoke-CSRestMethod.ps1

Describe "Construct-FilterString" {
  $TestCases = @(
    [ordered]@{},
    [ordered]@{ hostname = "test" },
    [ordered]@{ local_ip = "1.1.1.1"; external_ip = "2.2.2.2" },
    [ordered]@{ hostname = "test04";
      local_ip = "3.3.3.3";
      external_ip = "4.4.4.4";
      os_version = "Windows 7";
      platform_name = "Windows";
      status = "Normal" }
  )

  It "No params" {
    $q = [ordered]@{}
    $expect = ""
    Construct-FilterString $q | Should Be $expect
  }
  It "One params" {
    $q = [ordered]@{ hostname = "test" }
    $expect = "hostname:'$($q.hostname)'"
    Construct-FilterString $q | Should Be $expect
  }
  It "Two params" {
    $q = [ordered]@{ local_ip = "1.1.1.1"; external_ip = "2.2.2.2" }
    $expect = "local_ip:'$($q.local_ip)'+external_ip:'$($q.external_ip)'"
    Construct-FilterString $q | Should Be $expect
  }

  It "ProductType" {
    $q = @{ product_type_desc = "Server" }
    $expect = "product_type_desc:'$($q.product_type_desc)'"
    Construct-FilterString $q | Should Be $expect
  }

  It "all params" {
    $q = [ordered]@{ hostname = "test04";
      local_ip = "3.3.3.3";
      external_ip = "4.4.4.4";
      os_version = "Windows 7";
      platform_name = "Windows";
      status = "Normal"
    }

    $expect = "hostname:'$($q.hostname)'+local_ip:'$($q.local_ip)'+external_ip:'$($q.external_ip)'+os_version:'$($q.os_version)'+platform_name:'$($q.platform_name)'+status:'$($q.status)'"
    Construct-FilterString $q | Should Be $expect
  }
}

Describe "Search-CSDevice" {

  $RetAids = @(
    "ea2085de804f4dde7053af48828889cb",
    "01e90d6de67344d544ac1a009b708dc6",
    "f114d3fa9a0b465e42770091b0148c6c",
    "9447cb4a2b694d525ab0da85528fb1b8",
    "a147e79c127247967d8c3e9c3fd66336"
  )

  It "Search-CSDevice will be called Aids count if AidOnly is OFF. (In this test, Aids count is 5.)" {
    Mock Search-CSDeviceAids { return $RetAids } -Scope It
    Mock Search-CSDeviceDetail { return "Success" } -Scope It
    Search-CSDevice -HostName "Test" | Should be "Success"
    Assert-MockCalled -CommandName Search-CSDeviceAids -Time 1 -Exactly -Scope It
    Assert-MockCalled -CommandName Search-CSDeviceDetail -Time 5 -Exactly -Scope It
  }

  It "Not search-detail if AidOnly is ON." {
    Mock Search-CSDeviceAids { return $RetAids } -Scope It
    Mock Search-CSDeviceDetail { return "Error. Search-CSDeviceDetail should not be called if AidOnly is ON." } -Scope It
    Search-CSDevice -HostName "Test" -AidOnly | Should be $RetAids
    Assert-MockCalled -CommandName Search-CSDeviceAids -Time 1 -Exactly -Scope It
    Assert-MockCalled -CommandName Search-CSDeviceDetail -Time 0 -Exactly -Scope It
  }
}

