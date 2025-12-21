## Install Oracle wallet and configure it to use with ADF.
The page describes a way of configuring Oracle Wallet on a self-hosted integration runtime (IR) and using it with Oracle V2 connector.

After updating Oracle linked service from V1 to V2 there could be issues with timeouts. Random connection requests stuck for hours and fail after timeout period ends. The proposed configuration example was advised by a Microsoft support engineer and fixed the problem in my case. Though, it may not help in other situations.

Download Oracle **Full** client from the [Oracle web site](https://www.oracle.com/database/technologies/oracle19c-windows-downloads.html).
The full client is required because it contains Oracle Wallet and the associated tools.
You may need to have an Oracle account, but it can be created free of charge.

On the download page it should look like this:

![pic](oracle_connector_v2/adf01.jpg)

Run installation.
**Oracle Advanced Security** is the only component we need.

![pic](oracle_connector_v2/adf02.jpg)

A reboot is not required.
The summary installation page.

![pic](oracle_connector_v2/adf03.jpg)

After the installation finishes there are additional steps to be completed:

1. Create system environment variable that will point to the Oracle wallet location, as well as SQLNET.ORA and TNSNAMES.ORA files.
Let’s assume the folder is - C:\OracleWallet. In that case, the variable should look like this:

`TNS_ADMIN = C:\OracleWallet`

![pic](oracle_connector_v2/adf07.jpg)


2. Ensure the Oracle bin folder **C:\app\client\clinigenadmin\product\19.0.0\client_1\bin** was added to the default Path environment variable.

![pic](oracle_connector_v2/adf04.jpg)


3. Create folder - **C:\OracleWallet**

4. Create Oracle wallet in that folder by executing

`mkstore -wrl C:\OracleWallet\ -create`

The command will ask for a password. Write it down. It will be used later.
Check there are two new files cwallet.sso and ewallet.p12

5. Create two more files in the folder, replacing values **alias**, **servername.domain.com** and **servicename** Here are the examples.

**SQLNET.ORA**
```
sqlnet.authentication_services= (NTS)
NAMES.
DIRECTORY_PATH= (TNSNAMES)
SQLNET.WALLET_OVERRIDE = TRUE
SSL_CLIENT_
AUTHENTICATION = FALSE
SSL_VERSION = 0
WALLET_LOCATION =
(SOURCE = (METHOD = FILE)
(METHOD_DATA = (DIRECTORY = C:\OracleWallet)))
```
**TNSNAMES.ORA**
```
alias =
(DESCRIPTION =
(ADDRESS_LIST =
(ADDRESS = (PROTOCOL = TCP) (HOST = servername.domain.com) (PORT = 1521))
)
(CONNECT_DATA =
(SERVICE_NAME = servicename)
)
)
```
By doing this, we define the Oracle wallet location and bind alias to the connection string.

6. Create username/password credentials in the wallet by executing
```mkstore -wrl C:\OracleWallet\ -createCredential alias USERNAME PASSW0RD```
Use the password from step 4

7. Test connectivity to the DB by **tsnping** command. There should be **OK** in the end.

![pic](oracle_connector_v2/adf05.jpg)

To make sure all the settings are applied, start **Microsoft Integration Runtime** and then **STOP** and **START** runtime services.
After that the new alias can be used in an ADF linked service instead of the full connection string.
Please note that you still need to enter the same username and password on the ADF side.

![pic](oracle_connector_v2/adf06.jpg)

That's it!
