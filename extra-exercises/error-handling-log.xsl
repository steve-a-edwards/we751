<?xml version="1.0" encoding="UTF-8"?>
<!-- Demonstration code (Steve EDWARDS, 2015-01-14)
		- uses xsl:message to link with DataPower logging mechanism
		- this code triggers event (a custom category) 'error-handling-log-category'
		- add this log category to the domain
		- add a log target 'error-handling-log-target' that subscribes to this event
		- configure the log target to write entries to a file 'logtemp:///error-handling-log-file'
		- download this XSL file (can use 'Raw' tab) and upload to local: folder on DataPower
		- add a Transform action, using this, to a request rule (e.g. to MPGW HelloWorld)
		- send messages to this service, and then see entries in the log file
 -->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dp="http://www.datapower.com/extensions"
    xmlns:date="http://exslt.org/dates-and-times"
    exclude-result-prefixes="dp date">
    
	<xsl:template match="/">
		<!-- Use a service variable to get the DataPower device name -->
		<xsl:variable name="device-name" select="dp:variable('var://service/system/ident')/identification/device-name"/>
		<!-- Use other service variables (see fuller list at bottom of this file) -->
		<xsl:variable name="my-log-message">
{"error-details": {	
"client-ip": "<xsl:value-of select="dp:variable('var://service/transaction-client')"/>",
"DataPower": "<xsl:value-of select="$device-name"/>",
"error-subcode": "<xsl:value-of select="dp:variable('var://service/error-subcode')"/>",
"error-message": "<xsl:value-of select="dp:variable('var://service/error-message')"/>",
"request-size": "<xsl:value-of select="dp:variable('var://service/mpgw/request-size')"/>"}
}
		</xsl:variable>

		<!-- This xsl:message links with the DataPower logging system
				- triggering the event (category) 'error-handling-log-category'
				- any log targets subscribing to this event will get the following entry
		-->
		<xsl:message 
				dp:type='error-handling-log-category'
				dp:priority='error'><xsl:value-of select="normalize-space($my-log-message)"/>
		</xsl:message>

		<!-- Output incoming XML (not used): -->
		<xsl:copy-of select="/"/>
		
	</xsl:template>
<!--
var://service/client-service-address	string	'172.30.100.6:2826'
var://service/conformance/policyname	string	(empty string)
var://service/connection/note	string	(empty string)
var://service/current-call-depth	string	'0'
var://service/domain-name	string	'test-domain'
var://service/error-code	string	'0x00000000'
var://service/error-headers	string	(empty string)
var://service/error-ignore	string	'0'
var://service/error-message	string	(empty string)
var://service/error-subcode	string	'0x00000000'
var://service/formatted-error-message	string	(empty string)
var://service/header-manifest	node-set	(show nodeset)
var://service/input-size	string	'295'
var://service/lb/group	string	(empty string)
var://service/lb/member	string	(empty string)
var://service/local-service-address	string	'172.30.1.38:10595'
var://service/max-action-depth	string	'128'
var://service/max-call-depth	string	'128'
var://service/mpgw/backend-timeout	string	'120'
var://service/mpgw/request-size	string	'295'
var://service/mpgw/response-size	string	'0'
var://service/multistep/contexts	node-set	(show nodeset)
var://service/multistep/input-context-name	string	'INPUT'
var://service/multistep/loop-count	string	(empty string)
var://service/multistep/loop-iterator	string	(empty string)
var://service/multistep/output-context-name	string	'NULL'
var://service/original-content-type	string	'text/xml'
var://service/persistent-connection-counter	string	'1'
var://service/processor-name	string	'steve-mpg'
var://service/processor-type	string	'Multiprotocol Gateway'
var://service/protocol	string	'http'
var://service/protocol-method	string	'POST '
var://service/qos/priority	string	'normal'
var://service/routing-url	string	'http://172.30.1.38:10595/'
var://service/routing-url-sslprofile	string	(empty string)
var://service/soap-fault-response	string	'0'
var://service/strict-error-mode	string	'false'
var://service/system/ident	node-set	(show nodeset)
var://service/time-elapsed	string	'23'
var://service/time-forwarded	string	'0'
var://service/time-response-complete	string	'0'
var://service/time-started	string	'1'
var://service/transaction-audit-trail	node-set	(show nodeset)
var://service/transaction-client	string	'172.30.100.6'
var://service/transaction-id	string	'1068898'
var://service/transaction-policy-name	string	'steve-policy'
var://service/transaction-rule-name	string	'steve-rule'
var://service/transaction-rule-type	string	'request'
var://service/URI	string	'/'
var://service/URL-in	string	'http://172.30.1.38:10595/'
var://service/URL-out	string	'http://172.30.1.38:10595/'
var://service/wsa/genpattern	string	'sync'
var://service/wsa/timeout	string	'120'
var://service/wsm/http-parsed-url-replacement	node-set	(show nodeset)
var://service/wspolicy/endpoint/configname	string	(empty string)
var://service/wspolicy/message/configname	string	(empty string)
var://service/wspolicy/operation/configname	string	(empty string)
var://service/wspolicy/service/configname	string	(empty string)
var://service/xmlmgr-name	string	'default'
-->
</xsl:stylesheet>
