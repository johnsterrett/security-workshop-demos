# Workshop: Advanced Security Strategies for SQL Server
<p style="border-bottom: 1px solid lightgrey;"></p>
In this course you will learn how to implement advanced data security solutionss with SQL Server 2022 or SQL Server 2025 using a hands-on lab approach.
 <table style="tr:nth-child(even) {background-color: #f2f2f2;}; text-align: left; display: table; border-collapse: collapse; border-spacing: 2px; border-color: gray;">

<tr><th style="background-color: #1b20a1; color: white;">Technology</th> <th style="background-color: #1b20a1; color: white;">Description</th></tr>

<tr><td><i>SQL Server 2022/2025</i></td><td>The lastest major version(s) of SQL Server. SQL Server is a Database Platform released and sold by Microsoft</td></tr>
<tr><td><i>SQL Server Management Studio (SSMS)</i></td><td>Graphical User Interface Management and Query Tool</td></tr>
<tr><td><i>Data Classification</i></td><td>Classification for you existing data to determine which data is sensitive and should be protected with advance features.</td></tr>
<tr><td><i>Security Assessments</i></td><td>Learn how to perform security assessments on your SQL Server Instance</td></tr>
<tr><td><i>SQL Audit</i></td><td>Built-in tool to allow you to monitor whats going on your instance to help with compilance and threat detection.</td></tr>
<tr><td><i>Dynamic Data Masking</i></td><td>Built-in feature to help prevent unauthorized access to sensitive data by enabling you to specify how much sensitive data to reveal with minimal effect on the application layer.  </td></tr>
<tr><td><i>Row-Level Security</i></td><td>Built-in feature which enables you to use group membership or execution context to control access to rows in a database table.</td></tr>
<tr><td><i>Always Encrypted (Column-Level Encryption)<i></td><td>Built-in feature designed to safeguard sensitive information.It enables clients to encrypt sensitive data within client applications, ensuring that encryption keys are never exposed to the Database Engine. </td></tr>
<tr><td><i>Transparent data encryption (TDE)<i></td><td>Built-in feature to encrypt SQL Server data files. This encryption is known as encrypting data at rest, which is the data and log files. This ability lets software developers encrypt data at rest without changing existing applications.</td></tr>
<tr><td><i>Encrypting Data Connections (TLS)<i></td><td>Feature is designed to safeguard sensitive data packets in flight between the SQL Server and the client connecting.</td></tr>  
</table>

<h2><b>Before Taking this Workshop</b></h2>

To complete this workshop you will need the following:

- Before you attend the workshop, download all the scripts and files for hands-on exercises with one of the following methods:

1.	Clone the workshop repo with `git clone https://github.com/johnsterrett/security-workshop-demos.git`. You can download git for windows from https://gitforwindows.org. 
2.	Or download a zip file of the scripts from https://github.com/johnsterrett/security-workshop-demos/archive/refs/heads/main.zip. You will need to expand the zip file after downloading. Using this method the scripts will be under folders by module inside \security-workshop-demos-main.

- Setup a machine or VM and install the software and supporting files as listed in the **Setup** section below
<h3><b>Setup</b></h3>
In order to complete the exercises in this workshop you will need <b>one of the following two Database Platforms installed</b>:

- **SQL Server 2022 Evaluation Edition or Developer Edition General Availability** from (https://aka.ms/getsqlserver2022) with the Database Engine feature installed.
- **SQL Server 2025 Community Technology Preview** from (https://aka.ms/getsqlserver2025) with the Database Engine feature installed.
  
In order to complete the exercises in this workshop you will need <b> all of the following</b>:

- Install **SQL Server Management Studio (SSMS) 21** build from https://aka.ms/ssms/21/release/vs_SSMS.exe. Several of the modules require features built only into SSMS.
- Install **SQL Server Management Studio (SSMS) 18** build from https://go.microsoft.com/fwlink/?linkid=2199013&clcid=0x409. This feature is required to do parts of the Security Assessments lab.
- **WideWorldImporters** sample database from (https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak).
- **Sample HR database** sample data included in the repo. You can install via the bacpac (https://github.com/johnsterrett/security-workshop-demos/blob/main/contosohr.bacpac) or run the (https://github.com/johnsterrett/security-workshop-demos/blob/main/CreateDatabaseAndImportSampleData.sql)
