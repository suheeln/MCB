..::: Example command line :::..

'mvn clean verify -Dapk.name=${APK_NAME} -Djenkins.url=${JENKINS_URL} -Djob.name=${JOB_NAME} -Dserver.ip_address=192.168.111.148 -Dserver.port_number=4723 -Dlogin=Frederick -Dpassword=Testing!2 -Dsecurity.answer="a 1" -Dapp.package=sone.mbanking.test.debug -Dfailsafe.includesFile=ssfcu-test-class-include-list.txt -Pintegration-test'


..::: Java Properties :::..

- apk.name = the file name for the apk that the system will push to the test devices. (Supplied by Jenkins via env variable)

- jenkins.url = (supplied by Jenkins via env variable)

- job.name = (supplied by Jenkins via env variable)

- server.ip_address = the ipv4 address for the Appium server

- server.port_number = the port address for the particular Appium instance used.  The server may have multiple Appium instances running.

- login = The single login to be used for testing

- password = password for above

- security.answer = MFA response given for LOA3 logins using the above credentials

- app.package = the package name for the apk above

- failsafe.includesFile = the list of test classes to be executed


..::: Maven Profiles :::..

- integration-test = Runs and reports on all *IT.java files found in the customer.base package.