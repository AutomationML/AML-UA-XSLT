<?xml version="1.0" encoding="UTF-8"?>
<!--TODO: Change xsi:noNamespaceSchemaLocation="CAEX_ClassModel_V2.15.xsd" schema here to CAEX V3-->

	
<!--xsl:stylesheet version="2.0" 
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns="http://opcfoundation.org/UA/2011/03/UANodeSet.xsd" 
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
		xsi:noNamespaceSchemaLocation="CAEX_ClassModel_V2.15.xsd" 
		exclude-result-prefixes="#default xsi xsl exslt fn"
		xmlns:exslt="http://exslt.org/common">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/-->

		
		<xsl:stylesheet version="2.0" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes=" xsl exslt fn" xmlns:exslt="http://exslt.org/common">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
<!--<xsl:function name="exslt:node-set">
		<xsl:param name="rtf"/>
		<xsl:sequence select="$rtf"/>
	</xsl:function>-->	
	
	
	<xsl:template name="ClassReferences">
		<xsl:variable name="Namespace">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>
	
		<References>
			<!-- Class hierarchy -->
			<Reference ReferenceType="HasSubType" IsForward="False">
				<xsl:choose>
					<xsl:when test="ancestor::InterfaceClass[1]">
						<xsl:value-of select="concat('ns=', $Namespace, ';s=', ancestor::InterfaceClass[1]/@Name)"/>
					</xsl:when>
					<xsl:when test="ancestor::RoleClass[1]">
						<xsl:value-of select="concat('ns=', $Namespace, ';s=', ancestor::RoleClass[1]/@Name)"/>
					</xsl:when>
					<xsl:when test="ancestor::SystemUnitClass[1]">
						<xsl:value-of select="concat('ns=', $Namespace, ';s=', ancestor::SystemUnitClass[1]/@Name)"/>
					</xsl:when>
					<xsl:when test="@RefBaseClassPath">
						<xsl:variable name="BaseClass">
							<xsl:call-template name="GetClass">
								<xsl:with-param name="path" select="@RefBaseClassPath"/>
							</xsl:call-template>	
						</xsl:variable>
								<xsl:variable name="ParentNS">
			<xsl:call-template name="GetNamespaceIdByName">
				<xsl:with-param name="Namespace"><xsl:value-of select="substring-before(@RefBaseClassPath,'/')"/></xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

						
						<xsl:value-of select="concat('ns=', $ParentNS, ';s=', exslt:node-set($BaseClass)/*/@Name)"/>
					</xsl:when>
					<xsl:otherwise><xsl:text>TODO</xsl:text></xsl:otherwise>
				</xsl:choose>
			</Reference>	
			<xsl:call-template name="References">
				<xsl:with-param name="ObjectName" select="@Name"/>
				<xsl:with-param name="ObjectId">
					<xsl:choose>
						<xsl:when test="@ID!=''">
							<xsl:value-of select="@ID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@Name"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="ObjectIdType">
					<xsl:choose>
						<xsl:when test="@ID!=''">
							<xsl:value-of select="'g'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'s'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="Namespace" select="$Namespace"/>
			</xsl:call-template>
		</References>	

	</xsl:template>
	<xsl:template name="Library">
		<xsl:variable name="Namespace">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>
		<UAObject>
			<xsl:attribute name="NodeId">
				<xsl:value-of select="concat('ns=', $Namespace, ';s=Library')"/>
			</xsl:attribute>
			<xsl:attribute name="Name"><xsl:value-of select="@Name"/></xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="@Name"/></xsl:attribute>
			<DisplayName><xsl:value-of select="@Name"/></DisplayName>
			<xsl:if test="Description!=''">
				<Description><xsl:value-of select="Description"/></Description>
			</xsl:if>
			<References>
				<xsl:if test="Version">
					<Reference ReferenceType="HasProperty">
						<xsl:value-of select="concat('ns=', $Namespace, ';s=Library_Version')"/>
					</Reference>
				</xsl:if>
				<Reference ReferenceType="HasTypeDefinition">i=61</Reference>
				<Reference ReferenceType="Organizes" IsForward="false">ns=1;i=5008</Reference>
			</References>
		</UAObject>	
	</xsl:template>
	
	<!-- .........................................................................
		InterfaceClassLib: Create UAObjectTypes
	.........................................................................-->
	<xsl:template match="InterfaceClassLib">
		<xsl:comment>
			InterfaceClassLib: <xsl:value-of select="@Name"/>
			==================================================
			TODOs:
				- Why are the libraries mapped as UAObject in the example file?
				- Do we need BackwardReferences here?
				- How to handle DefaultValues for attributes?
				- What is the corresponding UAObjectType for AutomationMLBaseInterface?
				- How to handle if the parent interface is not specified in the InterfaceClassLibs of the document?
				- Why is there a Reference to RoleClassLib in the Opc.Ua.AMLLibraries.Nodeset2.xml
					&lt;Reference ReferenceType="HasComponent" IsForward="false"&gt;ns=2;i=345&lt;/Reference&gt; 
		</xsl:comment>
		<xsl:call-template name="Library"/>
		<xsl:apply-templates select="node()"/>
	</xsl:template>	
	<xsl:template match="//InterfaceClass">
		<xsl:variable name="Namespace">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>

		<UAObjectType>
			<xsl:attribute name="NodeId"><xsl:value-of select="concat('ns=', $Namespace, ';s=', @Name)"/></xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="@Name"/></xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<xsl:if test="Description!=''">
				<Description><xsl:value-of select="Description"/></Description>
			</xsl:if>
			<xsl:call-template name="ClassReferences"/>
		</UAObjectType>

		<xsl:apply-templates select="node()|@*"/>
	</xsl:template>

	<!-- .........................................................................
		RoleClassLib: Create UAObjectTypes
	.........................................................................-->
	<xsl:template match="RoleClassLib">
		<xsl:comment>
			RoleClassLib: <xsl:value-of select="@Name"/>
			==================================================
			TODOs:
				- We need an example with ClassInClass definition
				- Do we need BackwardReferences here?
				- Why are this Objects in the example file?
				- What was the correct translation for an RoleClass?
				- Why is the lib modelled as UAObject?
		</xsl:comment>
		<xsl:call-template name="Library"/>
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	<xsl:template match="//RoleClass">
		<xsl:variable name="Namespace">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>

		<UAObjectType>
			<xsl:attribute name="NodeId"><xsl:value-of select="concat('ns=', $Namespace, ';s=', @Name)"/></xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="@Name"/></xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<xsl:if test="Description!=''">
				<Description><xsl:value-of select="Description"/></Description>
			</xsl:if>
			<xsl:call-template name="ClassReferences"/>
		</UAObjectType>
		<xsl:apply-templates select="node()|@*"/>
	</xsl:template>

	<!-- .........................................................................
		SystemUnitClassLib: Create UAObjectTypes
	.........................................................................-->
	<xsl:template match="SystemUnitClassLib">
		<xsl:comment>
			SystemUnitClassLib: <xsl:value-of select="@Name"/>
			==================================================
			TODOs:
				- We need an example with ClassInClass definition.
				- We need an inheritance example.
				- We need an example with multiple SystemUnitClassLibs and cross references.
				- Do we need BackwardReferences here?
				- Why are this Objects in the example file?
				- What was the correct translation for a SystemUnitClass?
				- Why is the lib modelled as UAObject?
		</xsl:comment>
		<xsl:call-template name="Library"/>
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	<xsl:template match="//SystemUnitClass">
		<xsl:variable name="Namespace">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>
		<UAObjectType>
			<xsl:attribute name="NodeId"><xsl:value-of select="concat('ns=', $Namespace, ';s=', @Name)"/></xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="@Name"/></xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<xsl:if test="Description!=''">
				<Description><xsl:value-of select="Description"/></Description>
			</xsl:if>
			<xsl:call-template name="ClassReferences"/>
		</UAObjectType>
		<xsl:apply-templates select="node()|@*"/>
	</xsl:template>
</xsl:stylesheet>
