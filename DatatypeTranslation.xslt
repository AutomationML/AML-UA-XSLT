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
		<DataType OPCAlias="String" OPCNodeId="i=12" AML="xs:string"/>
		<DataType OPCAlias="Boolean" OPCNodeId="i=1" AML="xs:boolean"/>
		<DataType OPCAlias="Decimal" OPCNodeId="" AML="xs:decimal"/>
		<DataType OPCAlias="Float" OPCNodeId="i=10" AML="xs:float"/>
		<DataType OPCAlias="Double" OPCNodeId="i=11" AML="xs:double"/>
		<DataType OPCAlias="Duration" OPCNodeId="" AML="xs:duration"/>
		<DataType OPCAlias="ByteString" OPCNodeId="i=15" AML="xs:base64Binary"/>
		<DataType OPCAlias="Int64" OPCNodeId="i=8" AML="xs:long"/>
		<DataType OPCAlias="Int32" OPCNodeId="i=6" AML="xs:int"/>
		<DataType OPCAlias="Int16" OPCNodeId="i=4" AML="xs:short"/>
		<DataType OPCAlias="SByte" OPCNodeId="i=2" AML="xs:byte"/>
		<DataType OPCAlias="UInt64" OPCNodeId="i=9" AML="xs:unsignedLong"/>
		<DataType OPCAlias="UInt32" OPCNodeId="i=7" AML="xs:unsignedInt"/>
		<DataType OPCAlias="UInt16" OPCNodeId="i=5" AML="xs:unsignedShort"/>
		<DataType OPCAlias="Byte" OPCNodeId="i=3" AML="xs:unsignedByte"/>
		<DataType OPCAlias="NormalizedString" OPCNodeId="" AML="xs:normalizedString "/>
		<DataType OPCAlias="LocaleId" OPCNodeId="" AML="xs:language"/>
		<DataType OPCAlias="UriString" OPCNodeId="" AML="xs:anyURI"/>
		<DataType OPCAlias="Guid" OPCNodeId="i=14" AML="xs:token"/>
		<!-- TODO: überprüfen -->
		<DataType OPCAlias="String" OPCNodeId="i=12" AML="xs:string"/>
		<DataType OPCAlias="ImagePNG" OPCNodeId="i=2003" AML="xs:string"/>
	</xsl:variable>
</xsl:stylesheet>