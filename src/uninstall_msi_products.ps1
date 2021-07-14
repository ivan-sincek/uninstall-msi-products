function Uninstall ($mode, $list) {
	if ($mode -eq "one") {
		$guid = $(Read-Host -Prompt "Enter identifying number").Trim();
		Write-Host "";
		if ($guid.Length -lt 1) {
			Write-Host "Identifying number is required";
		} else {
			$exists = $false;
			foreach ($product in $list) {
				if ($product.IdentifyingNumber -eq $guid) {
					$exists = $true;
					break;
				}
			}
			if ($exists) {
				try {
					Start-Process -FilePath "msiexec.exe" -ArgumentList "/x `"$($guid)`"" -NoNewWindow;
					Write-Host "You should now be able to see an uninstall window...";
				} catch {
					Write-Host $_.Exception;
				}
			} else {
				Write-Host "Product has not been found";
			}
		}
	} elseif ($mode -eq "all") {
		try {
			foreach ($product in $list) {
				Start-Process -FilePath "msiexec.exe" -ArgumentList "/x `"$($product.IdentifyingNumber)`" /qn /norestart" -NoNewWindow;
			}
			Write-Host "Uninstallation completed successfully";
		} catch {
			Write-Host $_.Exception;
		}
	}
}

$products = $null;
try {
	Write-Host "Fetching the list of MSI products, this may take a while...";
	$products = Get-WmiObject -Class Win32_Product;
	if ($($products | Measure).Count -lt 1) {
		Write-Host "";
		Write-Host "No installed products were found";
	} else {
		$products | Sort-Object -Property Vendor, Name, Version | Format-List -Property IdentifyingNumber, Name, Version, Vendor, LocalPackage, PackageName;
		Write-Host "[1] [Prompt] Uninstall One ";
		Write-Host "[2] [Silent] Uninstall All ";
		Write-Host "---------------------------";
		$choice = $(Read-Host -Prompt "Your choice").Trim();
		Write-Host "";
		if ($choice -eq "1") {
			Uninstall -Mode "one" -List $products;
		} elseif ($choice -eq "2") {
			$confirm = $(Read-Host -Prompt "Confirm (yes)").Trim();
			if ($confirm -eq "yes") {
				Write-Host "";
				Uninstall -Mode "all" -List $products;
			}
		} else {
			Write-Host "Invalid choice";
		}
	}
} catch {
	Write-Host $_.Exception.InnerException.Message;
} finally {
	if ($products -ne $null) {
		$products.Dispose();
	}
}
