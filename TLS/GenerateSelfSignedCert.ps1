New-SelfSignedCertificate -KeyExportPolicy Exportable -Subject "CN=sql2025" -NotBefore (Get-Date) -NotAfter (Get-Date).AddMonths(6) -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1") -CertStoreLocation "Cert:\LocalMachine\My" -KeySpec KeyExchange -Provider "Microsoft RSA SChannel Cryptographic Provider" -KeyUsage CertSign -HashAlgorithm sha256 -FriendlyName "NewSQLCert"

