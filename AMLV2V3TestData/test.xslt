<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
 <xsl:strip-space elements="*"/>
 <xsl:template match="@*|node()[not(self::*)]">
  <xsl:copy/>
 </xsl:template>
 <xsl:template match="*">
  <xsl:element name="{local-name()}">
   <xsl:apply-templates select="node()|@*"/>
  </xsl:element>
 </xsl:template>
</xsl:stylesheet>