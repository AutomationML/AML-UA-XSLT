<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://opcfoundation.org/UA/2011/03/UANodeSet.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="CAEX_ClassModel_V2.15.xsd" exclude-result-prefixes="xsi">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
	
	<xsl:template name="ClassReferences">
		<xsl:variable name="LibName">
			<xsl:value-of select="@Name"/>
		</xsl:variable>
		<xsl:variable name="ObjectNodeId"><xsl:value-of select="@Name"/></xsl:variable>
		<References>
			<!-- Class hierarchy -->
			<Reference ReferenceType="HasSubType" IsForward="False">
				<xsl:choose>
					<xsl:when test="ancestor::InterfaceClass[1]">
						<xsl:text>ns=</xsl:text><xsl:value-of select="$LibName"/><xsl:text>;s=</xsl:text><xsl:value-of select="ancestor::InterfaceClass[1]/@Name"/>
					</xsl:when>
					<xsl:when test="@RefBaseClassPath">
						<xsl:variable name="BaseClass">
							<xsl:call-template name="GetClass">
								<xsl:with-param name="path">
									<xsl:value-of select="@RefBaseClassPath"/>
								</xsl:with-param>
							</xsl:call-template>	
						</xsl:variable>
						<xsl:text>ns=</xsl:text><xsl:value-of select="substring-before(@RefBaseClassPath,'/')"/><xsl:text>;s=</xsl:text><xsl:value-of select="$BaseClass/*/@Name"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>TODO</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="References">
					<xsl:with-param name="ObjectName">
						<xsl:value-of select="@Name"/>
					</xsl:with-param>
					<xsl:with-param name="ObjectId">
						<xsl:value-of select="@ID"/>
					</xsl:with-param>
				</xsl:call-template>
			</Reference>
			<!-- References for all Attribute properties -->
			<xsl:for-each select="Attribute">
				<xsl:comment>
					<xsl:text>Attribute: </xsl:text><xsl:value-of select="@Name"/>
				</xsl:comment>
				<Reference ReferenceType="HasProperty">ns=<xsl:value-of select="$LibName"/>;s=<xsl:value-of select="$ObjectNodeId"/>_<xsl:value-of select="@Name"/></Reference>
			</xsl:for-each>
		</References>	
	</xsl:template>
	<xsl:template name="Library">
		<xsl:variable name="LibName">
			<xsl:value-of select="@Name"/>
		</xsl:variable>
		<UAObject>
			<xsl:attribute name="NodeId">ns=<xsl:value-of select="$LibName"/>;s=Library</xsl:attribute>
			<xsl:attribute name="Name"><xsl:value-of select="$LibName"/></xsl:attribute>
			<xsl:if test="Description!=''">
				<Description><xsl:value-of select="Description"/></Description>
			</xsl:if>
			<References>
				<xsl:if test="Version">
					<Reference ReferenceType="HasProperty">ns=<xsl:value-of select="$LibName"/>;s=Library_Version</Reference>
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
		<xsl:variable name="LibName">
			<xsl:value-of select="@Name"/>
		</xsl:variable>
		<xsl:comment>
			InterfaceClassLib: <xsl:value-of select="$LibName"/>
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
		<UAObject>
			<xsl:attribute name="NodeId">ns=<xsl:value-of select="$LibName"/>;s=Library</xsl:attribute>
			<xsl:attribute name="Name"><xsl:value-of select="$LibName"/></xsl:attribute>
			<xsl:if test="Description!=''">
				<Description><xsl:value-of select="Description"/></Description>
			</xsl:if>
			<References>
				<!-- Reference to Version property -->
				<xsl:if test="Version">
					<xsl:comment>Version</xsl:comment>
					<Reference ReferenceType="HasProperty">ns=<xsl:value-of select="$LibName"/>;s=Library_Version</Reference>
				</xsl:if>
				<!-- Reference to CopyRight property -->
				<xsl:if test="Copyright">
					<xsl:comment>Copyright</xsl:comment>
					<Reference ReferenceType="HasProperty">ns=2;s={<xsl:value-of select="$ObjectId"/>}_Copyright</Reference>
				</xsl:if>
				<Reference ReferenceType="HasTypeDefinition">i=61</Reference>
				<Reference ReferenceType="Organizes" IsForward="false">ns=1;i=5008</Reference>
			</References>
		</UAObject>
		<xsl:apply-templates select="node()"/>
	</xsl:template>	
	<xsl:template match="//InterfaceClass">
		<xsl:variable name="LibName">
			<xsl:value-of select="ancestor::InterfaceClassLib[1]/@Name"/>
		</xsl:variable>
		<xsl:variable name="ObjectNodeId"><xsl:value-of select="@Name"/></xsl:variable>
		<UAObjectType>
			<xsl:attribute name="NodeId">ns=<xsl:value-of select="$LibName"/>;s=<xsl:value-of select="$ObjectNodeId"/></xsl:attribute>
			<xsl:attribute name="BrowserName"><xsl:value-of select="@Name"/></xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<xsl:if test="Description!=''">
				<Description><xsl:value-of select="Description"/></Description>
			</xsl:if>
			<xsl:call-template name="ClassReferences"/>
		</UAObjectType>
		<xsl:apply-templates select="node()"/>
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
		<xsl:variable name="LibName">
			<xsl:value-of select="ancestor::RoleClassLib[1]/@Name"/>
		</xsl:variable>

		<UAObjectType>
			<xsl:attribute name="NodeId">ns=<xsl:value-of select="$LibName"/>;s=<xsl:value-of select="@Name"/></xsl:attribute>
			<xsl:attribute name="BrowserName"><xsl:value-of select="@Name"/></xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<xsl:if test="Description!=''">
				<Description><xsl:value-of select="Description"/></Description>
			</xsl:if>
			<xsl:call-template name="ClassReferences"/>
		</UAObjectType>
		<xsl:apply-templates select="node()"/>
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
		<xsl:variable name="LibName">
			<xsl:value-of select="ancestor::RoleClassLib[1]/@Name"/>
		</xsl:variable>
		<UAObjectType>
			<xsl:attribute name="NodeId">ns=<xsl:value-of select="$LibName"/>;s=<xsl:value-of select="@Name"/></xsl:attribute>
			<xsl:attribute name="BrowserName"><xsl:value-of select="@Name"/></xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<xsl:if test="Description!=''">
				<Description><xsl:value-of select="Description"/></Description>
			</xsl:if>
			<xsl:call-template name="ClassReferences"/>
		</UAObjectType>
		<xsl:apply-templates select="node()"/>
	</xsl:template>
</xsl:stylesheet>
