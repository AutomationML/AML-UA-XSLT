<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" 
	xmlns:fn="http://www.w3.org/2005/xpath-functions" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns="http://opcfoundation.org/UA/2011/03/UANodeSet.xsd" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	exclude-result-prefixes="#default xsi xsl exslt fn" 
	xmlns:exslt="http://exslt.org/common">
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>

	<!--<xsl:function name="exslt:node-set">
		<xsl:param name="rtf"/>
		<xsl:sequence select="$rtf"/>
	</xsl:function>-->
	<xsl:variable name="DataTypes">
		<DataType OPC="String" AML="xs:string"/>
		<DataType OPC="Boolean" AML="xs:boolean"/>
		<DataType OPC="Decimal" AML="xs:decimal"/>
		<DataType OPC="Float" AML="xs:float"/>
		<DataType OPC="Double" AML="xs:double"/>
		<DataType OPC="Duration" AML="xs:duration"/>
		<DataType OPC="ByteString" AML="xs:base64Binary"/>
		<DataType OPC="Int64" AML="xs:long"/>
		<DataType OPC="Int32" AML="xs:int"/>
		<DataType OPC="Int16" AML="xs:short"/>
		<DataType OPC="SByte" AML="xs:byte"/>
		<DataType OPC="UInt64" AML="xs:unsignedLong"/>
		<DataType OPC="UInt32" AML="xs:unsignedInt"/>
		<DataType OPC="UInt16" AML="xs:unsignedShort"/>
		<DataType OPC="Byte" AML="xs:unsignedByte"/>
		<DataType OPC="NormalizedString " AML="xs:normalizedString "/>
		<DataType OPC="LocaleId" AML="xs:language"/>
		<DataType OPC="UriString" AML="xs:anyURI"/>
	</xsl:variable>
</xsl:stylesheet>