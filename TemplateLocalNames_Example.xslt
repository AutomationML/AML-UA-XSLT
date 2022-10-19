<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes=" xsl exslt fn" xmlns:exslt="http://exslt.org/common">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>	
	
	
		<!--ToDo: delete namespace for all elements-->
	<xsl:template match="*">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="@* | node()"/>
		</xsl:element>
	</xsl:template>
	<!--ToDo: delete namespace for all attributes-->
	<xsl:template match="@*">
		<xsl:attribute name="{local-name()}">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	<!--ToDo: delete namespace for all other elements-->
	<xsl:template match="comment() | text() | processing-instruction()">
		<xsl:copy/>
	</xsl:template>
	
	<!--ToDo check with 3 instructions above-->
	<xsl:template match="@*|node()[not(self::*)]">
		<xsl:apply-templates select="node()|@*"/>
		<!--take everything which could not be mapped in original state-->
		<xsl:value-of select="."/>
	</xsl:template>

	
</xsl:stylesheet>



