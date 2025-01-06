# Define the URL and local path for the certificate
$certificateUrl = "https://github.com/LITechAdvisors/certificate_install/raw/refs/heads/main/rdwebaccess.cer"
$localCertificatePath = "C:\\Temp\\rdwebaccess.cer"       # Path to save the certificate locally

# Create the Temp folder if it doesn't exist
if (!(Test-Path -Path "C:\\Temp")) {
    New-Item -ItemType Directory -Path "C:\\Temp" | Out-Null
}

# Download the certificate from the URL
try {
    Invoke-WebRequest -Uri $certificateUrl -OutFile $localCertificatePath
    Write-Host "Certificate downloaded successfully to $localCertificatePath"
} catch {
    Write-Host "Failed to download the certificate: $_" -ForegroundColor Red
    exit 1
}

# Import the certificate as a X509Certificate2 object
try {
    $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $certificate.Import($localCertificatePath)
    Write-Host "Certificate loaded successfully."
} catch {
    Write-Host "Failed to load the certificate: $_" -ForegroundColor Red
    exit 1
}

# Open the Local Machine Trusted Root Certification Authorities store
try {
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store -ArgumentList "Root", "LocalMachine"
    $store.Open("ReadWrite")
    $store.Add($certificate)
    $store.Close()
    Write-Host "Certificate installed successfully in the Trusted Root Certification Authorities store."
} catch {
    Write-Host "Failed to install the certificate: $_" -ForegroundColor Red
    exit 1
}

# Cleanup: Remove the local copy of the certificate
Remove-Item -Path $localCertificatePath -Force
Write-Host "Temporary certificate file removed."
